// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

package top_racl_pkg;
  import tlul_pkg::*;

  // This is a placeholder file.
  // Toplevel RAC-L constants for the CoralNPU SoC will be added here.
  parameter int unsigned NrRaclPolicies = 1;

  // RACL Policy selector bits
  parameter int unsigned RaclPolicySelLen =
                             prim_util_pkg::vbits(NrRaclPolicies);

  // Number of RACL bits transferred
  parameter int unsigned NrRaclBits = 1;

  // Number of CTN UID bits transferred
  parameter int unsigned NrCtnUidBits = 1;
  // CTN UID assigned the bus originator
  typedef logic[NrCtnUidBits - 1 : 0] ctn_uid_t;

  // RACL Policy selector type
  typedef logic[RaclPolicySelLen - 1 : 0] racl_policy_sel_t;

  // RACL role type binary encoded
  typedef logic[NrRaclBits - 1 : 0] racl_role_t;
  // RACL permission: A one-hot encoded role vector
  typedef logic[(2 ** NrRaclBits) - 1 : 0] racl_role_vec_t;

  // RACL policy containing a read and write permission
  typedef struct packed {
    racl_role_vec_t write_perm;  // Write permission (upper bits)
    racl_role_vec_t read_perm;   // Read permission (lower bits)
  } racl_policy_t;
  typedef racl_policy_t[NrRaclPolicies - 1 : 0] racl_policy_vec_t;

  // RACL information logged in case of a denial
  typedef struct packed {
    logic valid;     // Error information is valid
    logic overflow;  // Error overflow, More than 1 RACL error at a time
    racl_role_t racl_role;
    ctn_uid_t ctn_uid;
    logic read_access;  // 0: Write access, 1: Read access
    logic [top_pkg::TL_AW - 1 : 0] request_address;
  } racl_error_log_t;

  // RACL range used to protect a range of addresses with a RACL policy (e.g.,
  // for sram).
  typedef struct packed {
    logic [top_pkg::TL_AW - 1 : 0] base;   // Start address of range
    logic [top_pkg::TL_AW - 1 : 0] limit;  // End address of range (inclusive)
    racl_policy_sel_t policy_sel;          // Policy selector
    logic enable;  // 0: Range is disabled, 1: Range is enabled
  } racl_range_t;

  function automatic racl_role_t tlul_extract_racl_role_bits
      (logic [tlul_pkg::RsvdWidth - 1 : 0] rsvd);
    // Waive unused bits
    logic unused_rsvd_bits;
    unused_rsvd_bits = ^{
      rsvd
    };

    return racl_role_t'(rsvd[0 : 0]);
  endfunction

  function automatic ctn_uid_t tlul_extract_ctn_uid_bits
      (logic [tlul_pkg::RsvdWidth - 1 : 0] rsvd);
    // Waive unused bits
    logic unused_rsvd_bits;
    unused_rsvd_bits = ^{
      rsvd
    };

    return ctn_uid_t'(rsvd[0 : 0]);
  endfunction
endpackage
