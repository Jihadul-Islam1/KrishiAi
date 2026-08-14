import pathlib
root = pathlib.Path('d:/EventSathi/krishiai')
def read(p): return p.read_bytes().decode('utf-8')
def write(p, s): p.write_bytes(s.encode('utf-8'))

# 1) Fix app_providers.dart: remove misplaced imports, add them at top
prov = root / 'lib' / 'presentation' / 'providers' / 'app_providers.dart'
s = read(prov)
# Remove the three stray import lines (and their trailing blank line)
bad = "\nimport 'package:go_router/go_router.dart';\n\nimport '../router/app_router.dart';\n\n"
assert bad in s, 'stray imports not found'
s = s.replace(bad, '\n', 1)
# Add go_router import after flutter_riverpod import
old_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
new_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\nimport 'package:go_router/go_router.dart';\n"
assert old_top in s
s = s.replace(old_top, new_top, 1)
# Add app_router relative import after speech_service import
old_rel = "import '../../services/speech_service.dart';\n"
new_rel = "import '../../services/speech_service.dart';\nimport '../router/app_router.dart';\n"
assert old_rel in s
s = s.replace(old_rel, new_rel, 1)
write(prov, s)
print('providers fixed')

# 2) Fix app_router.dart: change WidgetRef to Ref, and (_, __) to (_, _)
router = root / 'lib' / 'presentation' / 'router' / 'app_router.dart'
rs = read(router)
assert 'GoRouterRefreshNotifier(WidgetRef ref)' in rs
rs = rs.replace('GoRouterRefreshNotifier(WidgetRef ref)', 'GoRouterRefreshNotifier(Ref ref)', 1)
# Replace all (_, __) with (_, _) and (_, ___) with (_, _) etc.
import re
# pattern: parenthesised parameter list like (_, __) or (_, ___)
rs = re.sub(r'\(_, _+\)', '(_, _)', rs)
write(router, rs)
print('router fixed')
