<img src="icons/icon.jpg?raw=true" width="128" height=128>

# VNDS-LOVE

[![Build Status](https://travis-ci.com/ajusa/VNDS-LOVE.svg?branch=master)](https://travis-ci.com/ajusa/VNDS-LOVE)
[![Discord](https://img.shields.io/discord/716444798432575518.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/q8wjpt2)

VNDS-LOVE is a cross platform program that plays **V**isual **N**ovel **D**ual **S**creen formatted novels.
Many famous visual novels have been ported to this format, which was designed for the Nintendo DS.
This project lets you play novels like Fate/stay Night, Higurashi, and more!

## Supported Platforms
Windows, Mac, Linux, and the Nintendo Switch are all fully supported. 
Nintendo 3DS is mostly functional. 
Other platforms are a work in progress.

# Installation Instructions
If you are a **user** who wants to install this, go to the guide [here](https://docs.google.com/document/d/e/2PACX-1vRoZeD_wTko3X7FnARS2HtUerTUABwqnfnEJQpuEG9GQ0UvbnWFdbhvg7eEYsFNnMxTUJ7F9dupMCjQ/pub).

## Having an Issue?
Go to the [issues](https://github.com/ajusa/VNDS-LOVE/issues/) and search for an issue similar to yours.
If there are no similar issues, go ahead and make a new one! Fill out as much information as you can.

# Development Instructions
### Not accepting PRs right now, code is in the middle of being refactored!
ONLY FOLLOW THESE INSTRUCTIONS IF YOU WANT TO COMPILE VNDS-LOVE! 
IF YOU JUST WANT TO PLAY VISUAL NOVELS, GO TO THE GUIDE!

**Note:** Right now, building an NRO file is not supported on non-debian operating systems.
You can still easily test, but you won't be able to generate a final package.

You should be able to develop on Windows, Mac, and Linux. If you encounter any errors when trying to do that, [create an issue.](https://github.com/ajusa/VNDS-LOVE/issues/new)

## Quickstart
If you are an experienced developer, try reading through .travis.yml in the repository to get an idea of how the entire thing is built. If you want step by step instructions, follow along below.

## Guide

1. Install [LuaRocks](https://luarocks.org/)
2. After making sure that LuaRocks is on your path (`luarocks --help` has output), run the following:
```
luarocks install moonscript busted alfons
```
3. Clone the repository (`git clone https://github.com/ajusa/VNDS-LOVE`)
4. `cd` to the cloned directory (`cd VNDS-LOVE`)
5. Install [Love2D](https://love2d.org/) and make sure it is also on your path.

Run `alfons compile` to compile the moonscript source to lua.

Run `alfons run` to run VNDS-LOVE using the installed copy of `love`.

Run `alfons test` to run the busted unit tests, which are located in `spec`

## Building

Building binaries requires additional steps. 
If you are able to run VNDS-LOVE with changes using Love2D, you do not need to build the program.
You can submit a [Pull Request](https://github.com/ajusa/VNDS-LOVE/pulls) without building the program.
Building is just for distribution.

With that out of the way:

### Building for Windows, Mac, and Linux

1. Try running `luarocks install --server=http://luarocks.org/dev love-release`
2. Install `libzip-dev` on your OS if the above command fails.
3. Run `alfons build`, and the build files should appear in a `build` folder, including a `.love` file.

### Building for Switch and 3DS

Travis is set up to do these builds. If you want to do this locally as well,
follow the "Dependencies" instructions on the LovePotion wiki [here](https://turtlep.github.io/LovePotion/wiki/#/building).

1. Install [lovebrew](https://github.com/TurtleP/lovebrew) and make sure you can run `lovebrew -h`
2. Create a directory called `bin` in the root of the project
3. Download the latest [LovePotion release](https://github.com/TurtleP/LovePotion/releases), and save `LovePotion.elf` in `bin/switch.elf`.
4. Run `lovebrew` in the project directory.

This should output a `VNDS-LOVE.nro` file in the project root directory to test with. 
3DS isn't supported yet, but to test with it just modify `lovebrew.toml` so it includes 3ds as a target.
