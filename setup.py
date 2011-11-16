"""

PyLSF: Python/Pyrex interface module to LSF Batch Scheduler

"""

from distutils.core import setup
from distutils.extension import Extension
from distutils.command import clean
from distutils.sysconfig import get_python_lib
from Pyrex.Distutils import build_ext

import os, re
import sys, platform
from string import *
from stat import *

# Mininmum of Python 2.3 required because that's what Pyrex-0.9.5 requires

if not hasattr(sys, 'version_info') or sys.version_info < (2,3,0,'final'):
   raise SystemExit, "Python 2.3+ or later required to build PyLSF."

# Retrieve the LSF environment variables and work out include dir

lsf_major = 0
lsf_incdir = ""
lsf_libdir = os.getenv("LSF_LIBDIR")
if (lsf_libdir):

  LSF_VERSION = re.compile(r'^(?P<lsf_dir>.*lsf|.*lsfhpc)/(?P<lsf_major>\d+).(?P<lsf_minor>\d+)/.*lib$')
  LSF_INCDIR = re.compile(r'^(?P<lsf_dir>.*)/(?P<lsf_os>.*)/lib$')

  line = LSF_INCDIR.match(lsf_libdir)
  if line:

    lsf_incdir = line.group("lsf_dir") + "/include"
    line = LSF_VERSION.match(lsf_libdir)
    if line:
      if line.group("lsf_major"):
        lsf_major = int(line.group("lsf_major"))

else:
  raise SystemExit, "PyLSF: Unable to detect LSF environment......exiting"

print lsf_incdir
include_dirs = [lsf_incdir, '/usr/include']
library_dirs = [lsf_libdir, '/usr/lib64', '/usr/lib']
extra_link_args = [ '']
extra_objects = [ '']

if lsf_major == 7:
  libraries = ['bat', 'lsf', 'lsbstream', 'nsl', 'dl', 'crypt' ]
elif lsf_major == 6:
  libraries = ['bat','lsf','nsl']
elif lsf_major == 0:
  raise SystemExit, "PyLSF: cannot detect any LSF version.....exiting"
else:
  raise SystemExit, "PyLSF: detected unsupported LSF version %d.....exiting" % lsf_major

print "PyLSF: detected LSF version %d" % lsf_major
compiler_dir = os.path.join(get_python_lib(prefix=''), 'pylsf/')

# Trove classifiers

classifiers = """\
Development Status :: 4 - Beta
Intended Audience :: Developers
License :: OSI Approved :: GNU General Public License (GPL)
Natural Language :: English
Operating System :: POSIX :: Linux
Programming Language :: Python
Topic :: Software Development :: Libraries :: Python Modules
"""

doclines = __doc__.split("\n")

setup(
    name = "PyLSF",
    version = "0.0.1",
    description = doclines[0],
    long_description = "\n".join(doclines[2:]),
    author = "Mark Roberts",
    author_email = "mark at gingergeeks co uk",
    url = "http://www.gingergeeks.co.uk/pylsf/",
    classifiers = filter(None, classifiers.split("\n")),
    platforms = ["Linux"],
    keywords = ["Batch Scheduler", "LSF"],
    packages = ["pylsf"],
    ext_modules = [
        Extension( "pylsf/pylsf",["pylsf/pylsf.pyx"],
                   libraries = libraries,
                   library_dirs = library_dirs,
                   include_dirs = include_dirs,
                   extra_compile_args = [],
                   extra_link_args = [] )
    ],
    cmdclass = {"build_ext": build_ext}
)

