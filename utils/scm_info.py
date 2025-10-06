# Copyright 2024 Google LLC
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

import argparse
import sys
from pathlib import Path
from typing import Union

class VersionInformation():
    def __init__(self, path: str):
        self.version_stamp = {}
        if path is None:
            return
        try:
            with open(path, 'rt') as f:
                for line in f:
                    k, v = line.strip().split(' ', 1)
                    self.version_stamp[k] = v
        except ValueError:
            raise SystemExit(sys.exc_info()[1])

    def scm_revision(self, default: Union[str, None] = None) -> Union[str, None]:
        return self.version_stamp.get('CORALNPU_BUILD_GIT_VERSION', default)

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--outfile', '-o', required=True, type=Path, help='Output file')
    parser.add_argument('--infile', '-i', required=True, type=Path, help='Input file')
    args = parser.parse_args()

    version_info = VersionInformation(args.infile)
    scm_revision = version_info.scm_revision('f' * 40)
    tpl = f"""
package coralnpu

class ScmInfo {{
    val revision = BigInt("{scm_revision}", 16)
}}
"""

    args.outfile.parent.mkdir(parents=True, exist_ok=True)
    with args.outfile.open(mode='w', encoding='utf-8') as fout:
        fout.write(tpl)

if __name__ == '__main__':
    main()
