"""Load dependencies needed to compile the pylib library as a 3rd-party consumer."""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")


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
	sha256 = "6dd0f6b20094910fbb7f1f7908688df01af2d4f6c5c21331b9f636048674aebf",
        strip_prefix = "protobuf-3.14.0",
        urls = [
            "https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/protobuf-all-3.14.0.tar.gz",
        ],
    )    
    
    # this dep should put in the toolchains ,but transitive dep not to add ,we should later add .
    # rust
    ########

    native.local_repository(
        name = "io_bazel_rules_rust",
        path = "../rules_rust",
    )

    #maybe(
    #    git_repository,
    #    name = "io_bazel_rules_rust",
    #    commit = "dfd1200fcdcc0d56d725818ed3a66316517f20a6",
    #    remote = "https://github.com/ankitects/rules_rust",
    #    shallow_since = "1607578413 +1000",
    #)
    native.local_repository(
        name = "toolchains",
	path = "../toolchains",
    )

   # maybe(
   #     git_repository,
   #     name = "toolchains",
   #     commit = "036eb1bee43572d9d20f3b3d5dedb322bf1f2805",
   #     remote = "https://github.com/cecini/toolchains.git",
   #     #shallow_since = "1608361362 +0000"
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

    # translations
    ################

    core_i18n_commit = "8d10e26bd363001d1119147eef8b7aa1cecfa137"
    core_i18n_shallow_since = "1608250325 +1000"

   # for the extra_ftl
    qtftl_i18n_commit = "50f55f232b3cae3f113ba5a94497a7da76137156"
    qtftl_i18n_shallow_since = "1608120047 +0000"

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

    # should set toolchains in the toolchains, not in the repo 
    maybe(
        native.local_repository,
    	name = "rules_pyo3_repo",
        path = "../rules_pyo3",
    )
    #maybe(
    #    git_repository,
    #    name = "rules_pyo3_repo",
    #    commit = "4a39ecbab67cf4e2e90a360fc688ed6ea9d35877",
    #    remote = "https://github.com/cecini/rules_pyo3",
    #)

    maybe(
        native.local_repository,
    	name = "orjson_repo",
        path = "../orjson",
    )
   # maybe(
   #     git_repository,
   #     name = "orjson_repo",
   #     commit = "2ed8462dc28fbb3929a11374af205d71b8d82faf",
   #     remote = "https://github.com/cecini/orjson",
   # )
