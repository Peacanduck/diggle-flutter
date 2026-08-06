"""Extract the content catalogue: ids + English name/description."""
import re
import json
import sys
import io

sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8',
                              errors='replace')

out = {}


def grab(path, pattern, label, groups=('id', 'name', 'desc')):
    src = open(path, encoding='utf-8').read()
    items = []
    for m in re.finditer(pattern, src, re.S):
        d = m.groupdict()
        items.append({g: d.get(g) for g in groups})
    out[label] = items
    print(f'{label:22} {len(items):>4} items  ({path})')


# ArtifactDefinition(id: 'x', name: 'y', description: 'z', ...)
grab('lib/game/systems/collection_system.dart',
     r"id:\s*'(?P<id>[^']+)',\s*name:\s*'(?P<name>(?:[^'\\]|\\.)*)',"
     r"\s*description:\s*\n?\s*'(?P<desc>(?:[^'\\]|\\.)*)'",
     'artifacts')

grab('lib/game/systems/achievement_system.dart',
     r"id:\s*'(?P<id>[^']+)',\s*name:\s*'(?P<name>(?:[^'\\]|\\.)*)',"
     r"\s*description:\s*\n?\s*'(?P<desc>(?:[^'\\]|\\.)*)'",
     'achievements')

# enum members with a displayName switch: collect the case labels
for path, label in [
    ('lib/game/systems/item_system.dart', 'items'),
    ('lib/game/world/tile.dart', 'tiles'),
]:
    src = open(path, encoding='utf-8').read()
    names = re.findall(r"case \w+\.(\w+):\s*\n\s*return '([^']+)'", src)
    out[label] = [{'id': a, 'name': b, 'desc': None} for a, b in names]
    print(f'{label:22} {len(names):>4} case returns  ({path})')

# gear part names
src = open('lib/game/systems/gear_system.dart', encoding='utf-8').read()
parts = sorted(set(re.findall(r"'([A-Z][A-Za-z]+(?: [A-Z][A-Za-z]+)+)'", src)))
out['gear_parts'] = [{'id': p, 'name': p, 'desc': None} for p in parts]
print(f"{'gear_parts':22} {len(parts):>4} names  (gear_system.dart)")

total = sum(
    len([1 for i in v if i.get('name')]) + len([1 for i in v if i.get('desc')])
    for v in out.values())
print(f'\nTOTAL translatable strings in catalogue: ~{total}')

json.dump(out, open('tool/catalogue.json', 'w', encoding='utf-8'),
          ensure_ascii=False, indent=1)
print('wrote catalogue.json')
