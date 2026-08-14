import pathlib
p = pathlib.Path('d:/EventSathi/krishiai/lib/presentation/providers/app_providers.dart')
b = p.read_bytes()
s = b.decode('utf-8').replace('\r\n', '\n')
idx = s.find("import 'package:go_router")
print(repr(s[idx-2:idx+520]))
