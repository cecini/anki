load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")
load("@bazel_skylib//lib:versions.bzl", "versions")
load("@io_bazel_rules_rust//rust:repositories.bzl", "rust_repositories")
load("@io_bazel_rules_rust//:workspace.bzl", "bazel_version")
load("@net_ankiweb_anki//cargo:crates.bzl", "raze_fetch_remote_crates")
load(":python.bzl", "setup_local_python")
load("@build_bazel_rules_nodejs//:index.bzl", "node_repositories", "yarn_install")
load("@io_bazel_rules_sass//:defs.bzl", "sass_repositories")
load("@build_bazel_rules_svelte//:defs.bzl", "rules_svelte_dependencies")
# load the repo ,root dir target(file),s func protobuf-deps
# whi
load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
load("@com_github_ali5h_rules_pip//:defs.bzl", "pip_import")
# packagename pip/pyqt5, label start //, @repo, target name is label
load("//pip/pyqt5:defs.bzl", "install_pyqt5")

anki_version = "2.1.36"

def setup_deps():
    bazel_skylib_workspace()

    versions.check(minimum_bazel_version = "3.7.0")

    rust_repositories(
        edition = "2018",
        # use_worker = True,
        #version = "1.47.0",
        version = "nightly",
	iso_date = "2020-10-24",
    )

    bazel_version(name = "io_bazel_rules_rust_bazel_version")

    # rust depend
    raze_fetch_remote_crates()

    setup_local_python(name = "python")

    native.register_toolchains("@python//:python3_toolchain")

    # need update to pip_install to import depend 
    # the requiremnt .tx use pip-compile 
    # package name pip!!!!!
    pip_import(
        name = "py_deps",
        requirements = "@net_ankiweb_anki//pip:requirements.txt",
        python_runtime = "@python//:python",
	#compile = True,
    )

    # just add BUILd in the pyqt5 ,not consume.
    install_pyqt5(
        name = "pyqt5",
        python_runtime = "@python//:python",
    )

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

    protobuf_deps()
