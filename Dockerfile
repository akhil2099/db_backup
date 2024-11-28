# Use an official Ubuntu or any other base image
FROM ubuntu:latest

# Set the working directory inside the container (optional)
WORKDIR /app

# Copy the contents of your repo into the Docker container
COPY . .

# Optionally, you can run a command like an entrypoint or leave it as is.
CMD ["echo", "Docker image built successfully with repo contents."]
