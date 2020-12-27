load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@bazel_skylib//lib:versions.bzl", "versions")
#load("@io_bazel_rules_rust//rust:repositories.bzl", "rust_repositories")
load("@net_ankiweb_anki//cargo:crates.bzl", "raze_fetch_remote_crates")
load(":protobuf.bzl", "setup_protobuf_binary")
load("@toolchains//:toolchains_deps.bzl", toolchains_deps = "toolchains_deps")
load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")
load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")
load("@build_bazel_rules_svelte//:defs.bzl", "rules_svelte_dependencies")
# load the repo ,root dir target(file),s func protobuf-deps
# whi
#load("@com_github_ali5h_rules_pip//:defs.bzl", "pip_import")
load("//pip/pyqt5:defs.bzl", "install_pyqt5")
load("@rules_python//python:pip.bzl", "pip_install")
load("@rules_pyo3_repo//cargo:crates.bzl", "rules_pyo3_fetch_remote_crates")
load("@orjson_repo//:orjson_defs.bzl", orjson_setup_deps= "setup_deps")

anki_version = "2.1.39"

def setup_deps():
    bazel_skylib_workspace()

    #versions.check(minimum_bazel_version = "3.7.0")

    toolchains_deps()

   # rust_repositories(
   #     edition = "2018",
   #     #use_worker = True,
   #     # use_worker = True,
   #     #version = "1.48.0",
   #     #version = "1.47.0",
   #     version = "nightly",
#	iso_date = "2020-11-25",
#    )


   # # get local raze rust depend

    #setup_local_python(name = "python")
    #setup_local_python(name = "python", path = "/usr/local/python/bin/python" )

    #native.register_toolchains("@python//:python3_toolchain")
    #toolchains_setup_debugdeps()
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
# not support git+ path in requirements.txt 
#    pip_import(
#        name = "py_deps",
#        requirements = "@net_ankiweb_anki//pip:requirements.txt",
#        python_runtime = "@python//:python",
#    )
    pip_install(   # or pip3_import
        name = "py_deps",
        requirements = "@net_ankiweb_anki//pip:requirements.txt",
        python_interpreter_target = "@python//:python",
        timeout = 600,
        #extra_pip_args = ["--no-binary","orjson"],	    
        # doc
        # 
    # pip_import and pip_install not support local wheel package,so how can i 
    # add depend?
    # how to http_arch /local repo /git repo / install_pyqt5/ py_wheel(how use)
    # 1. replicate the install_pyqt5 ,but dup code, first give up
    # 2. py_wheel
    #	extra_pip_args = ["--no-cache-dir", "--no-binary", "orjson"],	

    )
    
    rules_pyo3_fetch_remote_crates()
    orjson_setup_deps()



    # just add BUILd in the pyqt5 ,not consume.
    # same as above ,but no install 
    install_pyqt5(
        name = "pyqt5",
        python_runtime = "@python//:python",
        #python_interpreter_target = "@python//:python",
    )

   # new_local_repository(
   #     name = "typedast",
   #     path = "/workspaces/typed_ast/build/bdist.linux-x86_64/wheel/typed_ast/",
   #	build_file = "//pip:BUILD.typed_ast",
   #   ) 
    node_repositories(package_json = ["@net_ankiweb_anki//ts:package.json"])

    yarn_install(
        name = "npm",
        package_json = "@net_ankiweb_anki//ts:package.json",
        yarn_lock = "@net_ankiweb_anki//ts:yarn.lock",
    )

    sass_repositories()

    rules_svelte_dependencies()
    # which have some pakcage,as http_archive, which need be consumed later.
    # some need BUILD file /for py_lib cc_lib etc.

