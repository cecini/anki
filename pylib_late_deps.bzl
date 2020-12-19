"""Repo setup that can't happen until after defs.bzl:setup_deps() is run."""

#load("@npm//@bazel/labs:package.bzl", "npm_bazel_labs_dependencies")

# load("@py_deps//:requirements.bzl", "pip_install")
#load("@rules_python//python:pip.bzl", "pip_install")


def setup_late_deps():
    #pip_install(quiet=False, extra_pip_args=['-v','--no-binary regex,typed-ast,black'])
    pass
