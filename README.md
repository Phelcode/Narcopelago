# Schedule 1 Archipelago Randomizer Setup Guide

## Building the .apworld from source (Windows PowerShell)

A `.apworld` is just a zip of `worlds/Schedule_I`. Archipelago's launcher validates it before installing
(`worlds/LauncherComponents.py` in the Archipelago repo): the zip root must contain exactly **one directory**,
that directory's name must appear in the **file name** (case-sensitive), entries must use forward slashes,
and `schedule_I/__init__.py` must exist. That is why the file is named `schedule_I.apworld` and the root
folder inside is `schedule_I` (first letter lowercased from `Schedule_I`).

Run this from the repo root (the folder that contains `worlds\`), with Windows PowerShell 5.1+ or PowerShell 7:

```powershell
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem

$src = Join-Path (Get-Location) 'worlds\Schedule_I'
$out = Join-Path (Get-Location) 'schedule_I.apworld'
if (Test-Path $out) { Remove-Item $out -Force }

$zip = [System.IO.Compression.ZipFile]::Open($out, [System.IO.Compression.ZipArchiveMode]::Create)
try {
    $prefix = $src.Length + 1
    Get-ChildItem -Path $src -Recurse -File -Force | ForEach-Object {
        if ($_.FullName -match '__pycache__') { return }
        if ($_.Extension -in '.pyc', '.pyd', '.so', '.dll') { return }
        # root entry is exactly one directory named schedule_I, forward slashes, name contained in the file stem
        $entryName = 'schedule_I/' + $_.FullName.Substring($prefix).Replace('\', '/')
        $entry = $zip.CreateEntry($entryName, [System.IO.Compression.CompressionLevel]::Optimal)
        $stream = $entry.Open()
        try {
            $file = [System.IO.File]::OpenRead($_.FullName)
            try { $file.CopyTo($stream) } finally { $file.Dispose() }
        } finally { $stream.Dispose() }
    }
} finally {
    $zip.Dispose()
}

# optional sanity check, mirrors the launcher's validation (python ships with Archipelago):
python -c "import zipfile,pathlib; p='schedule_I.apworld'; z=zipfile.ZipFile(p); d=[f.name for f in zipfile.Path(z).iterdir() if f.is_dir()]; s=pathlib.Path(p).stem; assert len(d)==1 and d[0] in s, d; z.open(d[0]+'/__init__.py'); print('OK:', s, d)"
```

Do not use `Compress-Archive worlds\Schedule_I\*` for this — the `\*` flattens the root folder, and some zip
tools write `\` path separators, both of which fail the launcher's check. Install the result with the
Archipelago launcher's "Install APWorld" button, or attach it to a GitHub release as `schedule_I.apworld`.

## Required Software

- [Archipelago](https://github.com/ArchipelagoMW/Archipelago/releases/latest)
- [The Schedule I apworld](https://github.com/MacH8s/Narcopelago/releases/latest),
- [Thunderstore Mod Manager](https://www.overwolf.com/app/thunderstore-thunderstore_mod_manager)
- [Narcopelago Mod](https://thunderstore.io/c/schedule-i/p/Narcopelago/Narcopelago/)

## How to play

First, you need a room to connect to. For this, you or someone you know has to generate a game.  
This will not be explained here,
but you can check the Archipelago Setup Guide.

You also need to have [Archipelago](https://github.com/ArchipelagoMW/Archipelago/releases/latest) installed
and the [The Schedule I apworld](https://github.com/MacH8s/Narcopelago/releases/latest) installed into Archipelago.

### Install Mod

Install Thunderstore Mod Manager and open it.
Choose Schedule I and make a profile for Archipelago, name it whatever you like.
Search for 'Narcopelago' in the mod search and install it.
Search for 'MelonLoader' in the mod serach and choose version ***0.7.1***.
From there you can launch the game as Modded on the top right and your install has been complete! You must launch the game this way every time you want to play Archipelago.

### Joining Game

Use In-Game UI to connect to server. Once connected, Create a new world and skip the prologue.
Make sure to save as often as you can, and you are able to rejoin. Restart your game if you need to rejoin the world!
If you want to play with friends (Untested): Invite them to your lobby. All of you connect as same archipelago Info, Load into world.

## Switching Rooms
Restart your game to switch rooms. There may be some issues if you don't do so even if it shows things are working.


# Schedule 1

## Where is the options page?

The [player options page for this game](../player-options) contains all the options you need to configure and export a
config file.

## What does randomization do to this game?

 - Sends checks from all missions.
 - Sends and receives all customer checks and items.
 - Customers can be unlocked by receiving them through archipelago when randomize_customers is true in the YAML.
 - checks for samples will be sent no matter the settings and are functional.
 - Dealers will send checks when recruiting regardless of settings.
 - Dealer AP unlock will allow user to then recruit them in game. Check is still possible when having them as a possible contact.
 - Suppliers will not be unlockable if suppliers are randomized and only unlocked through ap items
 - Suppliers give checks for unlocking them when suppliers are not randomized
 - Every Action that would cause cartel influence in a region to drop is a check (x7 per region)
 - Unable to reduce cartel influence naturally and cartel influence items added to pool when randomize_cartel_influence is true
 - Level up rewards are suppressed when randomize_level_up_rewards is true
 - Level up rewards are added to the item pool when randomize_level_up_rewards is true
 - Whenever you'd nomrally get unlocks for leveling up, you get a check regardless of the option
 - Deathlink is sent when a player dies or when they arrested. Recieved deathlink causes player to get sent to the hospital by default. Other options are available.
 - Property and busniesses give checks when purchased
 - Randomized properties or businesses will not be unlocked when purchased if randomization on, properties and/or businesses will be added to the item pool
 - Recipe checks are sent when recipes are learned
 - Cash for trash are sent every 10 trash burned
 - Filler items, including bundles are claimed via the AP phone app
 - Purchasing from Jen Heard and entering keycode into sewer office counts as a check

## Once I'm inside Schedule1, how do I play Schedule1AP

Use In-Game UI to connect to server. Once connected, Create a new world and skip the prologue.
Make sure to save as often as you can, and you are able to rejoin. Restart your game if you need to rejoin the world!
If you want to play with friends (Untested): Invite them to your lobby. All of you connect as same archipelago Info, Load into world.

## Tracker: Use the Pop Tracker!
[Poptracker by Razgriz](https://github.com/RazgrizEast/schedule-1-poptracker-razgriz/releases/latest)

## Multiplayer
Everyone connect using AP as same player/yaml name. 
Known issue: People who aren't host will have fillers within AP app too, so they'll be duplicate.
Suggestion is to not collect fillers if you are not the host.

## A statement on the ownership over Schedule1AP

Schedule I apworld is MIT license. Created by MacH8s
