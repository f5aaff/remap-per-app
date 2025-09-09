Name:           remap-per-app
Version:        1.0.0
Release:        %autorelease
Summary:        Per-app key remap bash utility

License:        MIT
URL:            https://github.com/f5aaff/remap-per-app
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  bash, systemd
Requires:       bash, systemd, xdotool, xbindkeys, inotify-tools

%description
Per-app key remap utility.

%prep
%setup -q

%install
mkdir -p %{buildroot}/usr/local/bin
install -m 755 bin/remap-per-app-daemon %{buildroot}/usr/local/bin/remap-per-app-daemon

mkdir -p %{buildroot}/usr/lib/systemd/user
install -m 644 systemd/remap-per-app.service %{buildroot}/usr/lib/systemd/user/remap-per-app.service

%post
loginctl list-sessions | awk 'NR>1 {print $1}' | while read -r session; do
    loginctl enable-linger $(loginctl show-session $session -p Name --value)
done

%files
/usr/local/bin/remap-per-app-daemon
/usr/lib/systemd/user/remap-per-app.service

%changelog
%autochangelog

