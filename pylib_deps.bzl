"""Load dependencies needed to compile the pylib library as a 3rd-party consumer."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
#load("@rules_python//python:pip.bzl", "pip_install")

#def _maybe(rule, name, **kwargs):
#    if not native.existing_rule(name):
#        rule(name = name, **kwargs)


def pylib_deps():
    """Loads common dependencies needed to compile the pylib library."""

    maybe(
        http_archive,
        name = "bazel_skylib",
        sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.0.2/bazel-skylib-1.0.2.tar.gz",
        ],
    )
    # first install binary,then python pip install 
    maybe(
        http_archive,
        name = "com_google_protobuf",
        sha256 = "465fd9367992a9b9c4fba34a549773735da200903678b81b25f367982e8df376",
        strip_prefix = "protobuf-3.13.0",
        urls = [
            "https://github.com/protocolbuffers/protobuf/releases/download/v3.13.0/protobuf-all-3.13.0.tar.gz",
        ],
    )
    
   # load statement not at top level
   # load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")
   #  protobuf_deps()

    # rust
    ########

    maybe(
        git_repository,
        name = "io_bazel_rules_rust",
        commit = "dfd1200fcdcc0d56d725818ed3a66316517f20a6",
        remote = "https://github.com/ankitects/rules_rust",
        shallow_since = "1607578413 +1000",
    )

    # native.local_repository(
    #     name = "io_bazel_rules_rust",
    #     path = "../rules_rust",
    # )

    maybe(
        git_repository,
        name = "rules_python",
        commit = "3927c9bce90f629eb5ab08bbc99a3d3bda1d95c0",
        remote = "https://github.com/ankitects/rules_python",
        shallow_since = "1604408056 +1000",
    )

    maybe(
        git_repository,
        name = "com_github_ali5h_rules_pip",
        commit = "73953e06fdacb565f224c66f0683a7d8d0ede223",
        remote = "https://github.com/ankitects/rules_pip",
        shallow_since = "1606453171 +1000",
    )
#    maybe(
#        http_archive,
#        name = "build_bazel_rules_nodejs",
#        sha256 = "cd6c9880292fc83f1fd16ba33000974544b0fe0fccf3d5e15b2e3071ba011266",
#        urls = ["https://github.com/ankitects/rules_nodejs/releases/download/runfiles-fix-release/release.tar.gz"],
#    )
#
#    maybe(
#        http_archive,
#        name = "io_bazel_rules_sass",
#        sha256 = "6e60fc1cf0805af2cdcce727a5eed3f238fb4df41b35ce581c57996947c0202c",
#        strip_prefix = "rules_sass-1.26.12",
#        url = "https://github.com/bazelbuild/rules_sass/archive/1.26.12.zip",
#    )
#    maybe(
#        git_repository,
#        name = "build_bazel_rules_svelte",
#        commit = "c28cd9e5d251a0ce47c68a6a2a11b075f3df8899",
#        remote = "https://github.com/ankitects/rules_svelte",
#        shallow_since = "1603950453 +1000",
#    )
    # translations
    ################

    core_i18n_commit = "bd14d2c09e8b14123d37ff250ab4f7cca91be50d"
    core_i18n_shallow_since = "1607126494 +0000"

   # for the extra_ftl
    qtftl_i18n_commit = "19e28768f4e5ce5ec0cfb8639236a155de7224cf"
    qtftl_i18n_shallow_since = "1607126485 +0000"

    i18n_build_content = """
filegroup(
    name = "files",
    srcs = glob(["**/*.ftl"]),
    visibility = ["//visibility:public"],
)
exports_files(["l10n.toml"])
"""

    maybe(
        new_git_repository,
        name = "rslib_ftl",
        build_file_content = i18n_build_content,
        commit = core_i18n_commit,
        shallow_since = core_i18n_shallow_since,
        remote = "https://github.com/ankitects/anki-core-i18n",
    )

    maybe(
        new_git_repository,
        name = "extra_ftl",
        build_file_content = i18n_build_content,
        commit = qtftl_i18n_commit,
        shallow_since = qtftl_i18n_shallow_since,
        remote = "https://github.com/ankitects/anki-desktop-ftl",
    )

# how add this depend     
#load("@py_deps//:requirements.bzl", "requirement")
#load("//pylib:protobuf.bzl", "py_proto_library_typed")
#load("//:defs.bzl", "anki_version")

    maybe(
        native.local_repository,
	name = "rules_pyo3_repo",
        path = "/workspaces/rules_pyo3",
    )

    maybe(
        native.local_repository,
	name = "orjson_repo",
        path = "/workspaces/orjson",
    )
