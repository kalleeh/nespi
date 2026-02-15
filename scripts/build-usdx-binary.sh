#!/bin/bash
# Build UltraStar Deluxe from source in Lima VM
# Output: ARM64 binary tarball for Batocera port package
#
# Prerequisites:
#   - Lima VM running Debian/Ubuntu on ARM64
#   - Or native ARM64 Linux (e.g., Raspberry Pi with Debian)
#
# Usage:
#   limactl shell lima-karaoke -- bash /path/to/build-usdx-binary.sh
#
# Output goes to: ~/karaoke/usdx-arm64-<version>.tar.gz
# Copy that tarball to:
#   package/batocera/ports/ultrastar-deluxe/binaries/

set -e

USDX_VERSION="2025.12.1"
WORK_DIR="$HOME/karaoke"
INSTALL_DIR="$WORK_DIR/usdx-install"
OUTPUT_TARBALL="$WORK_DIR/usdx-arm64-${USDX_VERSION}.tar.gz"

echo "=== Building UltraStar Deluxe ${USDX_VERSION} from source ==="

# Install build dependencies
echo "--- Installing build dependencies ---"
sudo apt-get update
sudo apt-get install -y \
    git automake make gcc fpc \
    libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
    libavformat-dev libswscale-dev \
    libsqlite3-dev libfreetype6-dev portaudio19-dev \
    libportmidi-dev liblua5.3-dev libopencv-highgui-dev

# Clone USDX
echo "--- Cloning UltraStar Deluxe ---"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

if [ ! -d "USDX" ]; then
    git clone https://github.com/UltraStar-Deluxe/USDX.git
fi

cd USDX
git fetch --tags
git checkout "v${USDX_VERSION}"

# Build
echo "--- Building ---"
./autogen.sh
./configure --prefix=/usr
make -j$(nproc)

# Install to staging directory
echo "--- Creating install package ---"
rm -rf "$INSTALL_DIR"
mkdir -p "$INSTALL_DIR"
make DESTDIR="$INSTALL_DIR" install

# Create tarball for Batocera port package
echo "--- Creating tarball ---"
cd "$WORK_DIR"
tar czf "$OUTPUT_TARBALL" -C "$INSTALL_DIR" .

echo ""
echo "=== Build complete ==="
echo "Output: $OUTPUT_TARBALL"
echo ""
echo "Next steps:"
echo "  1. Copy tarball to your nespi repo:"
echo "     limactl copy lima-karaoke:$OUTPUT_TARBALL \\"
echo "       package/batocera/ports/ultrastar-deluxe/binaries/"
echo "  2. Verify the version in ultrastar-deluxe.mk matches: ${USDX_VERSION}"
