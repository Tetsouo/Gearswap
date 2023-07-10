# FFXI GearSwap Scripts by Tetsouo: Boost Your Gameplay

Welcome to my corner of GitHub! I'm Tetsouo, and I've crafted some Lua scripts for various jobs in Final Fantasy XI, specifically for the GearSwap addon. Covered jobs include Paladin (PLD), Warrior (WAR), Black Mage (BLM), Thief (THF), and Dancer (DNC).

## Description

I love playing FFXI and working with scripts, so why not blend the two? These scripts, carefully refined over time, handle all the gear swaps for you, allowing you to focus on the fun part - the gameplay.

Sharing my work with the FFXI community is a joy for me. Perhaps these scripts can add an extra layer of immersion to your gameplay experience - at least, that's my hope!

## Installation

To get these scripts up and running:

1. Ensure you have the GearSwap addon installed for Final Fantasy XI.
2. Clone this repo or download the Lua files.
3. Transfer the Lua files into your GearSwap installation's 'data' directory.
4. Rename the Lua files following the format: `[character_name]_JOB.lua`. For example, if your character's name is Tetsouo and you want to use the script for the Paladin job, rename the file to `Tetsouo_PLD.lua`.

## Usage

If GearSwap is correctly installed and the job file is aptly named (`userName_Job.lua`), the script should automatically load when you launch FFXI.

If that doesn't happen, simply:

- Open the console and type `lua load gearswap`.
  
  Or

- Input `//lua load gearswap` into the game chat.

With GearSwap active, you can load the script for a specific job using this command: `//gs load Job`. Replace 'Job' with the job you want to load (like `//gs load PLD`).

## Contributions

Feel free to enhance these scripts or fix any bugs you might encounter! Fork this repo, make your amendments, and submit a pull request.

## License

This project falls under the terms of the MIT license. More details are available in the [LICENSE](./LICENSE) file in the repository.
