NP_QoL 0.1.0 - Quality of Life Enhancements for Batomon Showdown
=================================================================

What it does
------------
Displays a simple, draggable panel during battles showing:
  [Heart Icon] HP [value] | [Badge Icon] Wins [value] | [Sun Icon] Day [value]

The panel appears automatically during battles and shows your current stats.
No hotkeys needed - it's read-only and doesn't affect your run, saves, or matchmaking.

Usage
-----
- Drag the header to move the panel anywhere on screen
- Click the header (or the -/+ button) to minimize/expand the panel
- Your position and minimized state are saved automatically

Requirement
-----------
The community Batomon Showdown Mod Loader (Mods\mod_loader.gd plus its ModLoader= line in
override.cfg). Install it first.

Install
-------
1. Close the game.
2. Open the game folder (Steam: right-click Batomon Showdown > Manage > Browse local files).
3. Extract this mod INTO that folder. You should get:
       Mods\NP_QoL\mod_main.gd   (and the other NP_QoL files)
4. Start the game. Mods\mod_loader.log should show "Started ...NP_QoL/mod_main.gd".

Uninstall
---------
Delete the Mods\NP_QoL folder. Your settings are kept in the game's user folder
(np_qol.cfg); delete that too for a clean slate.

Files written
-------------
user://np_qol.cfg (panel position and minimized state)
