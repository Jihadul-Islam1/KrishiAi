import pathlib, re

root = pathlib.Path('d:/EventSathi/krishiai')

def read(p):
    return p.read_bytes().decode('utf-8').replace(chr(13)+chr(10), chr(10))

def write(p, s):
    p.write_bytes(s.replace(chr(13)+chr(10), chr(10)).encode('utf-8'))

prov = root / 'lib' / 'presentation' / 'providers' / 'app_providers.dart'
s = read(prov)

needle = "\nimport 'package:go_router/go_router.dart';\n\nimport '../router/app_router.dart';\n\n/// ---------------------------------------------------------------------------\n/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so\n/// it rebuilds when those values change).\n/// ---------------------------------------------------------------------------\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"

assert needle in s, 'needle not found'
replacement = "\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"
s = s.replace(needle, replacement, 1)

old_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
new_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
assert old_top in s
s = s.replace(old_top, new_top, 1)

old_rel = "import '../../services/speech_service.dart';\n"
new_rel = "import '../../services/speech_service.dart';\nimport '../router/app_router.dart';\n"
assert old_rel in s
s = s.replace(old_rel, new_rel, 1)

write(prov, s)

router = root / 'lib' / 'presentation' / 'router' / 'app_router.dart'
rs = read(router)
assert 'GoRouter buildRouter(WidgetRef ref)' in rs
rs = rs.replace('GoRouter buildRouter(WidgetRef ref)', 'GoRouter buildRouter(Ref ref)', 1)
write(router, rs)

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