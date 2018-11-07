import os
import shutil
from pathlib import Path

output = Path('../corridor_out/')
conv = {
	'Coop/exit': 'coop',
	'Singleplayer/entrance': 'sp_entry',
	'Singleplayer/exit': 'sp_exit',
}

for style in Path().iterdir():
	if 'py' in style.name:
		continue
	for frm, to in conv.items():
		for src in (style / frm).iterdir():
			dest = output / style / to
			os.makedirs(dest, exist_ok=True)
			shutil.copyfile(src, dest / src.name)