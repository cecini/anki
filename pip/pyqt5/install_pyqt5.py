# based on https://github.com/ali5h/rules_pip/blob/master/src/whl.py
# MIT

"""downloads and parses info of a pkg and generates a BUILD file for it"""
import argparse
import glob
import logging
import os
import shutil
import sys
import re

from pip._internal.commands import create_command
from pip._vendor import pkg_resources

import pkginfo


def _create_nspkg_init(dirpath):
    """Creates an init file to enable namespacing"""
    if not os.path.exists(dirpath):
        # Handle missing namespace packages by ignoring them
        return
    nspkg_init = os.path.join(dirpath, "__init__.py")
    with open(nspkg_init, "w") as nspkg:
        nspkg.write("__path__ = __import__('pkgutil').extend_path(__path__, __name__)")


def install_package(pkg, directory, pip_args):
    # first sip-wheel build the debug wheel
    # then do below 

    # or sip-install the debug pkg, no pkg exist,other config option
    # or pip source install ,need qmake setting
    """Downloads wheel for a package. Assumes python binary provided has
    pip and wheel package installed. have pip and wheel package installed.


    Args:
        pkg: package name
        directory: destination directory to download the wheel file in
        python: python binary path used to run pip command
        pip_args: extra pip args sent to pip
    Returns:
        str: path to the wheel file
    """
    pip_args = [
    #    "--no-binary :all:",
        "--isolated",
        "--disable-pip-version-check",
        "--target",
        directory,
        "--no-deps",
        "--ignore-requires-python",
        pkg,
    ] + pip_args
    cmd = create_command("install")
    # install wheel pkg to the dir 
    cmd.main(pip_args)

    # need dist-info directory for pkg_resources to be able to find the packages
    dist_info = glob.glob(os.path.join(directory, "*.dist-info"))[0]
    # fix namespace packages by adding proper __init__.py files
    namespace_packages = os.path.join(dist_info, "namespace_packages.txt")
    if os.path.exists(namespace_packages):
        with open(namespace_packages) as nspkg:
            for line in nspkg.readlines():
                namespace = line.strip().replace(".", os.sep)
                if namespace:
                    _create_nspkg_init(os.path.join(directory, namespace))

    # PEP 420 -- Implicit Namespace Packages
    if (sys.version_info[0], sys.version_info[1]) >= (3, 3):
        for dirpath, dirnames, filenames in os.walk(directory):
            # we are only interested in dirs with no init file
            if "__init__.py" in filenames:
                dirnames[:] = []
                continue
            # remove bin and dist-info dirs
            for ignored in ("bin", os.path.basename(dist_info)):
                if ignored in dirnames:
                    dirnames.remove(ignored)
            _create_nspkg_init(dirpath)

    return pkginfo.Wheel(dist_info)

def _cleanup(directory, pattern):
    for p in glob.glob(os.path.join(directory, pattern)):
        shutil.rmtree(p)

fix_none = re.compile(r"(\s*None) =")

def copy_and_fix_pyi(source, dest):
    "Fix broken PyQt types."
    with open(source) as input_file:
        with open(dest, "w") as output_file:
            for line in input_file.readlines():
                line = fix_none.sub(r"\1_ =", line)
                output_file.write(line)

def merge_files(root, source):
    for dirpath, _dirnames, filenames in os.walk(source):
        target_dir = os.path.join(root, os.path.relpath(dirpath, source))
        if not os.path.exists(target_dir):
            os.mkdir(target_dir)
        for fname in filenames:
            source_path = os.path.join(dirpath, fname)
            target_path = os.path.join(target_dir, fname)
            if not os.path.exists(target_path):
                if fname.endswith(".pyi"):
                    copy_and_fix_pyi(source_path, target_path)
                else:
                    shutil.copy2(source_path, target_path)

# pip install wheel 
# pip install from sdist  need qmake path
# sip install from sdist 
def main():
    base = sys.argv[1]
    # pyqt5 have build the wheel debug using sipwheel,src from pip download
    # pyqtwebengqine 
    # last two pip --no-binary ,or install by pip 
    packages = [
#       ("pyqt5", "pyqt5==5.15.2"),
#       ("pyqtwebengine", "pyqtwebengine==5.15.2"),
       ("pyqt5", "/workspaces/PyQt5-5.15.1/wheelpack/PyQt5-5.15.1-cp39-cp39d-linux_x86_64.whl"),
       ("pyqtwebengine", "/workspaces/PyQtWebEngine-5.15.1/wheelpack/PyQtWebEngine-5.15.1-cp39-cp39d-linux_x86_64.whl"),
       ("pyqt5-sip", "pyqt5_sip==12.8.1"),
       ("pyqt-builder", "PyQt-builder==1.5.0"),
  #     ("typed-ast", "/workspaces/typed_ast/dist/typed_ast-1.4.1-cp39-cp39d-linux_x86_64.whl"),
  #     ("regex", "/workspaces/mrab-regex/dist/regex-2020.10.28-cp39-cp39d-linux_x86_64.whl"),
  #     ("black", "/workspaces/black/dist/black-20.8b2.dev46+g1d8b4d7-py3-none-any.whl"),
       # https://github.com/psf/black.git
    ]

    for (name, with_version) in packages:
        # install package in subfolder
        folder = os.path.join(base, "temp")
        # here sip pyqt5-sip pyqt-builder need pip install --no-cache-dir sip PyQt-builder PyQt5_sip --no-binary sip,PyQt-builder,PyQt5_sip

        _pkg = install_package(with_version, folder, [])
        # merge into parent
        merge_files(base, folder)
        shutil.rmtree(folder)

    # add missing py.typed file
    with open(os.path.join(base, "py.typed"), "w") as file:
        pass
    
    # create an buildfile in wheel 
    # https://github.com/bazelbuild/rules_python/blob/69f55c10e9a77e334800e6266ab43be0e320fa30/python/pip_install/extract_wheels/lib/bazel.py
    result = """
load("@rules_python//python:defs.bzl", "py_library")

package(default_visibility = ["//visibility:public"])

py_library(
    name = "pkg",
    srcs = glob(["**/*.py"]),
    data = glob(["**/*"], exclude = [
        "**/*.py",
        "**/*.pyc",
        "**/* *",
        "BUILD",
        "WORKSPACE",
        "bin/*",
        "__pycache__",
        # these make building slower
        "Qt/qml/**",
        "**/*.sip",
        "**/*.png",
    ]),
    # This makes this directory a top-level in the python import
    # search path for anything that depends on this.
    imports = ["."],
)
"""

    # clean up
    _cleanup(base, "__pycache__")

    # create  bazel target for the three library,only as one 
    with open(os.path.join(base, "BUILD"), "w") as f:
        f.write(result)


if __name__ == "__main__":
    main()
