# Use the JAX container as your base
#FROM dustynv/jax:0.5.2-r36.4.0-cu128-24.04
FROM ae_jax062_opencv:r36.4.tegra-aarch64-cu126-22.04

# Install JAX for Jetson (ARM64). Use NVIDIA's index for compatibility.
#RUN pip3 install --upgrade pip
#RUN apt-get update && apt-get install -y \
#    libopencv-dev \
#    python3-opencv \
#    && rm -rf /var/lib/apt/lists/*

RUN pip3 install elements portal chex ninjax einops optax scope
#RUN cd ai2_thor_model_training_src
# git clone ... https://github.com/archie1983/hpc_dreamer3
RUN git clone -b remote_env_branch "https://github.com/archie1983/ai2-thor_model_training" ai2_thor_model_training_src
WORKDIR ai2_thor_model_training_src
RUN pip install -e .
RUN cd ../
# Crucial for JAX on Jetson/ARM Unified Memory
ENV XLA_PYTHON_CLIENT_PREALLOCATE=false
ENV XLA_PYTHON_CLIENT_MEM_FRACTION=0.25

#LLVM_VERSION="20" jetson-containers build llvm --name llvm20_ae
#JAX_BUILD_VERSION="0.6.3" jetson-containers build jax --base llvm20_ae:r36.4.tegra-aarch64-cu126-22.04
#jetson-containers build opencv --base jax:r36.4.tegra-aarch64-cu126-22.04 --name ae_jax062_opencv
##jetson-containers build l4t-jax --name ae_d3
