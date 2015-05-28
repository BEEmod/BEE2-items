# coding=utf-8
"""
This script applies any changes made to the game files to matching resources
in any packages.
"""
import os
import shutil
import sys

# Location of Portal 2
GAME_FOLDER = r'F:\SteamLibrary\SteamApps\common\Portal 2'
EXTRA_FILE_LOC = 'extra_files'

# Skip these files, if they exist in the source folders.
# Users won't need them.
SKIPPED_EXTENSIONS = ('vmx', 'log', 'bsp', 'prt', 'lin')

resource_paths = set()

def check_file(pack_path, rel_path):
    if rel_path.startswith('instances'):
        game_path = os.path.join(
            GAME_FOLDER,
            'sdk_content',
            'maps',
            'instances',
            'bee2',
            rel_path[10:],
        )
    else:
        game_path = os.path.join(GAME_FOLDER, 'bee2_dev', rel_path)
    if os.path.isfile(game_path):
        print('Applying changes to "{}"'.format(rel_path))
        shutil.copyfile(game_path, pack_path)
    else:
        print('Removing "{}"'.format(rel_path), file=sys.stderr)
        os.remove(pack_path)

def do_folder(path):
    """Check a folder to see if it's a package.

    If it is, check any resources.
    """
    for package in os.listdir(path):
        package_path = os.path.join(path, package)
        if os.path.isdir(package_path):
            if os.path.isfile(os.path.join(package_path,'info.txt')):
                res_folder = os.path.join(package_path, 'resources')
                if not os.path.isdir(res_folder):
                    print('Package has no resources!')
                for base, dirs, files in os.walk(res_folder):
                    if base == res_folder:
                        # For the root, stop us from looking in the BEE2 folder
                        for ind, folder in enumerate(dirs):
                            if folder.casefold() == 'bee2':
                                del dirs[ind]
                                break
                        continue
                    for file in files:
                        full_path = os.path.normpath(os.path.join(base, file))
                        rel_path = os.path.relpath(full_path, res_folder)
                        resource_paths.add(rel_path.casefold())
                        check_file(
                            full_path,
                            rel_path,
                        )
            else:
                do_folder(package_path)

def check_extra(game_subfolder, set_prefix):
    full_folder = os.path.join(GAME_FOLDER, game_subfolder)
    for base, dirs, files in os.walk(full_folder):
        for file in files:
            if file[-3:] in SKIPPED_EXTENSIONS:
                continue
            full_path = os.path.normpath(os.path.join(base, file))
            rel_path = os.path.relpath(full_path, full_folder)
            if os.path.join(set_prefix, rel_path).casefold() not in resource_paths:
                print('Extra file: "{}"'.format(
                    os.path.join(set_prefix, rel_path)
                ))
                dest = os.path.join(EXTRA_FILE_LOC, set_prefix, rel_path)
                os.makedirs(os.path.dirname(dest), exist_ok=True)
                shutil.copy(full_path, dest)

if __name__ == '__main__':
    do_folder(os.path.join(os.getcwd(), 'packages'))
    print('Cleaning extra_files\\!')
    shutil.rmtree(EXTRA_FILE_LOC + '/', ignore_errors=True)
    print('Done!')
    check_extra('bee2_dev\\models\\', 'models')
    check_extra('bee2_dev\\materials\\', 'materials')
    check_extra('bee2_dev\\sounds\\', 'sounds')
    check_extra('bee2_dev\\scripts\\', 'scripts')
    check_extra('sdk_content\\maps\\instances\\bee2', 'instances')
    print('Complete!')