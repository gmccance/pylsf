rpm5:
	rpmbuild -ba --define "_sourcedir $(PWD)/SOURCES" --define 'dist .el6' python-pylsf.spec
srpm:
	rpmbuild -bs --nodeps --define "_sourcedir $(PWD)/SOURCES" --define 'dist .el6' python-pylsf.spec
