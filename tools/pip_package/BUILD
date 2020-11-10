# Description:
#  Tools for building pip package.

load("@local_config_syslibs//:build_defs.bzl", "if_not_system_lib")

package(default_visibility = ["//visibility:private"])


#py_binary include and license file and outher pkg in  deps 
#filegroup
#filegroup_as_file


COMMON_PIP_DEPS = [
    ":licenses",
    "//tensorflow:tensorflow_py",
]



sh_binary(
    name = "build_pip_package",
    srcs = ["build_pip_package.sh"],
    data = COMMON_PIP_DEPS,
)

