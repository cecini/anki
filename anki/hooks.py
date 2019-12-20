# -*- coding: utf-8 -*-
# Copyright: Ankitects Pty Ltd and contributors
# License: GNU AGPL, version 3 or later; http://www.gnu.org/licenses/agpl.html

"""\
Hooks - hook management and tools for extending Anki
==============================================================================

To find available hooks, grep for runHook and runFilter in the source code.

Instrumenting allows you to modify functions that don't have hooks available.
If you call wrap() with pos='around', the original function will not be called
automatically but can be called with _old().
"""

import decorator
from typing import List, Any, Callable, Dict

# Hooks
##############################################################################

_hooks: Dict[str, List[Callable[..., Any]]] = {}

def runHook(hook: str, *args) -> None:
    "Run all functions on hook."
    hookFuncs = _hooks.get(hook, None)
    if hookFuncs:
        for func in hookFuncs:
            try:
                func(*args)
            except:
                hookFuncs.remove(func)
                raise

def runFilter(hook: str, arg: Any, *args) -> Any:
    hookFuncs = _hooks.get(hook, None)
    if hookFuncs:
        for func in hookFuncs:
            try:
                arg = func(arg, *args)
            except:
                hookFuncs.remove(func)
                raise
    return arg

def addHook(hook: str, func: Callable) -> None:
    "Add a function to hook. Ignore if already on hook."
    if not _hooks.get(hook, None):
        _hooks[hook] = []
    if func not in _hooks[hook]:
        _hooks[hook].append(func)

def remHook(hook, func) -> None:
    "Remove a function if is on hook."
    hook = _hooks.get(hook, [])
    if func in hook:
        hook.remove(func)

# Instrumenting
##############################################################################

def wrap(old, new, pos="after") -> Callable:
    "Override an existing function."
    def repl(*args, **kwargs):
        if pos == "after":
            old(*args, **kwargs)
            return new(*args, **kwargs)
        elif pos == "before":
            new(*args, **kwargs)
            return old(*args, **kwargs)
        else:
            return new(_old=old, *args, **kwargs)

    def decorator_wrapper(f, *args, **kwargs):
        return repl(*args, **kwargs)

    return decorator.decorator(decorator_wrapper)(old)
