#!/bin/sh
set -e
echo "Adding MDEMG APT repository..."
curl -fsSL https://reh3376.github.io/apt-mdemg/mdemg-archive-keyring.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/mdemg-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/mdemg-archive-keyring.gpg] https://reh3376.github.io/apt-mdemg stable main" | \
  sudo tee /etc/apt/sources.list.d/mdemg.list > /dev/null
sudo apt update
echo ""
echo "MDEMG APT repository added! Install with:"
echo "  sudo apt install mdemg"
