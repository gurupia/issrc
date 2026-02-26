import sys

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
        
    for i, line in enumerate(lines):
        if line.startswith('| **Delphi 7**'):
            lines[i] = '| **Delphi 7**     | 2002  | ~500MB | 가볍고 빠름 |\n'
        elif line.startswith('| **Delphi XE7**'):
            lines[i] = '| **Delphi XE7**   | 2014  | ~3GB   | 중간        |\n'
        elif line.startswith('| **Delphi 10.4**'):
            lines[i] = '| **Delphi 10.4**  | 2020  | ~6GB   | 무거움      |\n'
        elif line.startswith('| **Delphi 12.3**'):
            lines[i] = '| **Delphi 12.3**  | 2024  | ~8GB   | 매우 무거움 |\n'
        elif line.startswith('|------|-----|-----|-----|'):
            lines[i] = '| ---------------- | ----- | ------ | ----------- |\n'
        elif line.startswith('**A: 가능하지만 권장하지 않습니다**'):
            lines[i] = 'A: **가능하지만 권장하지 않습니다**\n'

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)

process_file('03_Guides_and_Manuals/DELPHI_VERSION_GUIDE.md')
