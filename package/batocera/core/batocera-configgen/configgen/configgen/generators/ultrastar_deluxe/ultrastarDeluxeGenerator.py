from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from ... import Command
from ..Generator import Generator

if TYPE_CHECKING:
    from ...types import HotkeysContext

SONGS_DIR = Path("/userdata/roms/ultrastar-deluxe/songs")
CONFIG_DIR = Path("/userdata/system/configs/ultrastar-deluxe")


class UltrastarDeluxeGenerator(Generator):

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        # Ensure directories exist
        SONGS_DIR.mkdir(parents=True, exist_ok=True)
        CONFIG_DIR.mkdir(parents=True, exist_ok=True)

        commandArray = ["ultrastardx"]

        # Set song directory
        commandArray.extend(["-SongDir", str(SONGS_DIR)])

        # Set fullscreen at game resolution
        if gameResolution:
            commandArray.extend([
                "-Screens", "1",
                "-Resolution", f"{gameResolution['width']}x{gameResolution['height']}",
            ])

        env = {
            "XDG_CONFIG_HOME": str(CONFIG_DIR),
        }

        return Command.Command(array=commandArray, env=env)

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "ultrastar-deluxe",
            "keys": { "exit": ["KEY_LEFTALT", "KEY_F4"] }
        }
