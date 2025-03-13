#!/bin/bash
set -e
. setdevkitpath.sh
cd freetype-$BUILD_FREETYPE_VERSION

echo "Building Freetype"

export PATH=$TOOLCHAIN/bin:$PATH
./configure \
  --host=$TARGET \
  --prefix=${PWD}/build_android-${TARGET_SHORT} \
  LD=$TOOLCHAIN/bin/ld.lld \
  --without-zlib \
  --with-brotli=system \
  --with-png=no \
  --with-harfbuzz=no $EXTRA_ARGS \
  || error_code=$?

if [[ "$error_code" -ne 0 ]]; then
  echo "\n\nCONFIGURE ERROR $error_code , config.log:"
  cat ${PWD}/builds/unix/config.log
  exit $error_code
fi

export CFLAGS="-O3 -fno-emulated-tls -fno-rtti -Xclang "-target-feature" -Xclang "+v8.2a" -Xclang "-target-feature" -Xclang "+crc" -Xclang "-target-feature" -Xclang "+fp-armv8" -Xclang "-target-feature" -Xclang "+lse" -Xclang "-target-feature" -Xclang "+neon" -Xclang "-target-feature" -Xclang "+ras" -Xclang "-target-feature" -Xclang "+rdm" -Xclang "-target-feature" -Xclang "+fix-cortex-a53-835769" -Xclang "-target-feature" -Xclang "+fp" -Xclang "-target-feature" -Xclang "+simd" -Xclang "-target-abi" -Xclang "aapcs" -mcpu=cortex-a78"
export CFLAGS+=" -mllvm -polly -mllvm -polly-vectorizer=stripmine -mllvm -polly-invariant-load-hoisting -mllvm -polly-run-inliner -mllvm -polly-run-dce -flto=thin  -mllvm -polly-parallel -fopenmp=libomp -mllvm -polly-omp-backend=LLVM -mllvm -polly-scheduling=dynamic -fno-emulated-tls -fwhole-program-vtables -fdata-sections -ffunction-sections -fmerge-all-constants"

export CXXFLAGS="-Ofast -fno-emulated-tls -fno-rtti -Xclang "-target-feature" -Xclang "+v8.2a" -Xclang "-target-feature" -Xclang "+crc" -Xclang "-target-feature" -Xclang "+fp-armv8" -Xclang "-target-feature" -Xclang "+lse" -Xclang "-target-feature" -Xclang "+neon" -Xclang "-target-feature" -Xclang "+ras" -Xclang "-target-feature" -Xclang "+rdm" -Xclang "-target-feature" -Xclang "+fix-cortex-a53-835769" -Xclang "-target-feature" -Xclang "+fp" -Xclang "-target-feature" -Xclang "+simd" -Xclang "-target-abi" -Xclang "aapcs" -mcpu=cortex-a78"
export CXXFLAGS+="-mllvm -polly -mllvm -polly-vectorizer=stripmine -mllvm -polly-invariant-load-hoisting -mllvm -polly-run-inliner -mllvm -polly-run-dce -flto=thin  -mllvm -polly-parallel -fopenmp=libomp -mllvm -polly-omp-backend=LLVM -mllvm -polly-scheduling=dynamic -fno-emulated-tls -fwhole-program-vtables -fdata-sections -ffunction-sections -fmerge-all-constants"
make -j4
make install
