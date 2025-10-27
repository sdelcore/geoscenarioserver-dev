# GeoScenario Development Workspace

A development environment for [GeoScenario Server](./geoscenarioserver/), an autonomous vehicle scenario simulation framework with behavior tree-based planning and real-time co-simulation support.

This workspace provides a containerized development environment for GeoScenario Server with:

- **Ubuntu 24.04 LTS** base with all system dependencies pre-installed
- **Pixi package manager** for fast, reproducible Python and ROS2 dependency management
- **GUI support** via X11 forwarding (native) or web-based VNC
- **VS Code integration** with pre-configured extensions and settings
- **ROS2 Humble** support via Robostack (managed by Pixi)

The container eliminates "works on my machine" problems and provides a consistent development environment across Linux, macOS, and Windows.

## Quick Start

### Option 1: VS Code Dev Container

1. In VScode. Press `F1` and select **"Dev Containers: Reopen in Container"**
5. Wait for container build (first time: ~5-10 minutes)
6. Once ready, open a terminal to run commands in the container

### Option 2: Docker Compose

```bash
# Build and start the container
docker compose -f docker-compose.yml up -d

# Enter the container
docker compose -f .devcontainer/docker-compose.yml exec dev bash

# Inside container: run a scenario
cd /home/ubuntu/workspace/geoscenarioserver
pixi run gss --scenario scenarios/test_scenarios/gs_intersection_greenlight.osm
```

## GUI Display Options

### X11 Forwarding

**Setup**:
```bash
# Allow Docker to connect to X server (run on host)
xhost +local:docker

# Verify DISPLAY is set
echo $DISPLAY  # Should show something like :0 or :1
```

**Test X11**:
```bash
# Inside container
xeyes  # Should show a pair of eyes following your cursor
```

### Web-based VNC

**Recommended when X11 is unavailable**.

**Access**:
1. Start the container (VNC server starts automatically if no X11 detected)
2. Open browser to http://localhost:6080/vnc.html
3. Password: `dev`
4. GUI applications will appear in the browser window

**Manual VNC Control**:
```bash
# Inside container: start VNC manually
/usr/local/bin/start-vnc.sh

# Connect via VNC client (instead of web)
# Server: localhost:5901
# Password: dev
```
