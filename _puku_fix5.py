import pathlib

root = pathlib.Path("d:/EventSathi/krishiai")

def read(p):
    return p.read_bytes().decode("utf-8").replace(chr(13)+chr(10), chr(10))

def write(p, s):
    p.write_bytes(s.replace(chr(13)+chr(10), chr(10)).encode("utf-8"))

prov = root / "lib" / "presentation" / "providers" / "app_providers.dart"
s = read(prov)

N = "
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';

/// -" + ("-" * 75) + "
/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so
/// it rebuilds when those values change).
/// -" + ("-" * 75) + "
final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));
"

assert N in s, "needle not found"
R = "
final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));
"
s = s.replace(N, R, 1)

A = "import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
"
B = "import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
"
assert A in s
s = s.replace(A, B, 1)

C = "import '../../services/speech_service.dart';
"
D = "import '../../services/speech_service.dart';
import '../router/app_router.dart';
"
assert C in s
s = s.replace(C, D, 1)

write(prov, s)

router = root / "lib" / "presentation" / "router" / "app_router.dart"
rs = read(router)
assert "GoRouter buildRouter(WidgetRef ref)" in rs
rs = rs.replace("GoRouter buildRouter(WidgetRef ref)", "GoRouter buildRouter(Ref ref)", 1)
write(router, rs)

test = root / "test" / "widget_test.dart"
test.write_text(
    "// Smoke test for the KrishiAI root widget.

"
    "import 'package:flutter/material.dart';
"
    "import 'package:flutter_riverpod/flutter_riverpod.dart';
"
    "import 'package:flutter_test/flutter_test.dart';

"
    "import 'package:krishiai/main.dart';

"
    "void main() {
"
    "  testWidgets('KrishiAI pumps without throwing', (WidgetTester tester) async {
"
    "    await tester.pumpWidget(const ProviderScope(child: KrishiAI()));
"
    "    await tester.pump();
"
    "    expect(find.byType(MaterialApp), findsOneWidget);
"
    "  });
"
    "}
",
    encoding="utf-8",
)

print("all edited")
