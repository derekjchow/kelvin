# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

def _check_folder_impl(rctx):
    root_file_path = rctx.path(rctx.attr.root_file)
    workspace_root = root_file_path.dirname
    folder = workspace_root.get_child(rctx.attr.directory)
    folder_exists = folder.exists

    bzl_content = "FOLDER_EXISTS = %s\n" % folder_exists
    rctx.file(
        "status.bzl",
        content = bzl_content,
    )
    rctx.file(
        "BUILD.bazel",
        content = """
exports_files(["status.bzl"])
""",
    )

check_folder = repository_rule(
    implementation = _check_folder_impl,
    local = True,
    attrs = {
        "directory": attr.string(mandatory = True),
        "root_file": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
    }
)