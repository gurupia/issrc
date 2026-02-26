import glob
import os

def fix_closing_fences(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    in_block = False
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith('```'):
            if not in_block:
                in_block = True
                if stripped == '```':
                    lines[i] = line.replace('```', '```txt')
            else:
                in_block = False
                # It's a closing fence; make sure it doesn't have a language specifier
                # Replace the first occurrence of ```txt or ```anything with ```
                # A closing fence must exactly be ```
                lines[i] = line.replace(stripped, '```')

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)

files = glob.glob('02_Architecture_and_Strategy/*.md') + glob.glob('03_Guides_and_Manuals/*.md')
for f in files:
    fix_closing_fences(f)
print("Fences fixed.")
