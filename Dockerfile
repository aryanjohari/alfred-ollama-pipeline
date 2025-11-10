# Start from the official Ollama image.
FROM ollama/ollama

# 1. Copying the custom personality for alfred into the container.
COPY Modelfile /Modelfile

# 2. Pulling the quantized base model.
RUN ollama pull phi-3:mini-q4_K_M

# 3. "Baking" the personality to create a new model inside the container named 'alfred-brain'.
RUN ollama create alfred-brain -f /Modelfile

# Setting up the "adapter" to let lambda run Ollama
COPY --from=awsguru/aws-lambda-adapter:0.8.3 /lambda-adapter /opt/extensions/lambda-adapter

# Setting the host to be reachable and start the server
ENV OLLAMA_HOST 0.0.0.0
CMD ["/bin/sh", "-c", "/opt/extensions/lambda-adapter /usr/bin/ollama serve"]
