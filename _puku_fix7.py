import pathlib
root = pathlib.Path("d:/EventSathi/krishiai")
NL = chr(10)

def read(p):
    return p.read_bytes().decode("utf-8").replace(chr(13)+chr(10), NL)

def write(p, s):
    p.write_bytes(s.replace(chr(13)+chr(10), NL).encode("utf-8"))

prov = root / "lib" / "presentation" / "providers" / "app_providers.dart"
s = read(prov)

prefix = NL + "import 'package:go_router/go_router.dart';" + NL + NL + "import '../router/app_router.dart';" + NL + NL
suffix_needle = ("/// -" + ("-" * 75) + NL
                 + "/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so" + NL
                 + "/// it rebuilds when those values change)." + NL
                 + "/// -" + ("-" * 75) + NL
                 + "final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));")

i = s.find(prefix)
assert i >= 0, "prefix not found"
j = s.find(suffix_needle, i)
assert j >= 0, "suffix not found after prefix"
# j points at the opening dash row of the suffix. Replacement: drop everything
# from j to the end and re-insert just the routerProvider.
s = s[:i] + NL + "final routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));" + NL + s[j + len(suffix_needle):]

A = "import 'package:flutter_riverpod/flutter_riverpod.dart';" + NL + "import 'package:shared_preferences/shared_preferences.dart';" + NL
B = "import 'package:flutter_riverpod/flutter_riverpod.dart';" + NL + "import 'package:go_router/go_router.dart';" + NL + "import 'package:shared_preferences/shared_preferences.dart';" + NL
assert A in s
s = s.replace(A, B, 1)

C = "import '../../services/speech_service.dart';" + NL
D = "import '../../services/speech_service.dart';" + NL + "import '../router/app_router.dart';" + NL
assert C in s
s = s.replace(C, D, 1)

write(prov, s)

router = root / "lib" / "presentation" / "router" / "app_router.dart"
rs = read(router)
assert "GoRouter buildRouter(WidgetRef ref)" in rs
rs = rs.replace("GoRouter buildRouter(WidgetRef ref)", "GoRouter buildRouter(Ref ref)", 1)
write(router, rs)

test = root / "test" / "widget_test.dart"
parts = [
    "// Smoke test for the KrishiAI root widget.", NL, NL,
    "import 'package:flutter/material.dart';", NL,
    "import 'package:flutter_riverpod/flutter_riverpod.dart';", NL,
    "import 'package:flutter_test/flutter_test.dart';", NL, NL,
    "import 'package:krishiai/main.dart';", NL, NL,
    "void main() {", NL,
    "  testWidgets('KrishiAI pumps without throwing', (WidgetTester tester) async {", NL,
    "    await tester.pumpWidget(const ProviderScope(child: KrishiAI()));", NL,
    "    await tester.pump();", NL,
    "    expect(find.byType(MaterialApp), findsOneWidget);", NL,
    "  });", NL,
    "}", NL,
]
test.write_text("".join(parts), encoding="utf-8")

print("all edited")