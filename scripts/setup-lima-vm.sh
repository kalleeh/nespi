#!/bin/bash
# Setup Lima VM for building UltraStar Deluxe ARM64 binary
#
# This creates a Debian-based Lima VM that can compile USDX
# using Free Pascal. The VM runs natively on Apple Silicon
# (ARM64-to-ARM64, no emulation).
#
# Prerequisites:
#   brew install lima
#
# Usage:
#   ./scripts/setup-lima-vm.sh

set -e

VM_NAME="lima-karaoke"

echo "=== Setting up Lima VM for USDX builds ==="

# Check if Lima is installed
if ! command -v limactl &> /dev/null; then
    echo "Error: lima not installed. Run: brew install lima"
    exit 1
fi

# Check if VM already exists
if limactl list | grep -q "$VM_NAME"; then
    echo "VM '$VM_NAME' already exists."
    echo "  Start:   limactl start $VM_NAME"
    echo "  Shell:   limactl shell $VM_NAME"
    echo "  Delete:  limactl delete $VM_NAME"
    exit 0
fi

# Create VM with Debian
echo "--- Creating Lima VM ---"
limactl create --name="$VM_NAME" template://debian

echo "--- Starting VM ---"
limactl start "$VM_NAME"

echo "--- Installing build tools ---"
limactl shell "$VM_NAME" -- bash -c '
    sudo apt-get update
    sudo apt-get install -y \
        git automake make gcc fpc \
        libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev \
        libavformat-dev libswscale-dev \
        libsqlite3-dev libfreetype6-dev portaudio19-dev \
        libportmidi-dev liblua5.3-dev libopencv-highgui-dev

    # Create tar wrapper with --no-same-owner (needed for buildroot)
    mkdir -p ~/bin
    cat > ~/bin/tar << '\''TAREOF'\''
#!/bin/bash
exec /usr/bin/tar --no-same-owner "$@"
TAREOF
    chmod +x ~/bin/tar
    echo "export PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
'

echo ""
echo "=== Lima VM ready ==="
echo ""
echo "Build USDX:"
echo "  limactl shell $VM_NAME -- bash /path/to/nespi/scripts/build-usdx-binary.sh"
echo ""
echo "Copy result:"
echo "  limactl copy ${VM_NAME}:~/karaoke/usdx-arm64-*.tar.gz \\"
echo "    package/batocera/ports/ultrastar-deluxe/binaries/"
