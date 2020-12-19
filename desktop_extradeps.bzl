
"""
Dependencies required to build Anki excluding the pylib depend.
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository", "new_git_repository")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
def register_repos():
    # javascript
    ##############

    maybe(
        http_archive,
        name = "build_bazel_rules_nodejs",
        sha256 = "cd6c9880292fc83f1fd16ba33000974544b0fe0fccf3d5e15b2e3071ba011266",
        urls = ["https://github.com/ankitects/rules_nodejs/releases/download/runfiles-fix-release/release.tar.gz"],
    )

    # maybe(
    #     http_archive,
    #     name = "build_bazel_rules_nodejs",
    #     #        sha256 = "64a71a64ac58b8969bb19b1c9258a973b6433913e958964da698943fb5521d98",
    #     urls = [
    #         "file:///c:/anki/release.tar.gz",
    #         "file:///Users/dae/Work/code/dtop/release.tar.gz",
    #     ],
    # )

    # sass
    ############

    maybe(
        http_archive,
        name = "io_bazel_rules_sass",
        sha256 = "6e60fc1cf0805af2cdcce727a5eed3f238fb4df41b35ce581c57996947c0202c",
        strip_prefix = "rules_sass-1.26.12",
        url = "https://github.com/bazelbuild/rules_sass/archive/1.26.12.zip",
    )

    # svelte
    ##########

    maybe(
        git_repository,
        name = "build_bazel_rules_svelte",
        commit = "c28cd9e5d251a0ce47c68a6a2a11b075f3df8899",
        remote = "https://github.com/ankitects/rules_svelte",
        shallow_since = "1603950453 +1000",
    )

    # native.local_repository(
    #     name = "build_bazel_rules_svelte",
    #     path = "../rules_svelte",
    # )
