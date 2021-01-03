<img src="icons/icon.jpg?raw=true" width="128" height=128>

# VNDS-LOVE
[![Build Status](https://github.com/ajusa/VNDS-LOVE/workflows/VNDS-LOVE/badge.svg)](https://github.com/ajusa/VNDS-LOVE/actions)
[![Discord](https://img.shields.io/discord/716444798432575518.svg?label=&logo=discord&logoColor=ffffff&color=7389D8&labelColor=6A7EC2)](https://discord.gg/q8wjpt2)

VNDS-LOVE is a cross platform program that plays **V**isual **N**ovel **D**ual **S**creen formatted novels.
Many famous visual novels have been ported to this format, which was designed for the Nintendo DS.

## What is VNDS?
VNDS is a specification designed for visual novels in order to run them on the Nintendo DS. Many of the original sources for the project no longer exist, but you can find further information on it [at this wiki page.](https://github.com/BASLQC/vnds/wiki)

VNDS novels only have a few commands. As such, they don't have any support for animations, videos, or other fancier graphical capabilites of newer visual novels. They support basic audio and image based storytelling.

## Project Status
Mostly functional. There are no known VNDS related bugs. Note that some features from other visual novel engines might be missing. If they are, file an issue along with a general description of the feature.

## Supported Platforms
Windows, Mac, Linux, and the Nintendo Switch are all fully supported. Note that you need to have a Switch capable of running homebrew. For more information, see the guide below.

### Nintendo 3DS
This is only partially supported and a work in progress. I do provide builds (3dsx files) for the Nintendo 3DS, however the image format that the 3DS needs is custom (.t3x) so PNG/JPG files do not work on it without being converted. At some point I do intend on writing a cross platform conversion tool, however that won't be for a while most likely. Text and audio still work fine without any conversion.

Performance on the 3DS is also lacking at this moment. You can see this being tracked in [this issue.](https://github.com/ajusa/VNDS-LOVE/issues/16)
### Android
Android is also only partially supported. There aren't any touchscreen controls at this moment. You can still play through novels by hooking up an external gamepad, such as a Switch Joycon over bluetooth or a Wii Remote. Audio, images, and text all work fine.

# Installation Instructions
If you are a **user** who wants to install this, go to the guide [here](https://docs.google.com/document/d/e/2PACX-1vRoZeD_wTko3X7FnARS2HtUerTUABwqnfnEJQpuEG9GQ0UvbnWFdbhvg7eEYsFNnMxTUJ7F9dupMCjQ/pub).
If you encounter any issues, feel free to pop in our Discord [here.](https://discord.gg/q8wjpt2)

If you don't want to use Discord for some reason, feel free to open a Github issue.

## Having an Issue?
Go to the [issues](https://github.com/ajusa/VNDS-LOVE/issues/) and search for an issue similar to yours.
If there are no similar issues, go ahead and make a new one! Fill out as much information as you can.

# Development Instructions
ONLY FOLLOW THESE INSTRUCTIONS IF YOU WANT TO COMPILE VNDS-LOVE! 
IF YOU JUST WANT TO PLAY VISUAL NOVELS, GO TO THE GUIDE!

**Note:** Right now, building an NRO file is only supported on systems that you can install devKitPro on.
You can still easily test, but you won't be able to generate a final package.

You should be able to develop on Windows, Mac, and Linux. If you encounter any errors when trying to do that, [create an issue.](https://github.com/ajusa/VNDS-LOVE/issues/new)

## Quickstart
If you are an experienced developer, try reading through the Dockerfile and the main.yml workflow in the repository to get an idea of how the entire thing is built. If you want step by step instructions, follow along below.

## Guide

1. Install [LuaRocks](https://luarocks.org/)
2. After making sure that LuaRocks is on your path (`luarocks --help` has output), run the following:
```
luarocks install moonscript
luarocks install busted
luarocks install alfons
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

Github Actions is set up to do these builds. If you want to do this locally as well,
follow the "Dependencies" instructions on the LovePotion wiki [here](https://turtlep.github.io/LovePotion/wiki/#/building).

1. Install [lovebrew](https://github.com/TurtleP/lovebrew) and make sure you can run `lovebrew -h`
2. Create a directory called `bin` in the root of the project
3. Download the latest [LovePotion release](https://github.com/TurtleP/LovePotion/releases), and save `LovePotion.elf` in `bin/switch.elf`.
4. Run `lovebrew` in the project directory.

This should output a `VNDS-LOVE.nro` file in the project root directory to test with. 
