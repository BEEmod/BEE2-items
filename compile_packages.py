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
                    hammer_path = os.path.join('zips/hammer/', hammer_path)
                    os.makedirs(os.path.dirname(hammer_path), exist_ok=True)

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
    parser.add_argument("-o", "--output", default=None,
                        help="Will specify an output folder, otherwise \"./zips\" will be used.", dest="output")
    # since after moving output files to output destination (specified above), there remains lot of junk files
    # that looks like was for debugging and its safe to delete them. specifying this option will prevent that.
    parser.add_argument("-p", "--preserve-temp", action="store_const", const=True, default=False,
                        help="Will not delete temporary and hammer files (you probably won't need hammer files "
                             "if you are not planning to use hammer)", dest="preserve_temp")
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
    global OPTIMISE
    OPTIMISE = args.optimize
    do_zip = args.zip
    if not args.skip_confirm:
        print("You specified these folders:")
        print("\n".join(inp_list))
        # shows list with all files specified (in case using CLI is not
        # so intuitive), also tells if you have chosen to optimize output (below)
        print("These will be optimized" if OPTIMISE else "These will NOT be optimized")
        if not conv_bool(input("Continue? (y/n) ")):
            sys.exit(0)             # confirmation just in case

    # will dump all temporary files to 'zips' folder. also, all compiled packages will be left in
    # zips/sml or zips/lrg depending on whether you chose to optimize it or not
    zip_path = os.path.join(
        os.getcwd(),
        'zips',
        'sml' if OPTIMISE else 'lrg',
    )

    # if there is no such dir, then create it. if there is, and its empty,
    # then use it. if there is and its not empty - throw error (since whole directory will be erased)
    if os.path.isdir(zip_path):
        if os.listdir(zip_path):
            raise ValueError("The output directory is not empty")
    else:
        os.makedirs(zip_path, exist_ok=True)

    # yield will return found packages one by one, so it is easy to iterate them
    # without the need to process everything at once
    for package in search_list_of_dirs(inp_list, zip_path):
        build_package(*package)
    print('Done!')

    # confusing section, determining whether it need to create main zip and how to name it if not specified
    # makes it blank by default
    pack_name = ""
    if do_zip is None:
        if conv_bool(input("Zip it all in one file? (y/n) ")):
            pack_name = 'BEE{}_packages.zip'.format(input('Version: '))
    else:
        pack_name = do_zip      # do_zip also can be blank
    # if pack_name remained blank to this stage, then no zip will be created
    if pack_name != "":
        print('Building main zip...')
        with ZipFile(os.path.join('zips', pack_name), 'w', compression=ZIP_DEFLATED) as zip_file:
            for file in os.listdir(zip_path):
                zip_file.write(os.path.join(zip_path, file), os.path.join('packages/', file))
                print('.', end='', flush=True)
        print('Done!')
        if output is not None:
            print("Moving zip to output destination")
            shutil.move(os.path.join('zips', pack_name), output)
            print('Done!')
            if not args.preserve_temp:
                print("Deleting temporary and hammer files")
                shutil.rmtree("zips")
                print("Done!")
        else:
            if not args.preserve_temp:
                print("Deleting temporary and hammer files")
                shutil.rmtree("zips/hammer")
                if OPTIMISE:
                    shutil.rmtree("zips/sml")
                else:
                    shutil.rmtree("zips/lrg")
                print("Done!")
    else:
        # dont make zip
        if output is not None:
            print("Moving files to output destination")
            if OPTIMISE:
                shutil.move("zips/sml", output)
            else:
                shutil.move("zips/lrg", output)
            if not args.preserve_temp:
                print("Deleting temporary and hammer files")
                shutil.rmtree("zips")
                print("Done!")
        else:
            if not args.preserve_temp:
                print("Deleting hammer files")
                shutil.rmtree("zips/hammer")
                print("Done!")


if __name__ == '__main__':
    main()
