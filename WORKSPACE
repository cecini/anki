workspace(
    name = "net_ankiweb_anki",
    managed_directories = {"@npm": [
        "ts/node_modules",
    ]},
)

load(":repos.bzl", "register_repos")

register_repos()

load(":defs.bzl", "setup_deps")

setup_deps()

load(":late_deps.bzl", "setup_late_deps")


##############
# PyO3 Rules #
##############

#git_repository(
#    name = "rules_pyo3",
#    commit = "304d8974fa41e37e8ad3e32b9cb1221ecc9bb985",
#    remote = "https://github.com/cecini/rules_pyo3",
#)


#load("@rules_pyo3//cargo:crates.bzl", "rules_pyo3_fetch_remote_crates")

#rules_pyo3_fetch_remote_crates()



setup_late_deps()
