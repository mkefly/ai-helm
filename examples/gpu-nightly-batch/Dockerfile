FROM nvidia/cuda:12.1.0-runtime-ubuntu22.04

WORKDIR /app

# Install Python and pip
RUN apt-get update && apt-get install -y python3 python3-pip && rm -rf /var/lib/apt/lists/*

# Install GPU-enabled torch (example version; adjust to your cluster)
RUN pip3 install --no-cache-dir torch --index-url https://download.pytorch.org/whl/cu121

COPY run_batch.py .

# Default command: run the batch script once
CMD ["python3", "run_batch.py"]
