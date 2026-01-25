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

LibRu is designed as an **embedded library** that can be integrated directly into your World of Warcraft addon.

### Using as Git Submodule

To add LibRu as a Git submodule in your addon's `Libs` directory:

```bash
git submodule add https://github.com/ru-the-dev/LibRu Libs/LibRu
```

### Manual Integration

1. Download or clone LibRu from the repository
2. Copy the `LibRu` folder into your addon's directory (typically `Libs/LibRu`)
3. Include the necessary files in your addon's `.toc` file

### For Addon Developers

To use LibRu in your addon code, reference it as an embedded library within your namespace.


## Architecture

LibRu uses a **namespace-based architecture** designed for embedded use within addons. It provides a complete framework for building modular WoW addons with consistent UI components, event handling, and debugging tools.

## LibStub

LibRu includes an embedded copy of LibStub for reliable operation. LibStub is a stable, public domain library that hasn't changed significantly in over a decade. While submodules are ideal for actively maintained dependencies, LibStub's stability makes embedding the appropriate choice.

## Author

ru_the_dev (Pookie)