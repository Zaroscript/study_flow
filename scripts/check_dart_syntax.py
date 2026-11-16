"""Optional source-only check; does not replace flutter analyze or widget tests."""
from pathlib import Path
import os
import sys
import tempfile
sys.path.insert(0, os.path.join(tempfile.gettempdir(), 'enote-dart-syntax'))
from tree_sitter import Language, Parser
import tree_sitter_dart

parser = Parser(Language(tree_sitter_dart.language()))
root = Path(__file__).resolve().parent.parent
failures = []
files = list((root / 'lib').rglob('*.dart')) + list((root / 'test').glob('*.dart'))
for path in files:
    content = path.read_bytes()
    tree = parser.parse(content)
    if not tree.root_node.has_error:
        continue
    pending = [tree.root_node]
    while pending:
        node = pending.pop()
        if node.type == 'ERROR' or node.is_missing:
            failures.append(f'{path.relative_to(root)}:{node.start_point.row + 1}:{node.start_point.column + 1} {node.type}')
        else:
            pending.extend(reversed(node.children))
print(f'Parsed {len(files)} Dart source files.')
print('\n'.join(failures) if failures else 'No Dart syntax errors found. Flutter type and runtime checks still required.')
sys.exit(bool(failures))
