#---
# name: open3d
# alias: open3d
# group: cv
# config: config.py
# depends: [opencv]
# test: [test.py]
#---
ARG BASE_IMAGE
FROM ${BASE_IMAGE}

: "${OPEN3D_VERSION:?OPEN3D_VERSION must be set}"
: "${PIP_WHEEL_DIR:?PIP_WHEEL_DIR must be set}"

ARG OPEN3D_VERSION \
    TMP_DIR=/tmp/open3d \
    FORCE_BUILD=off

REPO_URL="https://github.com/johnnynunez/Open3D"
REPO_DIR="/opt/open3d"

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    lsb-release \
    pkg-config \
    gnupg \
    git \
    git-lfs \
    gdb \
    wget \
    wget2 \
    curl \
    nano \
    zip \
    unzip \
    time \
    sshpass \
    ssh-client \
    ninja-build \
    gfortran \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    build-essential \
    cmake \
    git \
    gdb \
    libeigen3-dev \
    libgl1-mesa-dev \
    libglew-dev \
    libglfw3-dev \
    libosmesa6-dev \
    libpng-dev \
    lxde \
    mesa-utils \
    x11vnc \
    xorg-dev \
    xterm \
    xvfb \
    ne \
    llvm-14 \
    clang-14 \
    libc++-14-dev \
    lld \
    libc++abi-14-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV SUDO=command
#COPY build.sh install.sh "${TMP_DIR}"/
#RUN "${TMP_DIR}"/install.sh || "${TMP_DIR}"/build.sh || touch "${TMP_DIR}"/.build.failed

if git clone --recursive --depth 1 --branch "v${OPEN3D_VERSION}" \
    "${REPO_URL}" "${REPO_DIR}"
then
  echo "Cloned v${OPEN3D_VERSION}"
else
  echo "Tagged branch not found; cloning default branch"
  git clone --recursive --depth 1 "${REPO_URL}" "${REPO_DIR}"
fi

# ---- Environment variables ---------------------------------------------------
# 1) XDG_SESSION_TYPE                       (forces X11 inside the container)
ENV XDG_SESSION_TYPE=x11

cd "${REPO_DIR}" || exit 1

# ./util/install_deps_ubuntu.sh assume-yes
mkdir build
cd build

ln -sfnv /usr/lib/llvm-14/lib/libc++.so.1.0 /usr/lib/llvm-14/lib/libc++.so.1

pip3 install -U wheel setuptools
cmake -DCMAKE_C_COMPILER=clang-14 \
      -DCMAKE_CXX_COMPILER=clang++-14 \
      -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld-14 -L/usr/lib/gcc/aarch64-linux-gnu/13" \
      -DCMAKE_SHARED_LINKER_FLAGS="-fuse-ld=lld-14 -L/usr/lib/gcc/aarch64-linux-gnu/13" \
      -DBUILD_SHARED_LIBS=ON \
      -DUSE_SYSTEM_OPENSSL=ON \
      -DUSE_SYSTEM_CURL=ON \
      -DUSE_SYSTEM_OPENSSL=ON \
      -DUSE_SYSTEM_CURL=ON \
      -DCMAKE_BUILD_TYPE=Release \
      -DBUILD_PYTHON_MODULE=ON \
      -DBUILD_CUDA_MODULE=ON \
      -DBUILD_PYTORCH_OPS=OFF \
      -DBUILD_TENSORFLOW_OPS=OFF \
      ..

# -DBUNDLE_OPEN3D_ML=ON \
# -DOPEN3D_ML_ROOT=https://github.com/isl-org/Open3D-ML.git \
export MAX_JOBS="$(nproc)"
export CMAKE_BUILD_PARALLEL_LEVEL=$MAX_JOBS

make -j$(nproc)
make pip-package -j$(nproc)
cd "${REPO_DIR}" || exit 1
cp build/lib/python_package/pip_package/*.whl /opt/open3d/
pip3 install /opt/open3d/open3d*.whl

# 2) LD_PRELOAD — combine both libraries in *one* variable (colon-separated)
#    – first: libgomp (OpenMP, shipped by libgomp1)
#    – second: libOpen3D.so from the venv you just created
# ENV LD_PRELOAD="/usr/lib/aarch64-linux-gnu/libgomp.so.1:/opt/venv/lib/python${PYTHON_VERSION}/site-packages/open3d/cpu/libOpen3D.so.0.19"
