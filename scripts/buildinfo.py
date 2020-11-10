#!/usr/bin/env python

import re
import sys

defs_file = sys.argv[1]
stamp_file = sys.argv[2]
release_mode = sys.argv[3] == "release"

version_re = re.compile('anki_version = "(.*)"')

def output(text: str) -> None:
    "Add text with a '\n' to stdout; avoiding a '\r' on Windows"
    sys.stdout.buffer.write(text.encode("utf8") + b"\n")

# extract version number from defs.bzl
with open(defs_file) as fh:
    for line in fh.readlines():
        if ver := version_re.match(line):
            output(f"STABLE_VERSION {ver.group(1)}")

with open(stamp_file) as fh:
    for line in fh.readlines():
        if line.startswith("STABLE_BUILDHASH"):
           if release_mode:
              output(line.strip())
           else:
              # if not in release mode, map buildhash to a consistent value
              output("STABLE_BUILDHASH dev")
