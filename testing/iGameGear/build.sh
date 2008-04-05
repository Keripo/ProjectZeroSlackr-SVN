#!/bin/sh
#
# iGameGear Auto-Building Script
# Created by Keripo
# For Project ZeroSlackr
# Last updated: April 4, 2008
#
echo ""
echo "==========================================="
echo ""
echo "iGameGear Auto-Building Script"
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
mkdir compiling
cd compiling
tar -xf ../../src/orig/igamegearsrc-20070117.tgz
cd ..
# Apply ZeroSlackr custom patches
echo "> Applying ZeroSlackr patches..."
cd compiling
for file in ../../src/patches/*; do
	patch -p0 -t -i $file >> ../build.log
done
cd ..
# Symlink the libraries
echo "> Symlinking libraries..."
DIR=$(pwd)
LIBSDIR=../../../libs
LIBS="hotdog"
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
cd ipl
export PATH=/usr/local/arm-uclinux-tools2/bin:/usr/local/arm-uclinux-elf-tools/bin:/usr/local/arm-uclinux-tools/bin:$PATH
make CC=arm-elf-gcc NAME=iGameGear >> ../../build.log 2>&1
cd ..
# Copy over compiled file
echo "> Copying over compiled files..."
cd ..
mkdir compiled
cp -rf compiling/ipl/iGameGear compiled/
# Creating release
echo "> Creating 'release' folder..."
tar -xf ../src/release.tar.gz
cd release
# Files
PACK=ZeroSlackr/opt/iGameGear
cp -rf ../compiled/iGameGear $PACK/
# Documents
DOCS=$PACK/Misc/Docs
cp -rf "../../ReadMe from Keripo.txt" $DOCS/
cp -rf ../../License.txt $DOCS/
DOCSORIG=$DOCS/Original
FILES="license README.TXT ipl/README_SMSSDL.TXT"
for file in $FILES
do
	cp -rf ../compiling/$file $DOCSORIG/
done
# Archive documents
cd $PACK/Misc
cd Docs
tar -cf Original.tar Original
gzip --best Original.tar
rm -rf Original
# Done
echo ""
echo "Fin!"
echo ""
echo "Auto-Building script by Keripo"
echo ""
echo "==========================================="