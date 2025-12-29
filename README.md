# Stremio Kai - Theme/Subtitles Patch

This is a simple Powershell script that fixes some of the CSS and subtitles issues in the Stremio Kai client.

[Stremio Kai](https://github.com/allecsc/Stremio-Kai) is a enhanced build of Stremio.

## What does the patch do?
- Re-enables some of the missing scrollbars (imagine scroll-wheeling all the way to One Piece EP.1155)
- Fixes vertical navigation menu appearing when you aren't hovering it
- Edits ```mpv.conf``` subtitle settings for better readability
- ...and other small tweaks.

## How to use

- Open ```patch.ps1``` with Powershell
- Select your Stremio Kai directory
- Wait for the patch to be applied

Keep in mind that if you edited ```mpv.conf``` and already changed the subtitle settings, they will be overwritten.

#### Tested on [v3.0.0](https://github.com/allecsc/Stremio-Kai/releases/tag/v3.0.0), it may not work on older versions.

