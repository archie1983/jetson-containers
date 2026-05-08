FROM ae_path_compare_img

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install OpenCV via pip (pre-built wheels available for Jetson)
RUN pip install --no-cache-dir \
    opencv-python==4.10.0.84 \
    opencv-contrib-python==4.10.0.84
