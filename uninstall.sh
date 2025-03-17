#!/bin/bash

set -euo pipefail

INSTALL_DIR="/usr/local/bashodoro"
BIN_PATH="/usr/local/bin/bashodoro"

# ANSI colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Uninstalling Bashodoro...${NC}"

# Ensure script is run as root
if [[ $EUID -ne 0 ]]; then
  echo -e "${RED}Error: Please run as root (use sudo).${NC}"
  exit 1
fi

# Remove installation directory
if [[ -d "$INSTALL_DIR" ]]; then
  echo -e "${YELLOW}Removing installation directory: $INSTALL_DIR${NC}"
  rm -rf "$INSTALL_DIR"
else
  echo -e "${GREEN}No existing installation found at $INSTALL_DIR${NC}"
fi

# Remove symlink
if [[ -L "$BIN_PATH" ]]; then
  echo -e "${YELLOW}Removing symlink: $BIN_PATH${NC}"
  rm "$BIN_PATH"
else
  echo -e "${GREEN}No symlink found at $BIN_PATH${NC}"
fi

echo -e "${GREEN}Bashodoro uninstalled successfully.${NC}"
exit 0
