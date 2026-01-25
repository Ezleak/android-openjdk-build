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
export CFLAGS=" -fno-rtti -Xclang "-target-feature" -Xclang "+v8.2a" -Xclang "-target-feature" -Xclang "+crc" -Xclang "-target-feature" -Xclang "+fp-armv8" -Xclang "-target-feature" -Xclang "+lse" -Xclang "-target-feature" -Xclang "+neon" -Xclang "-target-feature" -Xclang "+ras" -Xclang "-target-feature" -Xclang "+rdm" -Xclang "-target-feature" -Xclang "+fix-cortex-a53-835769" -Xclang "-target-feature" -Xclang "+fp" -Xclang "-target-feature" -Xclang "+simd" -Xclang "-target-abi" -Xclang "aapcs" -mtune=cortex-a76 -mcpu=cortex-a76"
export CFLAGS+=" -O3 -flto=thin -fno-emulated-tls -fwhole-program-vtables -fdata-sections -ffunction-sections -fmerge-all-constants -mllvm -hot-cold-split=true -ftree-vectorize -fomit-frame-pointer -fno-semantic-interposition -integrated-as"
export CFLAGS+=" -ffast-math -fno-finite-math-only -fno-signed-zeros -fno-trapping-math -fno-math-errno -freciprocal-math -fno-associative-math"
export CFLAGS+=" -fvectorize -fslp-vectorize -mllvm -polly-ast-detect-parallel -mllvm -polly-optimized-scops"
export CFLAGS+=" -mllvm -polly -mllvm -polly-vectorizer=stripmine -mllvm -polly-invariant-load-hoisting -mllvm -polly-run-inliner -mllvm -polly-run-dce -mllvm -polly-invariant-load-hoisting -mllvm -polly-run-inliner -mllvm -polly-run-dce -mllvm -polly-parallel -mllvm -polly-scheduling=dynamic -mllvm -polly-omp-backend=LLVM -fopenmp=libomp -mllvm -polly-detect-keep-going -mllvm -polly-ast-use-context"
export CFLAGS+=" -DANDROID -D__ANDROID__=1 -pipe -integrated-as -DLE_STANDALONE -Wno-int-conversion -Wno-error=implicit-function-declaration"
export LDFLAGS+=" -fuse-ld=lld -Wl,-plugin-opt=-emulated-tls=0 -Wl,--strip-all -fvisibility=hidden -Wl,-Bsymbolic -Wl,-O3 -Wl,--sort-common -Wl,--relax -Wl,--gc-sections -Wl,--as-needed -Wl,--lto-O3 -Wl,-plugin-opt=-emulated-tls=0"
export LDFLAGS+=" -flto=thin -O3 -fopenmp -l:libomp.a"

export CXXFLAGS="$CFLAGS"
make -j4
make install
