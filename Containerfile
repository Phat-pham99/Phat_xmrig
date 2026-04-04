# ==========================================
# Stage 1: Build Environment (Compile Phase)
# ==========================================
FROM ubuntu:22.04 AS builder

# Prevent interactive prompts during apt installations
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary build tools and dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory inside the container
WORKDIR /src

# Copy the local project files into the container
COPY . .

# Create build directory, configure with CMake, and compile
RUN mkdir build && cd build && \
    cmake .. && \
    make -j$(nproc)

# ==========================================
# Stage 2: Runtime Environment (Final Image)
# ==========================================
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install ONLY the required runtime libraries to keep the image small
RUN apt-get update && apt-get install -y \
    libuv1 \
    libssl3 \
    libhwloc15 \
    && rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Copy the compiled binary from the "builder" stage
COPY --from=builder /src/build/xmrig /app/xmrig

# Set the entrypoint so the container acts exactly like the executable
ENTRYPOINT ["./xmrig", " --config=./config_background_colored.json"]