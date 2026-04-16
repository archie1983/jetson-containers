# Use the Pytorch 2.7 container as our base
FROM dustynv/pytorch:2.7-r36.4.0-cu128-24.04

RUN apt-get update && apt-get install -y libsndfile1
RUN pip install --index-url "https://pypi.jetson-ai-lab.io/jp6/cu128" transformers
RUN git clone https://github.com/archie1983/ae_path_compare
WORKDIR ae_path_compare/
RUN pip install --index-url "https://pypi.jetson-ai-lab.io/jp6/cu128" -e .
RUN cd ../

#LLVM_VERSION="20" jetson-containers build llvm --name llvm20_ae
#JAX_BUILD_VERSION="0.6.3" jetson-containers build jax --base llvm20_ae:r36.4.tegra-aarch64-cu126-22.04
#jetson-containers build opencv --base jax:r36.4.tegra-aarch64-cu126-22.04 --name ae_jax062_opencv
##jetson-containers build l4t-jax --name ae_d3
