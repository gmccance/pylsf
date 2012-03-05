PyLSF - Python bindings for the LSF batch scheduler
===================================================

Quick Start
-----------

Either run `make` to build RPMs, or manually run `python setup.py build` to only
build the module. You may want set and export the `LSF_LIBDIR` and `LSF_VERSION`
environment variables beforehand, for instance:

    % export LSF_VERSION=7.0
    % export LSF_LIBDIR=/usr/lib64
