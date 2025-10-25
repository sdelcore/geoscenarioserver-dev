# Base image with Ubuntu 24.04 LTS
FROM ubuntu:24.04

# Set environment variables for non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install system dependencies and GUI libraries
RUN apt-get update && apt-get install -y \
    # Essential tools
    curl \
    wget \
    git \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    # Build tools
    build-essential \
    cmake \
    pkg-config \
    # X11 and GUI dependencies
    xorg \
    x11-apps \
    xvfb \
    libx11-dev \
    libxext-dev \
    libxft-dev \
    libxinerama-dev \
    libxcursor-dev \
    libxrender-dev \
    libxi-dev \
    libxrandr-dev \
    libgl1 \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    # Qt dependencies
    libqt6core6 \
    libqt6gui6 \
    libqt6widgets6 \
    qt6-base-dev \
    qt6-wayland \
    # GTK and other GUI toolkits
    libgtk-3-0 \
    libgtk-3-dev \
    # Python tk support
    python3-tk \
    # VNC server for web-based GUI
    tigervnc-standalone-server \
    tigervnc-common \
    novnc \
    websockify \
    # Window managers for VNC
    fluxbox \
    dbus-x11 \
    # Additional utilities
    locales \
    fonts-liberation \
    && rm -rf /var/lib/apt/lists/*

# Generate locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Give ubuntu user sudo privileges
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/ubuntu && \
    chmod 0440 /etc/sudoers.d/ubuntu

# Install Pixi package manager
ARG PIXI_VERSION=latest
RUN curl -fsSL https://pixi.sh/install.sh | bash \
    && mv /root/.pixi /opt/pixi \
    && ln -s /opt/pixi/bin/pixi /usr/local/bin/pixi \
    && chmod +x /usr/local/bin/pixi

# Configure VNC server
RUN mkdir -p /usr/share/desktop-directories \
    && mkdir -p ~/.vnc \
    && echo "#!/bin/sh\nunset SESSION_MANAGER\nunset DBUS_SESSION_BUS_ADDRESS\nexec fluxbox" > ~/.vnc/xstartup \
    && chmod +x ~/.vnc/xstartup \
    && echo "dev" | vncpasswd -f > ~/.vnc/passwd \
    && chmod 600 ~/.vnc/passwd

# Create startup script for VNC/noVNC
RUN echo '#!/bin/bash\n\
# Start VNC server\n\
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no\n\
# Start noVNC\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5901 &\n\
echo "noVNC server started on http://localhost:6080/vnc.html"\n\
wait\n' > /usr/local/bin/start-vnc.sh \
    && chmod +x /usr/local/bin/start-vnc.sh

# Create entrypoint script
RUN echo '#!/bin/bash\n\
# Check if DISPLAY is set for X11 forwarding\n\
if [ -n "$DISPLAY" ]; then\n\
    echo "X11 display detected: $DISPLAY"\n\
else\n\
    echo "No X11 display detected, VNC available at http://localhost:6080/vnc.html"\n\
    echo "Starting VNC server in background..."\n\
    /usr/local/bin/start-vnc.sh &\n\
    export DISPLAY=:1\n\
fi\n\
\n\
# Execute the command passed to docker run\n\
exec "$@"\n' > /usr/local/bin/entrypoint.sh \
    && chmod +x /usr/local/bin/entrypoint.sh

# Set up Pixi for the ubuntu user (do this before switching user)
RUN echo 'export PATH="/opt/pixi/bin:$PATH"' >> /home/ubuntu/.bashrc \
    && echo 'export PATH="/opt/pixi/bin:$PATH"' >> /home/ubuntu/.profile \
    && chown ubuntu:ubuntu /home/ubuntu/.bashrc /home/ubuntu/.profile

# Switch to ubuntu user
USER ubuntu
WORKDIR /home/ubuntu

# Create workspace directory
RUN mkdir -p /home/ubuntu/workspace

# Expose ports
EXPOSE 5901 6080

# Set the entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Default command
CMD ["/bin/bash"]