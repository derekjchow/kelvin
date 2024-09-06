#!/usr/bin/python3
#
# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import grpc
import tests.renode.kelvin_pb2 as kelvin_pb2
import tests.renode.kelvin_pb2_grpc as kelvin_pb2_grpc

import sys

def main():
    if len(sys.argv) < 3:
        print('Usage: {} receiverPort senderPort [address]'.format(sys.argv[0]))
        return -1
    address = sys.argv[3] if len(sys.argv) > 3 else "127.0.0.1"
    receiverPort = int(sys.argv[1])
    senderPort = int(sys.argv[2])
    agent_type = kelvin_pb2.AgentType.Master if "master" in sys.argv[0] else kelvin_pb2.AgentType.Slave

    with grpc.insecure_channel("127.0.0.1:9003") as channel:
        stub = kelvin_pb2_grpc.KelvinStub(channel)
        response = stub.StartAgent(kelvin_pb2.StartAgentRequest(
            type=agent_type,
            receiverPort=receiverPort,
            senderPort=senderPort,
            address=address,
        ))
    return 0

if __name__ == '__main__':
    sys.exit(main())