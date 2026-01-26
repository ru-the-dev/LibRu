import markdown
import re
from html.parser import HTMLParser
from pathlib import Path
import argparse

class MarkdownToWoWParser(HTMLParser):
    def __init__(self, addon_name="BetterTransmog"):
        super().__init__()
        self.addon_name = addon_name
        self.versions = {}
        self.current_version = None
        self.current_text = ""
        self.in_bold = False
        self.in_italic = False
        self.in_code = False
        self.in_heading = False
        self.heading_level = 0

    def handle_starttag(self, tag, attrs):
        self.flush_text()
        if tag in ['h1', 'h2', 'h3']:
            self.in_heading = True
            self.heading_level = int(tag[1])
            if self.heading_level == 1:
                self.current_version = None  # reset
            elem = {'type': 'heading', 'level': self.heading_level, 'text': ''}
            if self.current_version:
                self.versions[self.current_version].append(elem)
            else:
                # For h1, we'll set it in data
                pass
        elif tag == 'p':
            if self.current_version:
                self.versions[self.current_version].append({'type': 'text', 'text': ''})
        elif tag == 'li':
            if self.current_version:
                self.versions[self.current_version].append({'type': 'list_item', 'text': ''})
        elif tag == 'img':
            if self.current_version:
                attrs_dict = dict(attrs)
                src = attrs_dict.get('src', '')
                alt = attrs_dict.get('alt', '')
                full_path = f"Interface/AddOns/{self.addon_name}/" + src
                self.versions[self.current_version].append({'type': 'image', 'path': full_path, 'alt': alt})
        elif tag == 'strong' or tag == 'b':
            self.in_bold = True
        elif tag == 'em' or tag == 'i':
            self.in_italic = True
        elif tag == 'code':
            self.in_code = True
        elif tag == 'br':
            self.current_text += '\n'

    def handle_endtag(self, tag):
        if tag in ['h1', 'h2', 'h3']:
            self.flush_text()
            self.in_heading = False
            self.heading_level = 0
        elif tag in ['p', 'li']:
            self.flush_text()
        elif tag == 'strong' or tag == 'b':
            self.in_bold = False
        elif tag == 'em' or tag == 'i':
            self.in_italic = False
        elif tag == 'code':
            self.in_code = False

    def handle_data(self, data):
        if self.in_heading and self.heading_level == 1:
            self.current_version = data.strip()
            self.versions[self.current_version] = []
            self.versions[self.current_version].append({'type': 'heading', 'level': 1, 'text': data})
        else:
            formatted_data = data
            if self.in_bold:
                formatted_data = f"|cffffd100{formatted_data}|r"
            if self.in_italic:
                formatted_data = f"|cff888888{formatted_data}|r"  # dim for italic
            if self.in_code:
                formatted_data = f"|cff0080ff{formatted_data}|r"  # darker blue for code
            self.current_text += formatted_data

    def flush_text(self):
        if self.current_text.strip() and self.current_version:
            if self.versions[self.current_version] and self.versions[self.current_version][-1]['type'] in ['text', 'heading', 'list_item']:
                self.versions[self.current_version][-1]['text'] += self.current_text
        self.current_text = ""

def parse_changelog(md_path, addon_name="BetterTransmog"):
    with open(md_path, 'r', encoding='utf-8') as f:
        md_content = f.read()

    html = markdown.markdown(md_content, extensions=['extra', 'nl2br'])
    parser = MarkdownToWoWParser(addon_name)
    parser.feed(html)
    parser.flush_text()  # flush any remaining

    # Post-process
    for version, elements in parser.versions.items():
        current_level = 0
        for elem in elements:
            if elem['type'] == 'heading':
                elem['indent_level'] = elem['level'] - 1
                current_level = elem['level']
                if elem['level'] == 1:
                    # elem['text'] = "|u" + elem['text'] + "|u"  # Underline not working
                    pass
            else:
                elem['indent_level'] = current_level
            if elem['type'] == 'text':
                pass
            elif elem['type'] == 'list_item':
                elem['text'] = '- ' + elem['text']

    return parser.versions

def generate_lua_table(versions):
    lines = ["CHANGELOG_ELEMENTS = {"]
    for version, elements in versions.items():
        lines.append(f"    ['{version}'] = {{")
        for elem in elements:
            line = "        {"
            line += f"type = '{elem['type']}', "
            if 'text' in elem:
                text = elem['text'].replace('\n', '|n')
                line += f"text = [[{text}]], "
            if 'level' in elem:
                line += f"level = {elem['level']}, "
            if 'path' in elem:
                line += f"path = [[{elem['path']}]], "
            if 'width' in elem and elem['width'] is not None:
                line += f"width = {elem['width']}, "
            if 'height' in elem and elem['height'] is not None:
                line += f"height = {elem['height']}, "
            if 'indent_level' in elem:
                line += f"indent_level = {elem['indent_level']}, "
            line = line.rstrip(', ') + "},"
            lines.append(line)
        lines.append("    },")
    lines.append("}")
    return '\n'.join(lines)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Update changelog in Lua file from Markdown')
    parser.add_argument('changelog_md', help='Path to the CHANGELOG.md file')
    parser.add_argument('changelog_lua', help='Path to the output Lua file')
    parser.add_argument('--addon-name', default='BetterTransmog', help='Name of the addon for image paths')
    args = parser.parse_args()

    changelog_md_path = Path(args.changelog_md)
    changelog_lua_path = Path(args.changelog_lua)

    elements = parse_changelog(changelog_md_path, args.addon_name)
    lua_table = generate_lua_table(elements)

    # Read the lua file
    with open(changelog_lua_path, 'r', encoding='utf-8') as f:
        lua_content = f.read()

    # Replace the CHANGELOG_ELEMENTS block
    start_pattern = r'CHANGELOG_ELEMENTS = \{'
    end_pattern = r'-- Group elements by version'

    start_match = re.search(start_pattern, lua_content)
    end_match = re.search(end_pattern, lua_content)
    if start_match and end_match:
        start = start_match.start()
        end = end_match.start()
        new_content = lua_content[:start] + lua_table + '\n\n' + lua_content[end:]
    else:
        print("Could not find CHANGELOG_ELEMENTS or end marker")
        exit(1)

    # Write back
    with open(changelog_lua_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    print("Changelog updated successfully!")