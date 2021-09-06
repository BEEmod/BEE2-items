"""This converts each folder in packages/ into a zip, saving the zips into zips/.

This way it's easy to edit them.
Additionally all resources are saved into zips/resources.zip.
"""
import os
import shutil
import sys
import itertools
from zipfile import ZipFile, ZIP_LZMA, ZIP_DEFLATED

from srctools import Property, KeyValError, VMF, Entity, conv_bool
import argparse

OPTIMISE = False
# path to a folder, where all useful hammer files will be created, if it stated that they need to be created
HAMMER_PATH = None


def clean_vmf(vmf_path):
    """Optimise the VMFs, removing unneeded entities or objects."""
    inst = VMF.parse(vmf_path)

    for ent in itertools.chain([inst.spawn], inst.entities[:]):  # type: Entity
        # Remove comments
        ent.comments = ''

        # Remove entities that have their visgroups hidden.
        if ent.hidden or not ent.vis_shown:
            print('Removing hidden ent')
            inst.remove_ent(ent)
            continue

        # Remove hammer_notes entities
        if ent['classname'] == 'hammer_notes':
            print('Removing hammer_notes...')
            inst.remove_ent(ent)
            continue

        # All instances must be in bee2/, so any reference outside there is a map error!
        # It's ok if it's in p2editor and not in a subfolder though.
        # There's also an exception needed for the Tag gun instance.
        if ent['classname'] == 'func_instance':
            inst_loc = ent['file'].casefold().replace('\\', '/')
            if not inst_loc.startswith('instances/bee2/') and not (
                    inst_loc.startswith('instances/p2editor/') and inst_loc.count(
                    '/') == 2) and 'alatag' not in inst_loc:
                input('Invalid instance path "{}" in\n"{}"! Press Enter to continue..'.format(ent['file'], vmf_path))
                yield from clean_vmf(vmf_path)  # Re-run so we check again..

        for solid in ent.solids[:]:
            if all(face.mat.casefold() == 'tools/toolsskip' for face in solid):
                print('Removing SKIP brush')
                ent.solids.remove(solid)
                continue

            if solid.hidden or not solid.vis_shown:
                print('Removing hidden brush')
                ent.solids.remove(solid)
                continue

    for detail in inst.by_class['func_detail']:
        # Remove several unused default options from func_detail.
        # We're not on xbox!
        del detail['disableX360']
        # These aren't used in any instances, and it doesn't seem as if
        # VBSP preserves these values anyway.
        del detail['maxcpulevel'], detail['mincpulevel']
        del detail['maxgpulevel'], detail['mingpulevel']

    # Since all VMFs are instances or similar (not complete maps), we'll never
    # use worldspawn's settings. Keep mapversion though.
    del inst.spawn['maxblobcount'], inst.spawn['maxpropscreenwidth']
    del inst.spawn['maxblobcount'],
    del inst.spawn['detailvbsp'], inst.spawn['detailmaterial']

    lines = inst.export(inc_version=False, minimal=True).splitlines()
    for line in lines:
        yield line.lstrip()


# Delete these files, if they exist in the source folders.
# Users won't need them.
DELETE_EXTENSIONS = ['vmx', 'log', 'bsp', 'prt', 'lin']


def search_list_of_dirs(list_of_dirs, zip_path):
    """Search the given list of folders for packages
    
    zip_path is the folder the zips will be saved in, 
    and list_of_dirs is the list of locations to search.
    returns pairs (original_file_path, result_zip_path)
    """
    for dir_path in list_of_dirs:
        if not os.path.isdir(dir_path):  # it's a file
            continue
        if 'info.txt' not in os.listdir(dir_path):  # it's a folder, probably with packages
            # go search its contents
            yield from search_list_of_dirs([os.path.join(dir_path, i) for i in os.listdir(dir_path)], zip_path)
            continue

        # do not preserve original file structure, dump all found packs in root of zip_path
        pack_name = os.path.split(dir_path)[-1]
        pack_zip_path = os.path.join(zip_path, pack_name) + ".bee_pack"
        print('| ' + pack_name + '.bee_pack')

        yield dir_path, pack_zip_path


def build_package(package_path, pack_zip_path):
    """Build the packages in a given folder."""
    global HAMMER_PATH

    zip_file = ZipFile(
        pack_zip_path,
        'w',
        compression=ZIP_LZMA,
    )

    print('Starting on "{}"'.format(package_path))
    with zip_file:
        for base, dirs, files in os.walk(package_path):
            for file in files:
                full_path = os.path.normpath(os.path.join(base, file))
                rel_path = os.path.relpath(full_path, package_path)
                if file[-3:] in DELETE_EXTENSIONS:
                    print('\nX   \\' + rel_path)
                    os.remove(full_path)
                    continue

                hammer_path = os.path.relpath(rel_path, 'resources/')
                if hammer_path.startswith('..'):
                    hammer_path = None
                elif hammer_path.casefold().startswith(('bee2', 'instances')):
                    # Skip icons and instances
                    hammer_path = None
                elif 'props_map_editor' in hammer_path:
                    # Skip editor models
                    hammer_path = None
                elif 'puzzlemaker' in hammer_path:
                    # Skip editor models
                    hammer_path = None
                elif 'music' in rel_path.casefold():
                    # Skip music files..
                    hammer_path = None
                else:
                    # if this files can be added to HAMMER_PATH folder,
                    # check if this folder was specified (because if its not,
                    # then you should not create hammer files)
                    if HAMMER_PATH is not None:
                        hammer_path = os.path.join(HAMMER_PATH, hammer_path)
                        os.makedirs(os.path.dirname(hammer_path), exist_ok=True)
                    else:
                        hammer_path = None
                # yea, if at this point hammer_path is None, then file we currently looking at do not
                # need to be put into a HAMMER_PATH folder (including every case)

                print('.', end='', flush=True)
                
                if OPTIMISE and file.endswith('.vmf'):
                    print(rel_path)
                    data = '\r\n'.join(clean_vmf(full_path))
                    zip_file.writestr(rel_path, data)

                    if hammer_path:
                        with open(hammer_path, 'w') as f:
                            f.write(data)
                else:
                    zip_file.write(full_path, rel_path)

                    if hammer_path:
                        shutil.copy(full_path, hammer_path)

        print('')
    print('Finished "{}"'.format(package_path))


def main():
    parser = argparse.ArgumentParser(description="This is package compiler, which can compress packages "
                                                 "in order for them to be lighter. "
                                                 "Also provides an option to optimize them.\n"
                                                 "IMPORTANT NOTE: your packages should NOT be zipped before "
                                                 "compilation, also they should all have different names, "
                                                 "since they all will be dumped in the same directory.")
    # argument that accepts one or more filepaths that then will be recursively searched and
    # compiled all found stuff
    parser.add_argument("input", nargs="+",
                        help="Specifies an input path or several input paths. If an input path is a "
                             "single package, then it will be compiled, otherwise, if an input path is "
                             "a folder, then it will be recursively searched for packages, and will compile "
                             "all it finds")
    # will give args.optimize True value is specified, False otherwise;
    parser.add_argument("-op", "--optimize", action="store_const", const=True, default=False,
                        help="Will optimize zips (not recommended and may make packages "
                             "unloadable for bee in current version).", dest="optimize")
    # will give args.skip_confirm True value is specified, False otherwise;
    parser.add_argument("-c", "--confirm", action="store_const", const=True, default=False,
                        help="Will skip a confirmation prompt.", dest="skip_confirm")
    # will specify an output path. if not specified, args.output will be set to None, and nothing will be moved then
    parser.add_argument("-o", "--output", default="zips",
                        help="Will specify an output folder, otherwise \"./zips\" will be used.", dest="output")
    # during packing files, it can create several useful hammer files, which will be placed in specified directory,
    # or won't be created if not specified
    parser.add_argument("-hp", "--hammer_path", default=None,
                        help="Will create some useful files, which you can use in hammer later. "
                             "All files will be stored in specified directory.", dest="hammer")
    # if NOT specified, then args.zip will be set to None, if specified BUT NOT set to any string value, then
    # args.zip will be set to "" (empty string). Later, if args.zip remains set to "", then no zip will be created
    parser.add_argument("--zip", nargs="?", default=None, const="",
                        help="Will put all generated files in one zip. Also skips the prompt at the end. "
                             "Using this option with a string, followed after it, will create a zip with a "
                             "specified name. Using this option without a string will just skip prompt "
                             "without creating zip. Not using this option will generate a prompt at the end",
                        dest="zip")
    # if there is something left inside parse_args() brackets, then probably i forgot to remove after debugging
    args = parser.parse_args()
    inp_list = args.input
    output = args.output
    global OPTIMISE, HAMMER_PATH
    OPTIMISE = args.optimize
    do_zip = args.zip
    HAMMER_PATH = args.hammer
    if not args.skip_confirm:
        # shows list with all files specified (in case using CLI is not so intuitive)
        print("You specified these folders:\n-------------------------------")
        for inp in inp_list:
            print("|", inp)
        print("-------------------------------")
        print("Selected options:")
        print("* Optimization: " + ("ON" if OPTIMISE else "OFF"))
        print("* Output folder: \"" + output + "\"")
        print("* Hammer folder: " + ("OFF" if (HAMMER_PATH is None) else ("\"" + HAMMER_PATH + "\"")))
        print("* Final zip: " + ("skip prompt" if do_zip == "" else
                                 ("not skip prompt" if do_zip is None else
                                  do_zip)))
        print()
        if not conv_bool(input("---> Continue? (y/n) ")):
            sys.exit(0)             # confirmation just in case

    zip_path = output

    # if there is no such dir, then create it. if there is, and its empty,
    # then use it. if there is and its not empty - throw error (since whole directory will be erased)
    if os.path.isdir(zip_path):
        if os.listdir(zip_path):
            raise ValueError("The output directory is not empty")
    else:
        os.makedirs(zip_path, exist_ok=True)

    # if hammer path was specified then
    if HAMMER_PATH:
        # if there is no such dir, then create it. if there is, and its empty,
        # then use it. if there is and its not empty - throw error (why not)
        if os.path.isdir(HAMMER_PATH):
            if os.listdir(HAMMER_PATH):
                raise ValueError("The hammer files directory is not empty")
        else:
            os.makedirs(HAMMER_PATH, exist_ok=True)

    packages_list = []      # list with filenames of all packages
    # yield will return found packages one by one, so it is easy to iterate them
    # without the need to process everything at once
    for package in search_list_of_dirs(inp_list, zip_path):
        # package is a tuple (raw_package_directory, path_to_compiled_version)
        packages_list.append(os.path.relpath(package[1], zip_path))
        build_package(*package)
    print('Done!')

    # confusing section, determining whether it need to create main zip and how to name it if not specified
    # makes it blank by default
    pack_name = ""
    if do_zip is None:
        if conv_bool(input("Zip it all in one file? (y/n) ")):
            pack_name = 'BEE2_v{}_packages.zip'.format(input('Version: '))
    else:
        pack_name = do_zip      # do_zip also can be blank
        # if its not blank, and not ending with .zip, then add .zip to filename
        if pack_name and pack_name[-4:] != ".zip":
            pack_name += ".zip"
    # if pack_name remained blank to this stage, then no zip will be created
    if pack_name != "":
        print('Building main zip...')
        with ZipFile(os.path.join(zip_path, pack_name), 'w', compression=ZIP_DEFLATED) as zip_file:
            for file in packages_list:
                # previously it put in zip all contains of a folder, including itself (no clue why it
                # haven't raised any error), also, since hammer files do not need to appear in zip,
                # packages_list variable was created
                zip_file.write(os.path.join(zip_path, file), os.path.join('packages/', file))
                print('.', end='', flush=True)
        print('Done!')
        print("Deleting unzipped files...")
        # removes all files that are in packages_list var
        for file in packages_list:
            os.remove(os.path.join(zip_path, file))
        print("Done!")
    else:
        # dont make zip
        # we dont actually need to do anything else
        pass


if __name__ == '__main__':
    main()
