import pathlib, re
p = pathlib.Path('d:/EventSathi/krishiai/lib/presentation/providers/app_providers.dart')
s = p.read_bytes().decode('utf-8').replace('\r\n', '\n')
needle = "\nimport 'package:go_router/go_router.dart';\n\nimport '../router/app_router.dart';\n\n/// -------------------------------------------------------------------------\n/// Router (depends on onboardingCompleteProvider + currentFarmerProvider, so\n/// it rebuilds when those values change).\n/// -------------------------------------------------------------------------\nfinal routerProvider = Provider<GoRouter>((ref) => buildRouter(ref));\n"
print("found:", needle in s)
print("len:", len(needle))
idx = s.find(needle)
print("idx:", idx)
if idx >= 0:
    print(repr(s[idx:idx+len(needle)+10]))
