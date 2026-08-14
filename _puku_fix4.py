import pathlib

root = pathlib.Path('d:/EventSathi/krishiai')

def read(p):
    return p.read_bytes().decode('utf-8').replace(chr(13)+chr(10), chr(10))

def write(p, s):
    p.write_bytes(s.replace(chr(13)+chr(10), chr(10)).encode('utf-8'))

prov = root / 'lib' / 'presentation' / 'providers' / 'app_providers.dart'
s = read(prov)

N = "\nimport 'package:go_router/go_router.dart';\n\nimport '../router/app_router.dart';\n\n/// -" + ("-" * 75) + "\n/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so\n/// it rebuilds when those values change).\n/// -" + ("-" * 75) + "\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"

assert N in s, 'needle not found: ' + repr(s[-500:])
R = "\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"
s = s.replace(N, R, 1)

A = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
B = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
assert A in s
s = s.replace(A, B, 1)

C = "import '../../services/speech_service.dart';\n"
D = "import '../../services/speech_service.dart';\nimport '../router/app_router.dart';\n"
assert C in s
s = s.replace(C, D, 1)

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