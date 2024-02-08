#!/bin/bash

echo "Removing files"
rm -rfv cmake src CMakeLists.txt COPYING
echo "Fetching"
git clone https://github.com/davea42/libdwarf-code.git
cd libdwarf-code
#git checkout "6216e185863f41d6f19ab850caabfff7326020d7" # v0.8.0
#git checkout "8b0bd09d8c77d45a68cb1bb00a54186a92b683d9" # v0.9.0
git checkout "8cdcc531f310d1c5ae61da469d8056bdd36b77e7" # v0.9.1 + cmake fixes
cd ..
echo "Copying files"
mkdir -p src/lib
mv -v libdwarf-code/CMakeLists.txt .
mv -v libdwarf-code/COPYING .
mv -v libdwarf-code/cmake .
mv -v libdwarf-code/src/lib/libdwarf src/lib
echo "Deleting cloned repo"
rm -rf libdwarf-code
echo "Cleaning up src/lib/libdwarf"
cd src/lib/libdwarf
rm -rfv ChangeLog* CHANGES CODINGSTYLE NEWS
cd ../../..
echo "Patching"
patch < patches/CMakeLists.patch
echo "Done"
