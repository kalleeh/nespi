################################################################################
#
# ultrastar-deluxe (pre-built binary)
#
################################################################################

ULTRASTAR_DELUXE_VERSION = 2025.12.1
ULTRASTAR_DELUXE_SITE = $(BR2_EXTERNAL_BATOCERA_PATH)/package/batocera/ports/ultrastar-deluxe/binaries
ULTRASTAR_DELUXE_SOURCE = usdx-arm64-$(ULTRASTAR_DELUXE_VERSION).tar.gz
ULTRASTAR_DELUXE_SITE_METHOD = file
ULTRASTAR_DELUXE_LICENSE = GPL-2.0
ULTRASTAR_DELUXE_EMULATOR_INFO = ultrastar-deluxe.emulator.yml

# Runtime dependencies only (no build deps needed - pre-built binary)
ULTRASTAR_DELUXE_DEPENDENCIES = \
	sdl2 \
	sdl2_image \
	sdl2_mixer \
	sdl2_ttf \
	ffmpeg \
	portaudio \
	sqlite \
	freetype \
	lua

define ULTRASTAR_DELUXE_EXTRACT_CMDS
	tar xzf $(ULTRASTAR_DELUXE_DL_DIR)/$(ULTRASTAR_DELUXE_SOURCE) -C $(@D)
endef

define ULTRASTAR_DELUXE_BUILD_CMDS
	# Nothing to build - using pre-built binary
endef

define ULTRASTAR_DELUXE_INSTALL_TARGET_CMDS
	# Install pre-built binary and assets
	cp -a $(@D)/* $(TARGET_DIR)/

	# Create song directories in userdata (Batocera convention)
	mkdir -p $(TARGET_DIR)/usr/share/batocera/datainit/roms/ultrastar-deluxe
	mkdir -p $(TARGET_DIR)/usr/share/batocera/datainit/roms/ultrastar-deluxe/songs

	# Install song management script
	$(INSTALL) -D -m 0755 $(ULTRASTAR_DELUXE_PKGDIR)/manage-songs.sh \
		$(TARGET_DIR)/usr/bin/manage-songs
endef

$(eval $(generic-package))
$(eval $(emulator-info-package))
