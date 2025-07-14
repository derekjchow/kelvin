#!/usr/bin/env python3

import subprocess
import os
import xml.etree.ElementTree as ET
from collections import defaultdict


def get_workspace_root():
    return subprocess.check_output(['bazel', 'info',
                                    'workspace']).decode('utf-8').strip()


def get_all_cocotb_test_suites():
    xml_output = subprocess.check_output([
        'bazel', 'query',
        'kind("cocotb_test", //...) intersect attr("tags", "verilator_cocotb_test_suite", //...)',
        '--output=xml'
    ]).decode('utf-8').strip()
    if not xml_output:
        return []
    return ET.fromstring(xml_output)


def get_test_suite_info(suite_rule):
    test_module = None
    variable_name = None

    for child in suite_rule:
        if child.tag == 'list' and child.attrib.get('name') == 'test_module':
            for label in child:
                if label.tag == 'label':
                    test_module = label.attrib.get('value')
                    break
        if child.tag == 'list' and child.attrib.get('name') == 'tags':
            for string_attr in child:
                if string_attr.tag == 'string':
                    value = string_attr.attrib.get('value', '')
                    if value.startswith("testcases_vname="):
                        variable_name = value.split("=")[1]
                        break
        if test_module and variable_name:
            break

    return test_module, variable_name


def main():
    workspace_root = get_workspace_root()
    os.chdir(workspace_root)

    all_suites_xml = get_all_cocotb_test_suites()

    if all_suites_xml is None:
        print("No cocotb test suites found.")
        return

    for suite_rule in all_suites_xml.findall('rule'):
        suite_name = suite_rule.get('name').split(':')[1]
        print(f"Processing suite: {suite_name}")

        build_file = suite_rule.get('location').split(':')[0]
        test_module_label, variable_name = get_test_suite_info(suite_rule)

        if not test_module_label or not variable_name:
            print(
                f"Warning: Could not extract 'test_module' or 'testcases_vname' from {suite_name}"
            )
            continue

        # The test_module_label is a bazel label, e.g. //tests/cocotb:core_mini_axi_sim.py
        # We need to convert it to a file path.
        test_module_path = test_module_label.replace('//',
                                                     '').replace(':', '/')

        test_file_path = os.path.join(workspace_root, test_module_path)

        print(f"Updating testcases for {suite_name}...")

        update_script_path = os.path.join(workspace_root, "utils",
                                          "update_cocotb_tests.py")
        update_command = [
            'python3',
            update_script_path,
            f'--build_file={build_file}',
            f'--test_file={test_file_path}',
            f'--variable_name={variable_name}',
            f'--name={suite_name}',
        ]

        subprocess.run(update_command, check=True)
        print(f"Successfully updated {suite_name}.")


if __name__ == '__main__':
    main()
