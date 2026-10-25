# ultrastar-deluxe (nespi)

This package adds the UltraStar Deluxe karaoke game to Batocera as a port. It came from the
standalone karaoke-project Buildroot image, which has since been retired. The song downloader
(USDB search and download) still lives in the karaoke-project repo.

## Why a pre-built binary

USDX is written in Pascal, and Buildroot has no Free Pascal (FPC) package. FPC needs FPC to
build itself, so adding it means maintaining a bootstrap compiler. Instead, USDX is compiled
natively on ARM64 Debian, and this package only installs the result plus its runtime libraries.

## Building the binary

`binaries/usdx-arm64-<version>.tar.gz` is gitignored. To regenerate it:

1. `scripts/setup-lima-vm.sh` creates the `lima-karaoke` Debian ARM64 VM (no emulation).
2. Run `scripts/build-usdx-binary.sh` inside that VM. It writes
   `~/karaoke/usdx-arm64-<version>.tar.gz` and prints the `limactl copy` command that copies it
   into `binaries/`.

Keep `ULTRASTAR_DELUXE_VERSION` in `ultrastar-deluxe.mk` in step with `USDX_VERSION` in the
script.

## Songs

Songs go under `/userdata/roms/ultrastar-deluxe/songs/`. On the device, `manage-songs` (from
`manage-songs.sh`) sets up that directory and imports song folders from USB
(`manage-songs auto-import`). It doesn't download anything. To get new songs, use karaoke-project's
`manage-songs.sh download` on a computer, then copy the folders over.
