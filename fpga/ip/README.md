# Generating the Ibex Core

This document describes the process for generating the custom `rv_core_ibex` IP block for the Kelvin SoC.

The IP is generated using the `ipgen.py` script from the OpenTitan repository. This script takes an IP template and a configuration file as input and generates a concrete IP block in an output directory.

## Generation Command

To generate the `rv_core_ibex` IP, run the following command from the root of the repository:

```bash
python3 opentitan/util/ipgen.py generate \
    -C opentitan/hw/ip_templates/rv_core_ibex \
    -c fpga/ip/kelvin_rv_core_ibex.ipconfig.hjson \
    -o fpga/ip/rv_core_ibex \
    --force
```

## Dependencies

The `ipgen.py` script has several Python dependencies that must be installed:

*   `hjson`
*   `mako`
*   `semantic_version`
*   `tabulate`
*   `pycryptodome`

## Output

The script will generate the `rv_core_ibex` IP block in the `fpga/ip/rv_core_ibex` directory. This will include the `.core` file, the RTL files, and any other necessary files for the IP.

```