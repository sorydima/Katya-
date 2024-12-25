Name: katya
Version: 0.3.21+1026
Release: 1026%{?dist}
Summary: Katya App Client
Group: Application/Emulator
Vendor: Katya Systems, LLC
Packager: Sorokin Dmitry Olegovich <dmitry.justdev@gmail.com>
License: AGPLv3
URL: https://github.com/sorydima/Katya-.git
BuildArch: x86_64

%description
Katya ®! An AI multifunctional social blockchain platform!

%install
mkdir -p %{buildroot}%{_bindir}
mkdir -p %{buildroot}%{_datadir}/%{name}
mkdir -p %{buildroot}%{_datadir}/applications
mkdir -p %{buildroot}%{_datadir}/metainfo
mkdir -p %{buildroot}%{_datadir}/pixmaps
cp -r %{name}/* %{buildroot}%{_datadir}/%{name}
ln -s %{_datadir}/%{name}/%{name} %{buildroot}%{_bindir}/%{name}
cp -r %{name}.desktop %{buildroot}%{_datadir}/applications
cp -r %{name}.png %{buildroot}%{_datadir}/pixmaps
cp -r %{name}*.xml %{buildroot}%{_datadir}/metainfo || :
update-mime-database %{_datadir}/mime &> /dev/null || :

%postun
update-mime-database %{_datadir}/mime &> /dev/null || :

%files
%{_bindir}/%{name}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/metainfo


%defattr(-,root,root)

%attr(4755, root, root) %{_datadir}/pixmaps/%{name}.png
