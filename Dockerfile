# Start from the official Ollama image.
FROM ollama/ollama

# 1. Copying the custom personality for alfred into the container.
COPY Modelfile /Modelfile

# 2. Start the Ollama server first in the background so it can pull the models.
RUN ollama serve & \
  # Wait for some seconds for the server to be ready
  sleep 5 && \
  # Pull the quantized base model
  ollama pull phi-3:mini-q4_K_M && \
  # Bake the personality. This creates a new model named 'alfred-brain'.
  ollama create alfred-brain -f /Modelfile && \
  # Stop the background server as it will be restarted by CMD
  kill $(pgrep ollama)

# Setting up the "adapter" to let lambda run Ollama
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter

# Setting the host to be reachable and start the server
ENV OLLAMA_HOST 0.0.0.0
CMD ["/bin/sh", "-c", "/opt/extensions/lambda-adapter /usr/bin/ollama serve"]
