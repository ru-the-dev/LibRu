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

1. Place the LibRu folder in your `Interface/AddOns/` directory
2. Add `## Dependencies: LibRu` to your addon's .toc file

The library will automatically register itself using LibStub when loaded.

## Usage

```lua
-- In your addon
local LibRu = _G.LibRu

-- Create a module
local MyModule = LibRu.Module.New("MyModule", parentModule, dependencies, debug)

-- Use UI components
local button = LibRu.Frames.ResizeButton.New(parentFrame)

-- Register slash commands
LibRu.RegisterSlashCommand("/mymod", handler)
```

## Version

Current version: 1.6.0

## Dependencies

- LibStub (included with World of Warcraft)

## Author

ru_the_dev (Pookie)