FROM ae_path_compare_img:latest

# Just install OpenCV directly - pip may handle everything
RUN pip install --index-url "https://pypi.jetson-ai-lab.io/jp6/cu128" --no-cache-dir opencv-python
