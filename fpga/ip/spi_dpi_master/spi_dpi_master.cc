// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>

#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <mutex>
#include <queue>
#include <thread>
#include <atomic>
#include <vector>

#include "svdpi.h"

namespace {
// Defines the type of SPI command received over the socket.
enum class CommandType : uint8_t {
  // Direct mapping from SPIMaster
  WRITE_REG = 0,
  POLL_REG = 1,
  IDLE_CLOCKING = 2,
  PACKED_WRITE = 3,
  BULK_READ = 4,
  READ_SPI_DOMAIN_REG = 5,
  WRITE_REG_16B = 6,
  READ_SPI_DOMAIN_REG_16B = 7,
};

// The command structure sent from the Python client.
struct SpiCommand {
  CommandType type;
  uint32_t addr;  // For reg commands
  uint64_t data;  // For simple writes or expected value
  uint32_t count; // For bulk commands or wait cycles
} __attribute__((packed));

// The response packet sent back to the Python client.
struct SpiResponse {
  uint64_t data; // For simple reads
  uint8_t success;
} __attribute__((packed));

// A version of the command for the internal queue that can hold a data payload.
struct QueuedSpiCommand {
    SpiCommand header;
    std::vector<uint8_t> payload;
};

// Thread-safe queues for IPC between the server thread and the simulation thread.
std::queue<QueuedSpiCommand> cmd_queue;
std::mutex cmd_mutex;
std::queue<SpiResponse> result_queue;
std::mutex result_mutex;
std::queue<std::vector<uint8_t>> bulk_read_queue;
std::mutex bulk_read_mutex;

// Global state for the server thread.
int server_fd = -1;
std::thread server_thread;
std::atomic<bool> shutting_down{false};

struct SpiSignalState {
  uint8_t sck;
  uint8_t csb;
  uint8_t mosi;
};

// State for the DPI state machine.
enum SpiFsmState {
  IDLE,
  WRITE_REG_CMD_START,
  WRITE_REG_CMD_WAIT_SETUP,
  WRITE_REG_CMD_SHIFT,
  WRITE_REG_CMD_END,
  WRITE_REG_CMD_EXTRA_CLOCKS,
  WRITE_REG_DATA_START,
  WRITE_REG_DATA_WAIT_SETUP,
  WRITE_REG_DATA_SHIFT,
  WRITE_REG_DATA_END,
  WRITE_REG_DATA_EXTRA_CLOCKS,
  WRITE_REG_16B_START,
  WRITE_REG_16B_WAIT_SETUP,
  WRITE_REG_16B_SHIFT,
  WRITE_REG_16B_END_BYTE,
  WRITE_REG_16B_END,
  POLL_REG_START,
  POLL_REG_CHECK,
  POLL_REG_TXN_START,
  POLL_REG_TXN_WAIT_SETUP,
  POLL_REG_TXN_SHIFT,
  POLL_REG_TXN_END,
  POLL_REG_TXN_WAIT,
  READ_SPI_DOMAIN_START,
  READ_SPI_DOMAIN_SHIFT_CMD,
  READ_SPI_DOMAIN_SHIFT_DATA,
  READ_SPI_DOMAIN_END,
  READ_SPI_DOMAIN_16B_START,
  READ_SPI_DOMAIN_16B_PREPARE,
  READ_SPI_DOMAIN_16B_SHIFT,
  READ_SPI_DOMAIN_16B_END_BYTE,
  READ_SPI_DOMAIN_16B_END,
  BULK_READ_START,
  BULK_READ_SHIFT_CMD_L,
  BULK_READ_SHIFT_LEN_L,
  BULK_READ_SHIFT_CMD_H,
  BULK_READ_SHIFT_LEN_H,
  BULK_READ_SHIFT_FLUSH,
  BULK_READ_SHIFT_DATA,
  BULK_READ_END,
  IDLE_TICKING,
  PACKED_WRITE_START,
  PACKED_WRITE_WAIT_SETUP,
  PACKED_WRITE_SHIFT,
  PACKED_WRITE_END_BYTE,
  PACKED_WRITE_END,
};

enum PackedWriteStage {
  ADDRESS_STAGE,
  BEATS_STAGE,
  DATA_PAYLOAD_STAGE,
  DATA_STREAM_STAGE,
  ISSUE_COMMAND_STAGE,
  DONE_STAGE,
};

struct SpiDpiFsmState {
  SpiFsmState state;
  SpiSignalState signal_state;
  QueuedSpiCommand current_cmd;
  uint8_t data_out = 0;
  uint8_t data_in = 0;
  int bit_count = 0;
  bool is_polling = false;
  int packed_write_stage = ADDRESS_STAGE;
  int packed_write_sub_idx = 0;
  int write_16b_sub_idx = 0;
  int read_16b_sub_idx = 0;
  uint16_t read_16b_data = 0;
  int poll_count = 0;
  int cycle_wait_count = 0;
  int bulk_data_idx = 0;
  std::vector<uint8_t> bulk_data_buffer;

  void init() {
    this->state = IDLE;
    this->signal_state = {0, 1, 0};
    this->bit_count = 0;
    this->data_out = 0;
    this->data_in = 0;
    this->is_polling = false;
    this->packed_write_stage = ADDRESS_STAGE;
    this->packed_write_sub_idx = 0;
    this->write_16b_sub_idx = 0;
    this->read_16b_sub_idx = 0;
    this->read_16b_data = 0;
    this->poll_count = 0;
    this->cycle_wait_count = 0;
    this->bulk_data_idx = 0;
    this->bulk_data_buffer.clear();
  }
};

// static SpiDpiFsmState fsm_state;

// The main loop for the server thread. It listens for a client connection,
// reads commands, and pushes them to the thread-safe command queue.
void server_loop(int port) {
  struct sockaddr_in address;
  int opt = 1;
  socklen_t addrlen = sizeof(address);

  if ((server_fd = socket(AF_INET, SOCK_STREAM, 0)) == 0) {
    perror("socket failed");
    return;
  }

  if (setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &opt, sizeof(opt))) {
    perror("setsockopt");
    return;
  }
  address.sin_family = AF_INET;
  address.sin_addr.s_addr = INADDR_ANY;
  address.sin_port = htons(port);

  if (bind(server_fd, (struct sockaddr*)&address, sizeof(address)) < 0) {
    perror("bind failed");
    return;
  }
  if (listen(server_fd, 3) < 0) {
    perror("listen");
    return;
  }

  std::cout << "DPI: Server listening on port " << port << std::endl;

  int client_socket;
  if ((client_socket = accept(server_fd, (struct sockaddr*)&address, &addrlen)) < 0) {
    if (!shutting_down) {
      perror("accept");
    }
    return;
  }

  while (true) {
    SpiCommand cmd_header;
    int valread = read(client_socket, &cmd_header, sizeof(cmd_header));
    if (valread <= 0) {
      // Client disconnected or error.
      break;
    }

    QueuedSpiCommand q_cmd;
    q_cmd.header = cmd_header;

    if (cmd_header.type == CommandType::PACKED_WRITE) {
      size_t payload_size = cmd_header.count;
      payload_size *= 16;
      if (payload_size > 0) {
        q_cmd.payload.resize(payload_size);
        read(client_socket, q_cmd.payload.data(), payload_size);
      }
    }

    {
      std::lock_guard<std::mutex> lock(cmd_mutex);
      cmd_queue.push(q_cmd);
    }

    // All commands expect a response packet.
    // Busy-wait for the result to become available from the simulation thread.
    while (result_queue.empty()) {
      std::this_thread::sleep_for(std::chrono::milliseconds(1));
    }

    SpiResponse response;
    {
      std::lock_guard<std::mutex> lock(result_mutex);
      response = result_queue.front();
      result_queue.pop();
    }
    send(client_socket, &response, sizeof(response), 0);

    // If it was a successful bulk read, also send the data payload.
    if ((cmd_header.type == CommandType::BULK_READ) && response.success) {
        while(bulk_read_queue.empty()) {
            std::this_thread::sleep_for(std::chrono::milliseconds(1));
        }
        std::vector<uint8_t> read_payload;
        {
            std::lock_guard<std::mutex> lock(bulk_read_mutex);
            read_payload = bulk_read_queue.front();
            bulk_read_queue.pop();
        }
        send(client_socket, read_payload.data(), read_payload.size(), 0);
    }
  }
  close(client_socket);
}

} // namespace

extern "C" {

struct SpiDpiFsmState* spi_dpi_init() {
  const char* port_str = getenv("SPI_DPI_PORT");
  int port = 5555; // Default port
  if (port_str) {
    port = std::stoi(port_str);
  } else {
    std::cout << "SPI_DPI_PORT environment variable not set. Defaulting to " << port << std::endl;
  }
  server_thread = std::thread(server_loop, port);
  struct SpiDpiFsmState* ctx = new SpiDpiFsmState();
  ctx->init();
  return ctx;
}

void spi_dpi_close(struct SpiDpiFsmState* ctx) {
  shutting_down = true;
  if (server_fd != -1) {
    // Shutting down the socket will cause the accept/read calls to terminate.
    shutdown(server_fd, SHUT_RDWR);
  }
  if (server_thread.joinable()) {
    server_thread.join();
  }
  if (ctx) {
    delete ctx;
  }
}

void spi_dpi_reset(struct SpiDpiFsmState* ctx) {
  // Reset the state machine
  ctx->init();

  // Clear any pending commands or results
  {
    std::lock_guard<std::mutex> lock(cmd_mutex);
    std::queue<QueuedSpiCommand> empty_cmd;
    cmd_queue.swap(empty_cmd);
  }
  {
    std::lock_guard<std::mutex> lock(result_mutex);
    std::queue<SpiResponse> empty_result;
    result_queue.swap(empty_result);
  }
  {
    std::lock_guard<std::mutex> lock(bulk_read_mutex);
    std::queue<std::vector<uint8_t>> empty_bulk;
    bulk_read_queue.swap(empty_bulk);
  }
}

void handle_write_reg(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case WRITE_REG_CMD_START:
      ctx->data_out = (1 << 7) | ctx->current_cmd.header.addr;
      ctx->signal_state.csb = 0;
      ctx->state = WRITE_REG_CMD_WAIT_SETUP;
      ctx->cycle_wait_count = 1;
      break;

    case WRITE_REG_CMD_WAIT_SETUP:
      if (--ctx->cycle_wait_count <= 0) {
        ctx->bit_count = 0;
        ctx->data_in = 0;
        ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        ctx->state = WRITE_REG_CMD_SHIFT;
      }
      break;

    case WRITE_REG_CMD_SHIFT:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (ctx->signal_state.sck) { // Posedge
      } else { // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->state = WRITE_REG_CMD_EXTRA_CLOCKS;
          ctx->cycle_wait_count = 2 * 2; // 2 extra clock cycles
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case WRITE_REG_CMD_END:
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = WRITE_REG_DATA_START;
      break;

    case WRITE_REG_CMD_EXTRA_CLOCKS:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (--ctx->cycle_wait_count <= 0) {
        ctx->signal_state.sck = 0;
        ctx->state = WRITE_REG_CMD_END;
      }
      break;

    case WRITE_REG_DATA_START:
      ctx->data_out = ctx->current_cmd.header.data;
      ctx->signal_state.csb = 0;
      ctx->state = WRITE_REG_DATA_WAIT_SETUP;
      ctx->cycle_wait_count = 1;
      break;

    case WRITE_REG_DATA_WAIT_SETUP:
      if (--ctx->cycle_wait_count <= 0) {
        ctx->bit_count = 0;
        ctx->data_in = 0;
        ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        ctx->state = WRITE_REG_DATA_SHIFT;
      }
      break;

    case WRITE_REG_DATA_SHIFT:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (ctx->signal_state.sck) { // Posedge
      } else { // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->state = WRITE_REG_DATA_EXTRA_CLOCKS;
          ctx->cycle_wait_count = 2 * 2; // 2 extra clock cycles
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case WRITE_REG_DATA_END:
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = IDLE;
      {
        std::lock_guard<std::mutex> lock(result_mutex);
        result_queue.push({0, 1}); // Success, no data to return
      }
      break;

    case WRITE_REG_DATA_EXTRA_CLOCKS:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (--ctx->cycle_wait_count <= 0) {
        ctx->signal_state.sck = 0;
        ctx->state = WRITE_REG_DATA_END;
      }
      break;

    default:
      abort();
  }
}

void handle_write_reg_16b(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case WRITE_REG_16B_START:
      ctx->signal_state.csb = 0;
      ctx->signal_state.sck = 0;
      ctx->state = WRITE_REG_16B_WAIT_SETUP;
      ctx->cycle_wait_count = 1;
      break;

    case WRITE_REG_16B_WAIT_SETUP:
      if (--ctx->cycle_wait_count <= 0) {
        // Determine the next byte to transmit based on sub-index.
        switch (ctx->write_16b_sub_idx) {
          case 0: // CMD_L
            ctx->data_out = 0x80 | ctx->current_cmd.header.addr;
            break;
          case 1: // DATA_L
            ctx->data_out = ctx->current_cmd.header.data & 0xFF;
            break;
          case 2: // CMD_H
            ctx->data_out = 0x80 | (ctx->current_cmd.header.addr + 1);
            break;
          case 3: // DATA_H
            ctx->data_out = (ctx->current_cmd.header.data >> 8) & 0xFF;
            break;
        }
        ctx->bit_count = 0;
        ctx->data_in = 0;
        ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        ctx->state = WRITE_REG_16B_SHIFT;
      }
      break;

    case WRITE_REG_16B_SHIFT:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) {  // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->state = WRITE_REG_16B_END_BYTE;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case WRITE_REG_16B_END_BYTE:
      ctx->write_16b_sub_idx++;
      if (ctx->write_16b_sub_idx >= 4) {
        ctx->state = WRITE_REG_16B_END;
      } else {
        // In packed mode, there are no delays between bytes.
        ctx->state = WRITE_REG_16B_WAIT_SETUP;
        ctx->cycle_wait_count = 0; // Go straight to next byte
      }
      break;

    case WRITE_REG_16B_END:
      ctx->signal_state.sck = 0;
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = IDLE;
      {
        std::lock_guard<std::mutex> lock(result_mutex);
        result_queue.push({0, 1});  // Success
      }
      break;
    default:
      abort();
  }
}

void handle_poll_reg(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case POLL_REG_START:
      // The first transaction is to prime the pipeline. The data received is junk.
      ctx->poll_count = ctx->current_cmd.header.count;
      ctx->state = POLL_REG_TXN_START;
      break;

    case POLL_REG_CHECK:
      if (ctx->data_in == ctx->current_cmd.header.data) {
        // Success!
        ctx->state = IDLE;
        {
          std::lock_guard<std::mutex> lock(result_mutex);
          result_queue.push({1, 1}); // Return success
        }
      } else if (--ctx->poll_count <= 0) {
        // Timeout
        ctx->state = IDLE;
        {
          std::lock_guard<std::mutex> lock(result_mutex);
          result_queue.push({0, 1}); // Return failure
        }
      } else {
        // Not the value we want, try another read.
        ctx->state = POLL_REG_TXN_START;
      }
      break;

    case POLL_REG_TXN_START:
      ctx->data_out = ctx->current_cmd.header.addr; // Always send the read command
      ctx->signal_state.csb = 0;
      ctx->state = POLL_REG_TXN_WAIT_SETUP;
      ctx->cycle_wait_count = 1;
      break;

    case POLL_REG_TXN_WAIT_SETUP:
      if (--ctx->cycle_wait_count <= 0) {
        ctx->bit_count = 0;
        ctx->data_in = 0;
        ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        ctx->state = POLL_REG_TXN_SHIFT;
      }
      break;

    case POLL_REG_TXN_SHIFT:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->signal_state.sck = 0; // Ensure clock ends low
          ctx->state = POLL_REG_TXN_END;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case POLL_REG_TXN_END:
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = POLL_REG_TXN_WAIT;
      ctx->cycle_wait_count = 5; // Wait between polls
      break;

    case POLL_REG_TXN_WAIT:
      if (--ctx->cycle_wait_count <= 0) {
        ctx->state = POLL_REG_CHECK;
      }
      break;

    default:
      abort();
  }
}

void handle_idle_clocking(unsigned char miso, struct SpiDpiFsmState* ctx) {
  ctx->signal_state.sck = !ctx->signal_state.sck;
  if (--ctx->cycle_wait_count <= 0) {
    ctx->signal_state.sck = 0; // Ensure clock is left low
    ctx->state = IDLE;
    {
      std::lock_guard<std::mutex> lock(result_mutex);
      result_queue.push({0, 1});
    }
  }
}

void handle_packed_write(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case PACKED_WRITE_START:
      ctx->signal_state.csb = 0;
      ctx->signal_state.sck = 0;
      ctx->state = PACKED_WRITE_WAIT_SETUP;
      ctx->cycle_wait_count = 1; // 1 full clock cycle wait
      break;

    case PACKED_WRITE_WAIT_SETUP:
      if (--ctx->cycle_wait_count <= 0) {
        // Determine the next byte to transmit based on stage and sub-index.
        switch (ctx->packed_write_stage) {
          case ADDRESS_STAGE:  // Address stage (4 bytes, 8 transfers)
            if (ctx->packed_write_sub_idx % 2 == 0) {  // Command byte
              ctx->data_out = 0x80 | (0x00 + (ctx->packed_write_sub_idx / 2));
            } else {  // Data byte
              ctx->data_out = (ctx->current_cmd.header.addr >> ((ctx->packed_write_sub_idx / 2) * 8)) & 0xFF;
            }
            break;
          case BEATS_STAGE:  // Beats stage (2 bytes, 4 transfers)
            if (ctx->packed_write_sub_idx % 2 == 0) { // Command byte
                ctx->data_out = 0x80 | (0x04 + (ctx->packed_write_sub_idx / 2));
            } else { // Data byte
                uint32_t num_beats = ctx->current_cmd.header.count;
                ctx->data_out = ((num_beats - 1) >> ((ctx->packed_write_sub_idx / 2) * 8)) & 0xFF;
            }
            break;
          case DATA_PAYLOAD_STAGE:
            if (ctx->packed_write_sub_idx % 2 == 0) { // Command byte
                ctx->data_out = 0x80 | (0x0A + (ctx->packed_write_sub_idx / 2));
            } else { // Data byte
                uint32_t num_bytes = ctx->current_cmd.payload.size();
                ctx->data_out = ((num_bytes - 1) >> ((ctx->packed_write_sub_idx / 2) * 8)) & 0xFF;
            }
            break;
          case DATA_STREAM_STAGE:
            ctx->data_out = ctx->current_cmd.payload[ctx->packed_write_sub_idx];
            break;
          case ISSUE_COMMAND_STAGE:
            if (ctx->packed_write_sub_idx % 2 == 0) {  // Command byte
              ctx->data_out = 0x80 | 0x06;
            } else {  // Data byte
              ctx->data_out = 0x02;
            }
            break;
        }
        ctx->bit_count = 0;
        ctx->data_in = 0;
        ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        ctx->state = PACKED_WRITE_SHIFT;
      }
      break;

    case PACKED_WRITE_SHIFT:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) {  // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->state = PACKED_WRITE_END_BYTE;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case PACKED_WRITE_END_BYTE:
      ctx->packed_write_sub_idx++;
      switch (ctx->packed_write_stage) {
        case ADDRESS_STAGE:
          if (ctx->packed_write_sub_idx >= 8) {
            ctx->packed_write_stage = BEATS_STAGE;
            ctx->packed_write_sub_idx = 0;
          }
          break;
        case BEATS_STAGE:
          if (ctx->packed_write_sub_idx >= 4) {
            ctx->packed_write_stage = DATA_PAYLOAD_STAGE;
            ctx->packed_write_sub_idx = 0;
          }
          break;
        case DATA_PAYLOAD_STAGE:
          if (ctx->packed_write_sub_idx >= 4) {
            ctx->packed_write_stage = DATA_STREAM_STAGE;
            ctx->packed_write_sub_idx = 0;
          }
          break;
        case DATA_STREAM_STAGE:
          if (ctx->packed_write_sub_idx >= ctx->current_cmd.payload.size()) {
            ctx->packed_write_stage = ISSUE_COMMAND_STAGE;
            ctx->packed_write_sub_idx = 0;
          }
          break;
        case ISSUE_COMMAND_STAGE:
          if (ctx->packed_write_sub_idx >= 2) {
            ctx->packed_write_stage = DONE_STAGE;
          }
          break;
      }

      if (ctx->packed_write_stage == DONE_STAGE) {
        ctx->state = PACKED_WRITE_END;
      } else {
        ctx->state = PACKED_WRITE_WAIT_SETUP;
        ctx->cycle_wait_count = 0;
      }
      break;

    case PACKED_WRITE_END:
      ctx->signal_state.sck = 0;
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = IDLE;
      {
        std::lock_guard<std::mutex> lock(result_mutex);
        result_queue.push({0, 1});  // Success
      }
      break;
    default:
      abort();
  }
}

void handle_bulk_read(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case BULK_READ_START:
      ctx->signal_state.csb = 0;
      // Start shifting command byte
      ctx->data_out = 0x80 | 0x0C; // WRITE to BULK_READ_PORT_L
      ctx->bit_count = 0;
      ctx->data_in = 0;
      ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
      ctx->state = BULK_READ_SHIFT_CMD_L;
      break;

    case BULK_READ_SHIFT_CMD_L:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          // Start shifting length byte
          ctx->data_out = (ctx->current_cmd.header.count - 1) & 0xFF;
          ctx->bit_count = 0;
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
          ctx->state = BULK_READ_SHIFT_LEN_L;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case BULK_READ_SHIFT_LEN_L:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          // Start shifting command byte
          ctx->data_out = 0x80 | 0x0D; // WRITE to BULK_READ_PORT_H
          ctx->bit_count = 0;
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
          ctx->state = BULK_READ_SHIFT_CMD_H;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case BULK_READ_SHIFT_CMD_H:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          // Start shifting length byte
          ctx->data_out = ((ctx->current_cmd.header.count - 1) >> 8) & 0xFF;
          ctx->bit_count = 0;
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
          ctx->state = BULK_READ_SHIFT_LEN_H;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case BULK_READ_SHIFT_LEN_H:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          // Start shifting flush byte
          ctx->data_out = 0x00;
          ctx->bit_count = 0;
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
          ctx->state = BULK_READ_SHIFT_FLUSH;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case BULK_READ_SHIFT_FLUSH:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          // Start shifting data bytes
          ctx->data_out = 0x00; // Keep MOSI low
          ctx->bit_count = 0;
          ctx->data_in = 0;
          ctx->state = BULK_READ_SHIFT_DATA;
        }
      }
      break;

    case BULK_READ_SHIFT_DATA:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->bulk_data_buffer[ctx->bulk_data_idx++] = ctx->data_in;
          if (ctx->bulk_data_idx >= ctx->current_cmd.header.count) {
            ctx->state = BULK_READ_END;
          } else {
            // Reset for next byte
            ctx->bit_count = 0;
            ctx->data_in = 0;
          }
        }
      }
      break;

    case BULK_READ_END:
      ctx->signal_state.sck = 0;
      ctx->signal_state.csb = 1;
      ctx->state = IDLE;
      {
        std::lock_guard<std::mutex> lock(result_mutex);
        result_queue.push({0, 1}); // Success, data is sent separately
      }
      {
        std::lock_guard<std::mutex> lock(bulk_read_mutex);
        bulk_read_queue.push(ctx->bulk_data_buffer);
      }
      break;

    default:
      abort();
  }
}

void handle_read_spi_domain_reg(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case READ_SPI_DOMAIN_START:
      ctx->data_out = ctx->current_cmd.header.addr;
      ctx->signal_state.csb = 0;
      ctx->bit_count = 0;
      ctx->data_in = 0;
      ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
      ctx->state = READ_SPI_DOMAIN_SHIFT_CMD;
      break;

    case READ_SPI_DOMAIN_SHIFT_CMD:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          // First byte done, start second byte
          ctx->data_out = 0x00; // Dummy byte
          ctx->bit_count = 0;
          ctx->data_in = 0;
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
          ctx->state = READ_SPI_DOMAIN_SHIFT_DATA;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case READ_SPI_DOMAIN_SHIFT_DATA:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) { // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->state = READ_SPI_DOMAIN_END;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case READ_SPI_DOMAIN_END:
      ctx->signal_state.sck = 0;
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = IDLE;
      {
        std::lock_guard<std::mutex> lock(result_mutex);
        result_queue.push({(uint64_t)ctx->data_in, 1});
      }
      break;

    default:
      abort();
  }
}

void handle_read_spi_domain_reg_16b(unsigned char miso, struct SpiDpiFsmState* ctx) {
  switch (ctx->state) {
    case READ_SPI_DOMAIN_16B_START:
      ctx->signal_state.csb = 0;
      ctx->signal_state.sck = 0;
      ctx->read_16b_sub_idx = 0;
      ctx->read_16b_data = 0;
      ctx->state = READ_SPI_DOMAIN_16B_PREPARE;
      break;

    case READ_SPI_DOMAIN_16B_PREPARE:
        // Determine the next byte to transmit based on sub-index.
        if (ctx->read_16b_sub_idx % 2 == 0) { // Command byte
            ctx->data_out = ctx->current_cmd.header.addr + (ctx->read_16b_sub_idx / 2);
        } else { // Dummy byte for read
            ctx->data_out = 0x00;
        }
        ctx->bit_count = 0;
        ctx->data_in = 0;
        ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        ctx->state = READ_SPI_DOMAIN_16B_SHIFT;
      break;

    case READ_SPI_DOMAIN_16B_SHIFT:
      ctx->signal_state.sck = !ctx->signal_state.sck;
      if (!ctx->signal_state.sck) {  // Negedge
        ctx->data_in = (ctx->data_in << 1) | miso;
        ctx->bit_count++;
        if (ctx->bit_count == 8) {
          ctx->state = READ_SPI_DOMAIN_16B_END_BYTE;
        } else {
          ctx->signal_state.mosi = (ctx->data_out >> (7 - ctx->bit_count)) & 1;
        }
      }
      break;

    case READ_SPI_DOMAIN_16B_END_BYTE:
      if (ctx->read_16b_sub_idx % 2 != 0) { // This was a data byte
        if (ctx->read_16b_sub_idx == 1) { // Low byte
          ctx->read_16b_data |= ctx->data_in;
        } else { // High byte
          ctx->read_16b_data |= (ctx->data_in << 8);
        }
      }
      ctx->read_16b_sub_idx++;
      if (ctx->read_16b_sub_idx >= 4) {
        ctx->state = READ_SPI_DOMAIN_16B_END;
      } else {
        ctx->state = READ_SPI_DOMAIN_16B_PREPARE;
      }
      break;

    case READ_SPI_DOMAIN_16B_END:
      ctx->signal_state.sck = 0;
      ctx->signal_state.csb = 1;
      ctx->signal_state.mosi = 0;
      ctx->state = IDLE;
      {
        std::lock_guard<std::mutex> lock(result_mutex);
        result_queue.push({(uint64_t)ctx->read_16b_data, 1});
      }
      break;
    default:
      abort();
  }
}

void spi_dpi_tick(struct SpiDpiFsmState* ctx, unsigned char* sck, unsigned char* csb, unsigned char* mosi,
                  unsigned char miso) {

  // Only check for new commands if we are idle.
  if (ctx->state == IDLE) {
    ctx->signal_state = {0, 1, 0}; // Default idle state

    std::lock_guard<std::mutex> lock(cmd_mutex);
    if (!cmd_queue.empty()) {
      ctx->current_cmd = cmd_queue.front();
      cmd_queue.pop();

      switch (ctx->current_cmd.header.type) {
        case CommandType::WRITE_REG:
          ctx->state = WRITE_REG_CMD_START;
          ctx->is_polling = false;
          break;
        case CommandType::POLL_REG:
          ctx->state = POLL_REG_START;
          ctx->is_polling = true;
          ctx->poll_count = ctx->current_cmd.header.count; // Use for max_polls
          break;
        case CommandType::BULK_READ:
          ctx->state = BULK_READ_START;
          ctx->bulk_data_idx = 0;
          ctx->bulk_data_buffer.clear();
          if (ctx->current_cmd.header.count > 0) {
            ctx->bulk_data_buffer.resize(ctx->current_cmd.header.count);
          }
          break;
        case CommandType::IDLE_CLOCKING:
          if (ctx->current_cmd.header.count > 0) {
            ctx->state = IDLE_TICKING;
            ctx->cycle_wait_count = ctx->current_cmd.header.count * 2;
          } else {
            // If 0 cycles, just send ack immediately.
            std::lock_guard<std::mutex> lock(result_mutex);
            result_queue.push({0, 1});
          }
          break;
        case CommandType::PACKED_WRITE:
          ctx->state = PACKED_WRITE_START;
          ctx->packed_write_stage = ADDRESS_STAGE;
          ctx->packed_write_sub_idx = 0;
          break;
        case CommandType::READ_SPI_DOMAIN_REG:
          ctx->state = READ_SPI_DOMAIN_START;
          break;
        case CommandType::WRITE_REG_16B:
          ctx->state = WRITE_REG_16B_START;
          ctx->write_16b_sub_idx = 0;
          break;
        case CommandType::READ_SPI_DOMAIN_REG_16B:
          ctx->state = READ_SPI_DOMAIN_16B_START;
          break;
        // Other commands will be added back later.
        default:
          // For now, just acknowledge other commands immediately.
          {
            std::lock_guard<std::mutex> lock(result_mutex);
            result_queue.push({0, 1});
          }
          ctx->state = IDLE;
          break;
      }
    }
  }

  // --- Main State Machine ---
  switch (ctx->state) {
    case IDLE:
      // Do nothing, wait for commands.
      break;

    case WRITE_REG_CMD_START:
    case WRITE_REG_CMD_WAIT_SETUP:
    case WRITE_REG_CMD_SHIFT:
    case WRITE_REG_CMD_END:
    case WRITE_REG_CMD_EXTRA_CLOCKS:
    case WRITE_REG_DATA_START:
    case WRITE_REG_DATA_WAIT_SETUP:
    case WRITE_REG_DATA_SHIFT:
    case WRITE_REG_DATA_END:
    case WRITE_REG_DATA_EXTRA_CLOCKS:
      handle_write_reg(miso, ctx);
      break;

    case POLL_REG_START:
    case POLL_REG_CHECK:
    case POLL_REG_TXN_START:
    case POLL_REG_TXN_WAIT_SETUP:
    case POLL_REG_TXN_SHIFT:
    case POLL_REG_TXN_END:
    case POLL_REG_TXN_WAIT:
      handle_poll_reg(miso, ctx);
      break;

    case READ_SPI_DOMAIN_START:
    case READ_SPI_DOMAIN_SHIFT_CMD:
    case READ_SPI_DOMAIN_SHIFT_DATA:
    case READ_SPI_DOMAIN_END:
      handle_read_spi_domain_reg(miso, ctx);
      break;

    case WRITE_REG_16B_START:
    case WRITE_REG_16B_WAIT_SETUP:
    case WRITE_REG_16B_SHIFT:
    case WRITE_REG_16B_END_BYTE:
    case WRITE_REG_16B_END:
      handle_write_reg_16b(miso, ctx);
      break;

    case READ_SPI_DOMAIN_16B_START:
    case READ_SPI_DOMAIN_16B_PREPARE:
    case READ_SPI_DOMAIN_16B_SHIFT:
    case READ_SPI_DOMAIN_16B_END_BYTE:
    case READ_SPI_DOMAIN_16B_END:
      handle_read_spi_domain_reg_16b(miso, ctx);
      break;

    case BULK_READ_START:
    case BULK_READ_SHIFT_CMD_L:
    case BULK_READ_SHIFT_LEN_L:
    case BULK_READ_SHIFT_CMD_H:
    case BULK_READ_SHIFT_LEN_H:
    case BULK_READ_SHIFT_FLUSH:
    case BULK_READ_SHIFT_DATA:
    case BULK_READ_END:
      handle_bulk_read(miso, ctx);
      break;

    case IDLE_TICKING:
      handle_idle_clocking(miso, ctx);
      break;

    case PACKED_WRITE_START:
    case PACKED_WRITE_WAIT_SETUP:
    case PACKED_WRITE_SHIFT:
    case PACKED_WRITE_END_BYTE:
    case PACKED_WRITE_END:
      handle_packed_write(miso, ctx);
      break;
  }

  // Update the output pointers
  *sck = ctx->signal_state.sck;
  *csb = ctx->signal_state.csb;
  *mosi = ctx->signal_state.mosi;
}

}  // extern "C"