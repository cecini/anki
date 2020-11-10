"""Repo setup that can't happen until after defs.bzl:setup_deps() is run."""

load("@py_deps//:requirements.bzl", "pip_install")
load("@npm//@bazel/labs:package.bzl", "npm_bazel_labs_dependencies")

def setup_late_deps():
    #pip_install(quiet=False, extra_pip_args=['-v','--no-binary regex,typed-ast,black'])
    #pip_install(quiet=False, extra_pip_args=['-v','--no-binary=regex,typed-ast,git+https://github.com/psf/black.git@master#egg=black'])
    # from load("@com_github_ali5h_rules_pip//:defs.bzl", "whl_library") !!!!
    #pip_install(pip_args=['-v','--no-binary=regex','--no-binary=typed-ast','--no-binary=git+https://github.com/psf/black.git@master#egg=black'])
    #pip_install(pip_args=['--no-binary=regex','--no-binary=typed-ast','--no-binary=git+https://github.com/psf/black.git@master#egg=black'])
    pip_install(pip_args=[])
    #pip_install(quiet=False, extra_pip_args=['-v','--no-binary=regex'])
    npm_bazel_labs_dependencies()
