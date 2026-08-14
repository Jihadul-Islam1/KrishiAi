import pathlib, re

root = pathlib.Path('d:/EventSathi/krishiai')

def read(p):
    return p.read_bytes().decode('utf-8').replace('\r\n', '\n')

def write(p, s):
    p.write_bytes(s.replace('\r\n', '\n').encode('utf-8'))

# 1. app_providers.dart
prov = root / 'lib' / 'presentation' / 'providers' / 'app_providers.dart'
s = read(prov)

# Match the late imports + routerProvider using a regex so we don't depend on
# exact dash counts.
pattern = re.compile(
    r"\nimport 'package:go_router/go_router\.dart';\n\n"
    r"import '\.\./router/app_router\.dart';\n\n"
    r"/// [^\n]*\n"
    r"/// Router \(depends on onboardingCompleteProvider \+ currentFarmerProvider, so\n"
    r"/// it rebuilds when those values change\)\.\n"
    r"/// [^\n]*\n"
    r"final routerProvider = Provider<GoRouter>\(\(ref\) => buildRouter\(ref\)\);\n"
)
m = pattern.search(s)
assert m, 'late block regex did not match'
replacement = "\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"
s = s[:m.start()] + replacement + s[m.end():]

# Insert go_router import near the top
old_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
new_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
assert old_top in s, 'top imports missing'
s = s.replace(old_top, new_top, 1)

# Insert relative router import
old_rel = "import '../../services/speech_service.dart';\n"
new_rel = "import '../../services/speech_service.dart';\nimport '../router/app_router.dart';\n"
assert old_rel in s, 'relative import missing'
s = s.replace(old_rel, new_rel, 1)

write(prov, s)

# 2. app_router.dart
router = root / 'lib' / 'presentation' / 'router' / 'app_router.dart'
rs = read(router)
assert 'GoRouter buildRouter(WidgetRef ref)' in rs, 'router signature not found'
rs = rs.replace('GoRouter buildRouter(WidgetRef ref)', 'GoRouter buildRouter(Ref ref)', 1)
write(router, rs)

# 3. widget_test.dart
test = root / 'test' / 'widget_test.dart'
test.write_text(
    "// Smoke test for the KrishiAI root widget.\n\n"
    "import 'package:flutter/material.dart';\n"
    "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
    "import 'package:flutter_test/flutter_test.dart';\n\n"
    "import 'package:krishiai/main.dart';\n\n"
    "void main() {\n"
    "  testWidgets('KrishiAI pumps without throwing', (WidgetTester tester) async {\n"
    "    await tester.pumpWidget(const ProviderScope(child: KrishiAI()));\n"
    "    await tester.pump();\n"
    "    expect(find.byType(MaterialApp), findsOneWidget);\n"
    "  });\n"
    "}\n",
    encoding='utf-8',
)

print('all edited')
