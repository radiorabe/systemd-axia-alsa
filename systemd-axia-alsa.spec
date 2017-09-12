#
# spec file for package systemd-axia-alsa
#
# Copyright (c) 2017 Radio Bern RaBe
#                    http://www.rabe.ch
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public 
# License as published  by the Free Software Foundation, version
# 3 of the License.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License  along with this program.
# If not, see <http://www.gnu.org/licenses/>.
#
# Please submit enhancements, bugfixes or comments via GitHub:
# https://github.com/radiorabe/systemd-axia-alsa
#

Name:           systemd-axia-alsa
Version:        0.1.0
Release:        1%{?dist}
Summary:        systemd service units and udev rules for AXIA - ALSA

License:        AGPL
BuildArch:      noarch
URL:            https://github.com/radiorabe/%{name}
Source0:        https://github.com/radiorabe/%{name}/archive/v%{version}.tar.gz#/%{name}-%{version}.tar.gz

%{?systemd_requires}
BuildRequires:  systemd

Requires:       axia-alsa
Requires:       kmod-axia-alsa

# udev directory paths
# The _libdir macro can't be used as a prefix here as udev rules have to go
# into /usr/lib/udev/rules.d and not into /usr/lib64/udev/rules.d (on x86_64)
%global udevdir /usr/lib/udev/
%global udevrulesdir %{udevdir}/rules.d

%global service_user axia
%global service_group %{service_user}

%description
systemd service units and udev rules for managing the AXIA - ALSA soundcard
driver for Livewire services.


%prep
%setup -q -n %{name}-%{version}


%build


%install
rm -rf $RPM_BUILD_ROOT
make install prefix=%{_prefix} \
             exec_prefix=%{_exec_prefix} \
             sysconfdir=%{_sysconfdir} \
             unitdir=%{_unitdir} \
             udevrulesdir=%{udevrulesdir} \
             DESTDIR=%{?buildroot}


%pre
getent group %{service_group} >/dev/null || groupadd -r %{service_group}
getent passwd %{service_user} >/dev/null || \
    useradd -r -g %{service_group} -d /dev/null -M -s /sbin/nologin \
    -c "AXIA system user account" %{service_user}
exit 0


%files
%doc %{_docdir}/%{name}/README.md
%{_unitdir}/*.service
%config(noreplace) %{_sysconfdir}/axia/systemd-env.conf
%{_sysconfdir}/modules-load.d/snd-axia.conf
%{_sysconfdir}/modprobe.d/snd-axia.conf
%{udevdir}/*


%changelog
* Tue Sep 12 2017 Christian Affolter <c.affolter@purplehaze.ch> - 0.1.0-1
- Initial release