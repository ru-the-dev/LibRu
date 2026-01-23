#!/usr/bin/env python3
"""
Script to automatically add @field annotations for submodules in LibRu-based addon modules.
Scans .lua files in the specified modules directory and updates class definitions with Modules fields.
Generalized for any addon using LibRu's module system.
"""

import os
import re
import argparse
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(description="Auto-generate @field annotations for LibRu modules.")
    parser.add_argument('--addon_name', required=True, help="The name of the addon (e.g., 'BetterTransmog').")
    parser.add_argument('--modules_dir', default='Modules', help="Directory to scan for modules (default: 'Modules').")
    args = parser.parse_args()
    
    addon_name = args.addon_name
    modules_dir = Path(args.modules_dir)
    
    # Change to the script's directory (assumes script is in addon root or LibRu subfolder)
    os.chdir(Path(__file__).parent.parent)  # Adjust if needed; assumes LibRu/ is a subfolder
    
    # Dynamically build regex patterns based on addon_name
    CLASS_PATTERN = re.compile(r'---\s*@class (' + re.escape(addon_name) + r'(?:\.Modules(?:\.[^:]*)?)?) : LibRu\.Module')
    MODULE_NEW_PATTERN = re.compile(r'local\s+Module\s*=\s.*?\.Module\.New\s*\(\s*"([^"]+)"\s*,\s*([^,\s]+)\s*,')
    FIELD_MODULES_PATTERN = re.compile(r'^---@field\s+Modules\s*\{([^}]*)\}')
    
    def get_module_name_from_file(filepath):
        """Extract module name from file path."""
        parts = filepath.relative_to(modules_dir).parts
        if parts[-1].endswith('.lua'):
            parts = parts[:-1] + (parts[-1][:-4],)
        return '.'.join(parts)
    
    def collect_classes():
        """Collect all class definitions."""
        classes = {}
        # Check Core.lua for top-level class
        core_file = Path('Core.lua')
        if core_file.exists():
            with open(core_file, 'r', encoding='utf-8') as f:
                content = f.read()
                for match in CLASS_PATTERN.finditer(content):
                    class_name = match.group(1)
                    classes[class_name] = core_file
        # Check all lua files in modules_dir
        for lua_file in modules_dir.rglob('*.lua'):
            with open(lua_file, 'r', encoding='utf-8') as f:
                content = f.read()
                for match in CLASS_PATTERN.finditer(content):
                    class_name = match.group(1)
                    classes[class_name] = lua_file
        return classes
    
    def collect_module_news():
        """Collect all Module.New calls with their parents."""
        module_news = []
        for lua_file in modules_dir.rglob('*.lua'):
            with open(lua_file, 'r', encoding='utf-8') as f:
                content = f.read()
                matches = re.findall(r'local\s+Module\s*=\s.*?\.Module\.New\s*\(\s*"([^"]+)"\s*,\s*([^,]+)\s*,', content, re.DOTALL)
                for match in matches:
                    name = match[0]
                    parent_expr = match[1].strip()
                    parent_module = None
                    if parent_expr == 'Core':
                        parent_module = addon_name
                    elif parent_expr.startswith('Core.Modules.'):
                        module_path = parent_expr[len('Core.Modules.'):].strip()
                        parent_module = f'{addon_name}.Modules.{module_path}'
                    else:
                        # Try to find variable assignment
                        lines = content.split('\n')
                        for i, line in enumerate(lines):
                            if f'"{name}"' in line and 'Module.New' in line:
                                parent_module = find_parent_module(lines[:i], parent_expr, lua_file)
                                break
                    if parent_module:
                        module_news.append({
                            'file': lua_file,
                            'name': name,
                            'parent': parent_module
                        })
        return module_news
    
    def find_parent_module(lines, var_name, current_file):
        """Find what module variable refers to by looking backwards."""
        for line in reversed(lines):
            if f'local {var_name} = ' in line:
                match = re.search(rf'local\s+{var_name}\s*=\s*(.+)', line)
                if match:
                    assignment = match.group(1).strip()
                    if assignment == 'Core':
                        return addon_name
                    elif 'Core.Modules.' in assignment:
                        match2 = re.search(r'Core\.Modules\.(.+)', assignment)
                        if match2:
                            return f'{addon_name}.Modules.{match2.group(1)}'
            elif f'{var_name} = ' in line:
                match = re.search(rf'{var_name}\s*=\s*(.+)', line)
                if match:
                    assignment = match.group(1).strip()
                    if 'Core.Modules.' in assignment:
                        match2 = re.search(r'Core\.Modules\.(.+)', assignment)
                        if match2:
                            return f'{addon_name}.Modules.{match2.group(1)}'
        return None
    
    def build_submodules_map(module_news, classes):
        """Build a map of parent modules to their submodules."""
        submodules = {}
        for news in module_news:
            parent = news['parent']
            name = news['name']
            submodule_class = None
            for class_name, file in classes.items():
                if file == news['file']:
                    submodule_class = class_name
                    break
            if submodule_class and parent in classes:
                if parent not in submodules:
                    submodules[parent] = {}
                submodules[parent][name] = submodule_class
        return submodules
    
    def update_class_definitions(submodules, classes):
        """Update the class definitions with Modules fields."""
        for parent_class, subs in submodules.items():
            if parent_class in classes:
                file = classes[parent_class]
                with open(file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                lines = content.split('\n')
                class_line_idx = None
                for i, line in enumerate(lines):
                    if re.search(r'---\s*@class\s+' + re.escape(parent_class) + r'\s*:', line):
                        class_line_idx = i
                        break
                
                if class_line_idx is not None:
                    modules_field_idx = None
                    for i in range(class_line_idx + 1, len(lines)):
                        if lines[i].startswith('---@field Modules'):
                            modules_field_idx = i
                            break
                        elif not lines[i].startswith('---@field') and lines[i].strip():
                            break
                    
                    modules_str = ', '.join(f'{name}: {cls}' for name, cls in subs.items())
                    new_field = f'---@field Modules {{{modules_str}}}'
                    
                    if modules_field_idx is not None:
                        lines[modules_field_idx] = new_field
                    else:
                        lines.insert(class_line_idx + 1, new_field)
                    
                    try:
                        with open(file, 'w', encoding='utf-8') as f:
                            f.write('\n'.join(lines))
                        print(f"Updated {file}")
                    except Exception as e:
                        print(f"Failed to update {file}: {e}")
                else:
                    print(f"No class definition found for {parent_class}")
    
    classes = collect_classes()
    module_news = collect_module_news()
    submodules = build_submodules_map(module_news, classes)
    update_class_definitions(submodules, classes)
    
    print("Done!")

if __name__ == '__main__':
    main()