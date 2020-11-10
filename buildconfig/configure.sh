#!/bin/sh
sed -i -e 's/"-lgds"/"-lfbclient"/' ../qtbase/src/plugins/sqldrivers/configure.json
#../configure -prefix $QT_PREFIX -opensource -confirm-license -developer-build -nomake examples -nomake tests  -xcb -bundled-xcb-xinput -webengine-alsa -webengine-embedded-build
export PATH=/usr/bin:$PATH 
which python
#../configure -prefix $QT_PREFIX -opensource -confirm-license -developer-build -nomake examples -nomake tests  -xcb -bundled-xcb-xinput
#../configure -prefix $QT_PREFIX -opensource -confirm-license -developer-build -nomake examples -nomake tests  -xcb -bundled-xcb-xinput
../configure -opensource -confirm-license -developer-build -nomake examples -nomake tests  -xcb -bundled-xcb-xinput
