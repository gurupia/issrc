import sys

def fix_md040(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    in_block = False
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped == '```':
            if not in_block:
                lines[i] = line.replace('```', '```txt')
                in_block = True
            else:
                in_block = False
        elif stripped.startswith('```') and len(stripped) > 3:
            if not in_block:
                in_block = True
            else:
                # Should not happen, but just in case
                in_block = False

    with open(filepath, 'w', encoding='utf-8') as f:
        f.writelines(lines)

files = [
    '02_Architecture_and_Strategy/DOTNET_PORTING_ANALYSIS.md',
    '02_Architecture_and_Strategy/HYBRID_DOTNET_IDE_STRATEGY.md',
    '02_Architecture_and_Strategy/IDE_INTEGRATION.md',
    '02_Architecture_and_Strategy/SETUP_STUB_REALITY.md',
    '02_Architecture_and_Strategy/SIMPLE_SOLUTION.md'
]

for f in files:
    fix_md040(f)
