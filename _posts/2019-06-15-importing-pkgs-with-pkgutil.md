---
layout: blog_post
title: "Importing Python packages with pkgutil"
categories: [programming]
---

We Python programmers have our cherished shortcuts around [package search hell](https://xkcd.com/1987/). The easiest by far is probably `sys.path.insert(0)`, but it isn't always feasible or generalizable across machines. This post is about `pkgutil`[^docs-link], a package that I recently stumbled across, and whether it is a suitable substitute to `sys.path.insert`. A couple of disclaimers:

1. This is NOT a tutorial on how to use `pkgutil`; I leave that to other experts.
1. I am still using Python 2 for various reasons. The Python 3 `pkgutil` might be much more capable than indicated in this post.


## Background

I have been working on code to run robot tasks, which has the following directory structure[^assitance-arbitration]:

```
task_executor
|-- __init__.py
|-- actions
|    |-- __init__.py
|    |-- move.py
|    |-- pick.py
|    |-- find_object.py
|    |-- speak.py
|    +-- ...
|-- beliefs.py
+-- ...

```

As a short summary, the `task_executor` Python package contains utilities to call robot perception and motion actions in order to complete a task, and its primary interface to the rest of the robot system is through clients defined within the Python subpackage `actions`. To make the interface to clients easy, external packages simply import `task_executor.actions`, which means that the file `task_executor/actions/__init__.py` needs to be kept upto date with all the modules that are defined in the path `task_executor/actions/`.

Before my foray into `pkgutil`, I manually synchronized `__init__.py` with every action update. However, when the number of actions reached 42 (and more), the situation became untenable: I needed a mechanism to automatically find and import action clients from a specified submodule in a package[^does-not-work].


## Importing on the PATH

Naturally, StackOverflow was my first destination, and it [didn't disappoint](https://stackoverflow.com/questions/487971/is-there-a-standard-way-to-list-names-of-python-modules-in-a-package). A stub of the code required in `task_executor/actions/__init__.py` is:

```python
import os
import pkgutil

# First iterate through the directory with pkgutil, and save all
# the modules that were found in the variable found_packages
pkgname = __package__  # Should be `task_executor.actions`
pkgpath = os.path.dirname(__file__)
found_packages = list(
    pkgutil.iter_modules([pkgpath],
                         prefix="{}.".format(pkgname))]
)

# Then fetch the action names, because each `x` in the list
# comprehension below is of the form
# `task_executor.actions.<name>`
action_names = [x.split('.')[-1] for _, x, _ in found_packages]

# Get the package importer from the package list too. We will use
# it for the actual import. Note, that since we only had a single
# directory, the importer for all the returned packages is the
# same (you can verify this in a separate interpreter)
importer = found_packages[0][0]

# Finally, import the actions from the found_packages. Remember
# that this code can be very prone to exceptions!
actions = {}
for idx, name in enumerate(action_names):
    module = importer.find_module(found_packages[idx][1])\
                     .load_module(found_packages[idx][1])
    actions[name] = getattr(module, "Action")
```

As easily as that, I now have an `__init__.py` that I never have to remember to update when changing one of the many actions that are defined[^but-caveat].


## Importing off the PATH

But, as you probably noticed, the argument accepted by `pkgutil.iter_modules` is a list of folder paths and *not package names*. So I decided to conduct a few experiments to see if `pkgutil` is a valid substitute for old-faithful---`sys.path.insert`.

### Absolute imports in modules

Consider the following package structure, which is not on any of the Python import paths:

```
foo
|-- __init__.py (empty)
|-- a.py
+-- b.py
```

```python
#!/usr/bin/env python
# a.py
from __future__ import print_function
print("A")
```

```python
#!/usr/bin/env python
# b.py
from __future__ import print_function
print("B")
```

In a separate directory (`/home/banerjs/Downloads`), I then ran the following:

```python
>>> import os
>>> import pkgutil
>>> pth = "/home/banerjs/foo"
>>> p = list(pkgutil.iter_modules([pth], "foo."))
>>> p
[(<pkgutil.ImpImporter instance at 0x7fc64b85c518>, 'foo.a', False), (<pkgutil.ImpImporter instance at 0x7fc64b85c518>, 'foo.b', False)]
>>> i = p[0][0]
>>> a = i.find_module(p[0][1]).load_module(p[0][1])
/home/banerjs/foo/a.py:1: RuntimeWarning: Parent module 'foo' not found while handling absolute import
  from __future__ import print_function
A
```

Surprisingly, the result is a successful import, but the `RuntimeWarning` suggests that relative imports in the module could prove to be problematic. So I tested that next.

### Relative imports in modules

I updated the code of `a.py`:

```python
#!/usr/bin/env python
# a.py
from __future__ import print_function
from .b import *
print("A")
```

And then ran in the previous terminal:

```python
>>> a = i.find_module(p[0][1]).load_module(p[0][1])
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "/usr/lib/python2.7/pkgutil.py", line 243, in load_module
    mod = imp.load_module(fullname, self.file, self.filename, self.etc)
  File "/home/banerjs/foo/a.py", line 2, in <module>
    from .b import *
SystemError: Parent module 'foo' not loaded, cannot perform relative import
```

Sure enough, to perform relative imports, the package `foo` must be in the search path and loaded. One can verify this easily with:

```python
>>> import sys
>>> sys.path.insert(0, os.path.dirname(pth))  # Old faithful
>>> import importlib
>>> f = importlib.import_module('foo')
>>> f
<module 'foo' from '/home/banerjs/foo/__init__.py'>
>>> a = i.find_module(p[0][1]).load_module(p[0][1])
B
A
```

### Absolute imports in submodules

The comments in the StackOverflow discussion also mention `pkgutil.walk_packages()` as a means of recursing through all submodules. So I reverted `a.py` and updated the package structure to:

```
foo
|-- __init__.py (empty)
|-- a.py
|-- b.py
+-- c
    |-- __init__.py (empty)
    +-- d.py
```
```python
#!/usr/bin/env python
# d.py
from __future__ import print_function
print("D")
```

And then, in a new terminal, ran the following:

```python
>>> from __future__ import print_function
>>> import os
>>> import pkgutil
>>> pth = "/home/banerjs/foo"
>>> p = list(pkgutil.iter_modules([pth], "foo.", onerror=print))
foo.c
>>> p
[(<pkgutil.ImpImporter instance at 0x7f31d4d73518>, 'foo.a', False), (<pkgutil.ImpImporter instance at 0x7f31d4d73518>, 'foo.b', False), (<pkgutil.ImpImporter instance at 0x7f31d4d73518>, 'foo.c', True)]
```

The absence of `d` in the output and the presence of the intermediate `foo.c` print indicate that `walk_packages` also requires `foo` to be on the package search paths. We can verify this:

```python
>>> import sys
>>> sys.path.insert(0, os.path.dirname(pth))  # Old faithful
>>> import importlib
>>> f = importlib.import_module('foo')
>>> p = list(pkgutil.walk_packages([pth], "foo.", print))
>>> p
[(<pkgutil.ImpImporter instance at 0x7f31d2c3e518>, 'foo.a', False), (<pkgutil.ImpImporter instance at 0x7f31d2c3e518>, 'foo.b', False), (<pkgutil.ImpImporter instance at 0x7f31d2c3e518>, 'foo.c', True), (<pkgutil.ImpImporter instance at 0x7f31d2c3e680>, 'foo.c.d', False)]
```


## Conclusions

In conclusion, therefore, `pkgutil` is a great tool for package or module discovery when the package in question is already in the package search path(s), but we still need good ol' `sys.path.insert` (among other, more generalizable methods) to get the target package(s) into the search path in the first place.


#### Footnotes

[^docs-link]: [link](http://docs.python.org/library/pkgutil.html)

[^assitance-arbitration]: Some of the code is [here](https://github.com/GT-RAIL/assistance_arbitration); but there will be more details on it at a later date.

[^does-not-work]: Unfortunately, due to various reasons still unclear to me, `dir(task_executor.actions)` did not magically list all the modules that I wanted...

[^but-caveat]: There are a few caveats, such as the fact that the naming convention within the actions have to be standardized, etc. However, as caveats go, they aren't too bad.
