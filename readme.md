# CODHU Promod for Call of Duty 4

CODHU (callofduty.hu) is a community Call of Duty 4 Promod project based on the original [Promod4](https://github.com/promod/promod4), including Promod LIVE V2.21 EU. The CODHU version uses `codhu_promod` as its mod folder and `fs_game` value.

## Build and install

Run `build.bat`. It detects the Call of Duty 4 tools root when possible; otherwise, enter the folder containing `raw`, `bin`, and `zone_source`. It builds the IWD and fastfile, then installs them in `Mods\codhu_promod`.

Each build and backups of existing files it replaces are kept under `codhu_builds` in the game root. The build scripts do not delete files. Start the server with `+set fs_game mods/codhu_promod`; see [server_setup.txt](server_setup.txt) for an example.

## CODHU changes

Changes made for CODHU are dated 2026-10-05. The server no longer reports disabled PunkBuster as a violation.

## Attribution and license

Based on Promod4 by Andreas Göransson and Indrek Ardel. See [LICENSE.md](LICENSE.md) for the Promod Modder Ethical Public License and the Call of Duty 4 Mod Tools license terms. This is an unofficial community project and is not made or supported by Activision.
