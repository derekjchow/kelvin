# Build coralnpu_v2 toolchain in Rock linux

The following instructions describe how to build and export a toolchain for coralnpu_v2

## Build and run docker image

```sh
$ docker build --no-cache -t toolchain_test -f toolchain_rockylinux_image.dockerfile .
```
open toolchain_test container in interactive mode and mount current directory
```sh
$ docker run -v `pwd`:/toolchain/build_scripts -w /toolchain/build_scripts toolchain_test bash coralnpu_v2_toolchain_build.sh
```

Output toolchain artifacts will be exported to rv32_out