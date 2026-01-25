# LibRu

A lightweight library framework for World of Warcraft addons.

## Features

- **Module System**: Easy-to-use module registration and management
- **Event Handling**: Robust event frame system with script and callback support
- **UI Components**: Pre-built UI components (buttons, sliders, frames)
- **Debug Tools**: Comprehensive debugging utilities and color-coded logging
- **Database Utilities**: Simple database factory for saved variables
- **Slash Commands**: Easy slash command registration system

## Installation

LibRu is distributed as a **separate addon** that will be **automatically downloaded** when other addons declare it as a dependency.

### For Addon Developers

To use LibRu in your addon:

1. Add `## Dependencies: LibRu` to your addon's `.toc` file
2. CurseForge/Overwolf will automatically download LibRu when users install your addon
3. Use LibRu in your code as shown below

### Manual Installation

If you need to install manually:
1. Download LibRu from CurseForge/Overwolf
2. Place the `LibRu` folder in your `Interface/AddOns/` directory


## Architecture

LibRu uses a **namespace-based architecture** designed for embedded use within addons. It provides a complete framework for building modular WoW addons with consistent UI components, event handling, and debugging tools.

## LibStub

LibRu includes an embedded copy of LibStub for reliable operation. LibStub is a stable, public domain library that hasn't changed significantly in over a decade. While submodules are ideal for actively maintained dependencies, LibStub's stability makes embedding the appropriate choice.

## Author

ru_the_dev (Pookie)