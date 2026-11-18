import re,json
from pathlib import Path
strings=set()
files=list(Path('lib/features').rglob('*screen.dart'))+list(Path('lib/features/shell').glob('*.dart'))+list(Path('lib/features/onboarding/widgets').glob('*.dart'))+list(Path('lib/core/widgets').glob('*.dart'))+list(Path('lib/core/constants').glob('*.dart'))
for p in files:
    for m in re.finditer(r"'((?:\\.|[^'\\])*)'",p.read_text(encoding='utf8')):
        v=m.group(1)
        if re.search('[\u0600-\u06ff]',v) and '$' not in v and '\n' not in v and len(v)<350: strings.add(v.replace("\\'", "'"))
english=json.loads(Path('.tooling/english.json').read_text(encoding='utf8'))
unknown=sorted(strings-set(english))
Path('.tooling/native-labels.json').write_text(json.dumps(sorted(strings),ensure_ascii=False,indent=2),encoding='utf8')
Path('.tooling/native-untranslated.json').write_text(json.dumps(unknown,ensure_ascii=False,indent=2),encoding='utf8')
print(f'{len(strings)} native labels; {len(strings)-len(unknown)} have existing translations; {len(unknown)} need translation.')
print(json.dumps(unknown,ensure_ascii=False,indent=2))
