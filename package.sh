!#/bin/bash
# each distro needs it's own service file, they're already in the related dir.

RPM_BUILD_DIR=./rpm/remap_per_app
DEB_BUILD_DIR=./deb/remap_per_app
NIX_BUILD_DIR=./flake/remap-per-app

PARENT_DIR=$(pwd)

# delete releases
rm -rf releases 2>/dev/null
mkdir releases

# package for deb
cp .src/remap-per-app-daemon $DEB_BUILD_DIR/usr/local/bin/remap-per-app-daemon
cd $DEB_BUILD_DIR
dpkg-deb --build remap-per-app
cd $PARENT_DIR
cp $DEB_BUILD_DIR/remap-per-app.deb ./releases

# package for rpm
cp ./src/remap-per-app-daemon $RPM_BUILD_DIR/SOURCES/remap-per-app-1.0.0/bin/remap-per-app-daemon
cd $RPM_BUILD_DIR
rpmbuild -ba SPECS/remap-per-app.spec --define "_topdir $(pwd)"
cd $PARENT_DIR
cp $RPM_BUILD_DIR/RPMS/x86_64/*.rpm ./releases

# package for nix
cp ./src/remap-per-app-daemon $NIX_BUILD_DIR/bin/remap-per-app-daemon
cd $NIX_BUILD_DIR
tar -zcvf remap-per-app-nix.tar remap-per-app/
cd $PARENT_DIR
cp $NIX_BUILD_DIR/remap-per-app-nix.tar ./releases

