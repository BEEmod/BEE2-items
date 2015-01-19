''' This converts each folder in packages/ into a zip, saving the zips into zips/. This way it's easy to edit them.'''
import os
import os.path
from zipfile import ZipFile

# Skip these files, if they exist in the source folders.
# Users won't need them.
SKIPPED_EXTENSIONS = ('vmx', 'log', 'bsp', 'prt', 'lin')

zip_path = os.path.join(os.getcwd(), 'zips/')
if not os.path.isdir(zip_path):
    os.makedirs(zip_path)

path = os.path.join(os.getcwd(), 'packages\\')
for package in os.listdir(path):
    if os.path.isdir(os.path.join(path, package)):
        print('| ' + package + '.zip')
        package_path = os.path.join(path, package)
        pack_zip_path = os.path.join(zip_path, package)
        zip = ZipFile(pack_zip_path + '.zip', 'w')
        for base, dirs, files in os.walk(package_path):
            for file in files:
                full_path = os.path.normpath(os.path.join(base, file))
                rel_path = os.path.relpath(full_path, package_path)
                if file[-3:] in SKIPPED_EXTENSIONS:
                    print('X   \\' + rel_path)
                    continue
                print('    \\' +rel_path)
                
                zip.write(full_path, rel_path)
        print('')