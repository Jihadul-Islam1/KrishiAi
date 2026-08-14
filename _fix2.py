import pathlib, re
def read(p): return pathlib.Path(p).read_bytes().decode("utf-8").replace("\r\n","\n")
def write(p, s): pathlib.Path(p).write_bytes(s.encode("utf-8"))
prov = "d:/EventSathi/krishiai/lib/presentation/providers/app_providers.dart"
s = read(prov)
bad = "\nimport 'package:go_router/go_router.dart';\n\nimport '../router/app_router.dart';\n\n"
print("bad in s:", bad in s)
if bad in s: s = s.replace(bad, "\n", 1)
old_top = "import 'package:flutter_riverpod/flutter_riverpod.dart';\n"
new_top = old_top + "import 'package:go_router/go_router.dart';\n"
print("old_top in s:", old_top in s)
s = s.replace(old_top, new_top, 1)
old_rel = "import '../../services/speech_service.dart';\n"
new_rel = old_rel + "import '../router/app_router.dart';\n"
print("old_rel in s:", old_rel in s)
s = s.replace(old_rel, new_rel, 1)
write(prov, s)
print("providers ok")
router = "d:/EventSathi/krishiai/lib/presentation/router/app_router.dart"
rs = read(router)
assert "GoRouterRefreshNotifier(WidgetRef ref)" in rs, "router signature not found"
rs = rs.replace("GoRouterRefreshNotifier(WidgetRef ref)", "GoRouterRefreshNotifier(Ref ref)", 1)
rs = re.sub(r"\(_, _+\)", "(_, _)", rs)
write(router, rs)
print("router ok")
