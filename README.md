PyLSF - Python bindings for the LSF batch scheduler
===================================================

Obsolete
--------

This was used long ago for developing tools against Platform LSF 7.

For the current LSF version (>= v9) from IBM, I suggest you look at the python API provided by IBM:

https://github.com/PlatformLSF/platform-python-lsf-api



i 
Obsolete
--------

Otherwise..

Either run `make` to build RPMs, or manually run `python setup.py build` to only
build the module. You may want set and export the `LSF_LIBDIR` and `LSF_VERSION`
environment variables beforehand, for instance:

    % export LSF_VERSION=7.0
    % export LSF_LIBDIR=/usr/lib64
