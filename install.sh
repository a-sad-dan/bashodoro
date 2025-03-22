#!/bin/bash

set -euo pipefail

INSTALL_DIR="/usr/local/bashodoro"
BIN_PATH="/usr/local/bin/bashodoro"

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Installing Bashodoro...${NC}"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Error: Please run as root (use sudo).${NC}"
  exit 1
fi

# Remove any existing installation
if [[ -d "$INSTALL_DIR" ]]; then
  echo -e "${YELLOW}Removing old installation...${NC}"
  rm -rf "$INSTALL_DIR"
fi

# Copy files to the install directory
echo -e "${YELLOW}Copying files to $INSTALL_DIR...${NC}"
mkdir -p "$INSTALL_DIR"
cp -r . "$INSTALL_DIR"

# Ensure scripts are executable
chmod +x "$INSTALL_DIR/bashodoro.sh"
chmod -R +x "$INSTALL_DIR/bin"/*.sh

# Change owner to the original invoking user
if [[ -n "${SUDO_USER:-}" ]]; then 
  chown -R "$SUDO_USER:$(id -gn "$SUDO_USER")" "$INSTALL_DIR" # <-- fixed bug for different group name then username 
else
  echo -e "${RED}Warning: SUDO_USER not set, skipping ownership change.${NC}"
fi

# Create a symlink for easy access
if [[ -L "$BIN_PATH" || -f "$BIN_PATH" ]]; then
  rm -f "$BIN_PATH"
fi
ln -s "$INSTALL_DIR/bashodoro.sh" "$BIN_PATH"

echo -e "${GREEN}Installation complete! Run 'bashodoro' to start.${NC}"
exit 0
