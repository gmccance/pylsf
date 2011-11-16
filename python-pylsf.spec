# sitelib for noarch packages, sitearch for others (remove the unneeded one)
%{!?python_sitearch: %global python_sitearch %(%{__python} -c "from distutils.sysconfig import get_python_lib; print get_python_lib(1)")}

Name:           python-pylsf
Version:        2009.02.23
Release:        1.cern1%{?dist}
Summary:        Bindings for Platform LSF

Group:          Development/Languages
License:        GPL 
URL:            http://www.gingergeeks.co.uk/pylsf/
Source0:        http://www.gingergeeks.co.uk/pylsf/snapshots/pylsf-2009-02-23.tar.bz2
# Add current CERn specials to find our LSF devel libs
Patch0:         pylsf-setup.patch 
Patch1:         pylsf-cernaddons.patch 
BuildRoot:      %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)

BuildRequires:  python-devel Pyrex  LSF-GLIBC-2.3-devel

%description
Bindings for Platform LSF

%prep
%setup -q -n pylsf-0.0.1
%patch0 -p1
%patch1 -p1

%build
# Remove CFLAGS=... for noarch packages (unneeded)
CFLAGS="$RPM_OPT_FLAGS" %{__python} setup.py build


%install
rm -rf $RPM_BUILD_ROOT
%{__python} setup.py install -O1 --skip-build --root $RPM_BUILD_ROOT

 
%clean
rm -rf $RPM_BUILD_ROOT


%files
%defattr(-,root,root,-)
%doc
# For noarch packages: sitelib
%{python_sitearch}/*


%changelog
* Thu May 27 2011 Gavin McCance <gavin.mccance@cern.ch> - 2009.02.23-1.cern1
- Add resource_req to ls_gethostinfo
* Mon Mar 28 2011 Gavin McCance <gavin.mccance@cern.ch> - 2009.02.23-0.cern1
- Initial build.

