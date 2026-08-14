import pathlib
p = pathlib.Path("d:/EventSathi/krishiai/lib/presentation/providers/app_providers.dart")
s = p.read_bytes().decode("utf-8").replace(chr(13)+chr(10), chr(10))
i = s.find("import 'package:go_router")
print(repr(s[i:i+520]))
print("ENDS_NL:", s.endswith(chr(10)))