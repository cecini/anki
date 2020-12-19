
load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")
load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")
load("@build_bazel_rules_svelte//:defs.bzl", "rules_svelte_dependencies")
load("@com_github_ali5h_rules_pip//:defs.bzl", "pip_import")
load("//pip/pyqt5:defs.bzl", "install_pyqt5")

anki_version = "2.1.38"

def setup_deps():
    # pip_import and pip_install not support local wheel package,so how can i 
    # add depend?
    # how to http_arch /local repo /git repo / install_pyqt5/ py_wheel(how use)
    # 1. replicate the install_pyqt5 ,but dup code, first give up
    # 2. py_wheel

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

