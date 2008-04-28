#!/bin/sh
#
# SBaGen Auto-Building Script
# Created by Keripo
# For Project ZeroSlackr
# Last updated: Apr 26, 2008
#
echo ""
echo "==========================================="
echo ""
echo "SBaGen Auto-Building Script"
echo ""
# Cleanup
if [ -d build ]; then
	echo "> Removing old build directory..."
	rm -rf build
fi
# Make new compiling directory
echo "> Setting up build directory..."
mkdir build
cd build
# Extract source
echo "> Extracting source..."
tar -xf ../src/orig/sbagen-1.4.4.tgz
mv sbagen-1.4.4 compiling
# Apply ZeroSlackr custom patches
echo "> Applying ZeroSlackr patches..."
cp -rf ../src/mod/* compiling/
# Symlink the libraries
echo "> Symlinking libraries..."
DIR=$(pwd)
LIBSDIR=../../../../libs
LIBS="ttk launch"
for lib in $LIBS
do
	if [ ! -d $LIBSDIR/$lib ]; then
		cd $LIBSDIR
		echo "  - Building "$lib"..."
		./src/$lib.sh
		cd $DIR
	fi
	ln -s $LIBSDIR/$lib ./
done
# Compiling
echo "> Compiling..."
cd compiling
export PATH=/usr/local/bin:$PATH
rm -rf sbagen
chmod ugo+rwx ./mk-ipod
./mk-ipod >> ../build.log
# Copy over compiled file
echo "> Copying over compiled files..."
cd ..
mkdir compiled
if [ -e compiling/sbagen.elf.bflt ]; then
	cp -rf compiling/sbagen.elf.bflt compiled/SBaGen
else
	cp -rf compiling/sbagen compiled/SBaGen
fi
# Launch module
echo "> Building ZeroLauncher launch module..."
cp -rf ../src/launcher ./
cd launcher
export PATH=/usr/local/arm-uclinux-tools2/bin:/usr/local/arm-uclinux-elf-tools/bin:/usr/local/arm-uclinux-tools/bin:$PATH
make -f ../launch/launch.mk
cd ..
# Creating release
echo "> Creating 'release' folder..."
cp -rf ../src/release ./
cd release
# Files
PACK=ZeroSlackr/opt/Media/SBaGen
cp -rf ../compiled/SBaGen $PACK/
cp -rf ../compiling/examples/* $PACK/Beats/
cp -rf ../launcher/* $PACK/Launch/
# Documents
DOCS=$PACK/Misc/Docs
cp -rf "../../ReadMe from Keripo.txt" $PACK/
cp -rf ../../License.txt $PACK/
FILES="ChangeLog.txt COPYING.txt focus.txt holosync.txt README.txt SBAGEN.txt wave.txt"
for file in $FILES
do
	cp -rf ../compiling/$file $DOCS/
done
sh -c "find -name '.svn' -exec rm -rf {} \;" >> /dev/null 2>&1
# Archive documents
cd $PACK/Misc
tar -cf Docs.tar Docs
gzip --best Docs.tar
rm -rf Docs
# Done
echo ""
echo "Fin!"
echo ""
echo "Auto-Building script by Keripo"
echo ""
echo "==========================================="