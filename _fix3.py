import pathlib
p = pathlib.Path("d:/EventSathi/krishiai/lib/presentation/screens/farm/my_crops_screen.dart")
s = p.read_text()
import_line = "import '../../../core/utils/date_utils.dart';\n"
print("present:", import_line in s)
if import_line in s:
    s = s.replace(import_line, "")
    p.write_text(s)
    print("removed")
