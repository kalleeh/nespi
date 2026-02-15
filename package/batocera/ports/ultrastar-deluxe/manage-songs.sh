#!/bin/bash
# UltraStar Deluxe Song Management Script (Batocera)
# Handles song directories under /userdata/roms/ultrastar-deluxe/

set -euo pipefail

SONGS_DIR="/userdata/roms/ultrastar-deluxe/songs"
USB_MOUNT_DIR="/media/usb-songs"
CONFIG_DIR="/userdata/system/configs/ultrastar-deluxe"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log()     { echo -e "${BLUE}[SONG-MGR]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
error()   { echo -e "${RED}[ERROR]${NC} $1"; }

setup_directories() {
    log "Setting up song directories..."
    mkdir -p "$SONGS_DIR"
    mkdir -p "$CONFIG_DIR"
    success "Song directories ready"
}

import_usb_songs() {
    log "Checking for USB songs..."

    if [[ ! -d "$USB_MOUNT_DIR" ]] || [[ -z "$(ls -A "$USB_MOUNT_DIR" 2>/dev/null)" ]]; then
        warning "No USB songs found in $USB_MOUNT_DIR"
        return 0
    fi

    log "Importing songs from USB..."

    for song_dir in "$USB_MOUNT_DIR"/*; do
        if [[ -d "$song_dir" ]]; then
            song_name=$(basename "$song_dir")
            log "Importing: $song_name"
            cp -r "$song_dir" "$SONGS_DIR/"
        fi
    done

    success "USB songs imported"
}

list_songs() {
    log "Songs available in UltraStar Deluxe:"

    if [[ -d "$SONGS_DIR" ]] && [[ -n "$(ls -A "$SONGS_DIR" 2>/dev/null)" ]]; then
        for song_dir in "$SONGS_DIR"/*; do
            if [[ -d "$song_dir" ]]; then
                echo "  - $(basename "$song_dir")"
            fi
        done
    else
        warning "No songs found"
        log "Place songs in: $SONGS_DIR"
    fi
}

auto_mount_usb() {
    log "Auto-detecting USB drives..."

    for device in /dev/sd*1; do
        if [[ -b "$device" ]]; then
            log "Found USB device: $device"
            mkdir -p "$USB_MOUNT_DIR"
            if mount "$device" "$USB_MOUNT_DIR" 2>/dev/null; then
                success "Mounted $device to $USB_MOUNT_DIR"
                return 0
            fi
        fi
    done

    warning "No mountable USB drives found"
    return 1
}

count_songs() {
    if [[ -d "$SONGS_DIR" ]]; then
        local count=0
        for d in "$SONGS_DIR"/*/; do
            [[ -d "$d" ]] && count=$((count + 1))
        done
        echo "$count songs in library"
    else
        echo "0 songs in library"
    fi
}

main() {
    case "${1:-help}" in
        setup)
            setup_directories
            ;;
        import)
            setup_directories
            import_usb_songs
            ;;
        list)
            list_songs
            ;;
        auto-mount)
            auto_mount_usb
            ;;
        auto-import)
            setup_directories
            if auto_mount_usb; then
                import_usb_songs
                umount "$USB_MOUNT_DIR" 2>/dev/null || true
            fi
            ;;
        count)
            count_songs
            ;;
        help|*)
            echo "UltraStar Deluxe Song Management (Batocera)"
            echo ""
            echo "Usage: $0 {setup|import|list|auto-mount|auto-import|count|help}"
            echo ""
            echo "Commands:"
            echo "  setup       - Create song directories"
            echo "  import      - Import songs from USB"
            echo "  list        - List available songs"
            echo "  auto-mount  - Auto-detect and mount USB drives"
            echo "  auto-import - Auto-mount USB and import songs"
            echo "  count       - Count songs in library"
            echo "  help        - Show this help"
            echo ""
            echo "Songs directory: $SONGS_DIR"
            ;;
    esac
}

main "$@"
