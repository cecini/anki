load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@bazel_skylib//lib:versions.bzl", "versions")
#load("@io_bazel_rules_rust//rust:repositories.bzl", "rust_repositories")
load("@net_ankiweb_anki//cargo:crates.bzl", "raze_fetch_remote_crates")
#load(":python.bzl", "setup_local_python")
load(":protobuf.bzl", "setup_protobuf_binary")
#load("@toolchains//:toolchains_defs.bzl", toolchains_setup_deps = "setup_deps")
load("@toolchains//:toolchains_deps.bzl", toolchains_deps = "toolchains_deps")
#load("@toolchains//:toolchains_defs.bzl", toolchains_setup_debugdeps = "setup_debugdeps", toolchains_setup_releasedeps = "setup_releasedeps")
load("@toolchains//:toolchains_defs.bzl", toolchains_setup_deps = "setup_deps")
#load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")
# load the repo ,root dir target(file),s func protobuf-deps
# whi
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@com_github_ali5h_rules_pip//:defs.bzl", "pip_import")
# packagename pip/pyqt5, label start //, @repo, target name is label
load("@rules_python//python:pip.bzl", "pip_install")
load("@rules_pyo3_repo//cargo:crates.bzl", "rules_pyo3_fetch_remote_crates")
load("@orjson_repo//:orjson_defs.bzl", orjson_setup_deps= "setup_deps")

anki_version = "2.1.38"

def setup_deps():
    bazel_skylib_workspace()

    versions.check(minimum_bazel_version = "3.7.0")

    toolchains_deps()
#    rust_repositories(
#        edition = "2018",
#        # use_worker = True,
#        #version = "1.48.0",
#        #version = "1.47.0",
#        version = "nightly",
#	iso_date = "2020-11-25",
#    )


#    # get local raze rust depend
#    raze_fetch_remote_crates()

    #setup_local_python(name = "python")

    #native.register_toolchains("@python//:python3_toolchain")
    #toolchains_setup_debugdeps()
    #toolchains_setup_debugdeps(pypath = "/Users/baojg/Downloads/code/cpython/python.exe")
    #toolchains_setup_deps(pypath = "/Users/baojg/bin/python310/bin/python")
    toolchains_setup_deps()
    raze_fetch_remote_crates()

    #should place the extension protobuf before the pip install ,
    # offical anki use later setup ,so no need consder this case.
    #protobuf_deps()
    setup_protobuf_binary(name = "com_google_protobuf")

    # need update to pip_install to import depend 
    # the requiremnt .tx use pip-compile 
    # package name pip!!!!!
    # can use as dep requirement()
    #  pip_import(
    #      name = "py_deps",
    #      requirements = "@net_ankiweb_anki//pip:requirements.txt",
    #      python_runtime = "@python//:python",
    #	#compile = True,
    #)
    # Create a central repo that knows about the dependencies needed for
    # requirements.txt.

    # can put in the repos/deps.bzl, because it create an center repo 
    # but need set python firsti,so put here
    # same as the defs.bzl in anki
    pip_install(   # or pip3_import
        name = "py_deps",
        requirements = "@net_ankiweb_anki//pip:requirements.txt",
        python_interpreter_target = "@python//:python",
        timeout = 600,
        #extra_pip_args = ["--no-binary","orjson"],	    
        # doc
        # 

    )
    rules_pyo3_fetch_remote_crates()
    orjson_setup_deps()


