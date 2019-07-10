from srctools import VPK, VTF
from pathlib import Path
from io import BytesIO
from PIL import Image
import os

vpk = VPK(str(Path(os.environ['PORTAL_2_LOC'], 'portal2/pak01_dir.vpk'))
for info in vpk:
    if not info.dir.startswith('materials/signage') or info.ext != 'vtf':
        continue
    if 'signage' not in info._filename:
        continue

    file = BytesIO(info.read())
    vtf = VTF.read(file)
    img = vtf.to_PIL(0)
    img.convert('RGB').resize((64, 64), Image.LANCZOS).save('spr/' + Path(info.filename).stem + '.png')
    print(info.filename, vtf.format)
