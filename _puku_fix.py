import pathlib

root = pathlib.Path('d:/EventSathi/krishiai')

def read(p):
    return p.read_bytes().decode('utf-8').replace('\r\n', '\n')

def write(p, s):
    p.write_bytes(s.replace('\r\n', '\n').encode('utf-8'))

# 1. app_providers.dart
prov = root / 'lib' / 'presentation' / 'providers' / 'app_providers.dart'
s = read(prov)

late_block = (
    "\nimport 'package:go_router/go_router.dart';\n\n"
    "import '../router/app_router.dart';\n\n"
    "/// ---------------------------------------------------------------------------\n"
    "/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so\n"
    "/// it rebuilds when those values change).\n"
    "/// ---------------------------------------------------------------------------\n"
    "final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"
)
assert late_block in s, 'late block not found'
replacement = "\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"
s = s.replace(late_block, replacement, 1)

old_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
new_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\nimport 'package:shared_preferences/shared_preferences.dart';\n"
assert old_top in s, 'top imports missing'
s = s.replace(old_top, new_top, 1)

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
    """// Smoke test for the KrishiAI root widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:krishiai/main.dart';

void main() {
  testWidgets('KrishiAI pumps without throwing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: KrishiAI()));
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
""",
    encoding='utf-8',
)

print('all edited')
