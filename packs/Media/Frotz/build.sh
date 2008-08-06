#!/bin/sh
#
# Frotz Auto-Building Script
# Created by Keripo
# For Project ZeroSlackr
# Last updated: Aug 6, 2008
#
echo ""
echo "==========================================="
echo ""
echo "Frotz Auto-Building Script"
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
BUILDDIR=$(pwd)
# Extract source
echo "> Extracting source..."
tar zxf ../src/orig/frotz-2.43.tar.gz
mv frotz-2.43 compiling
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
LIBSDIR=../../../../libs
LIBS="ncurses ttk launch"
for lib in $LIBS
do
	if [ ! -d $LIBSDIR/$lib ]; then
		cd $LIBSDIR
		echo "  - Building "$lib"..."
		./src/$lib.sh
		echo ""
		cd $DIR
	fi
	ln -s $LIBSDIR/$lib ./
done
# Compiling
echo "> Compiling..."
echo "  Note: All warnings/errors here will"
echo "  be logged to the 'build.log' file."
echo "  If building fails, check the log file."
cd compiling
export PATH=/usr/local/arm-uclinux-tools2/bin:/usr/local/arm-uclinux-elf-tools/bin:/usr/local/arm-uclinux-tools/bin:$PATH
# I have no idea if sound works as I haven't tried any games with sound
echo "  - building dumb target..."
make dumb CC=arm-uclinux-elf-gcc CONFIG_DIR=/opt/Media/Frotz/Conf SOUND_DEFS=-DOSS_SOUND SOUND_DEV=/dev/dsp LIB=-elf2flt >> ../build.log 2>&1
echo "  - building ncurses target..."
make CC=arm-uclinux-elf-gcc CONFIG_DIR=/opt/Media/Frotz/Conf SOUND_DEFS=-DOSS_SOUND SOUND_DEV=/dev/dsp INCL="-I../ncurses/include -I../ncurses/include/ncurses" LIB="-L../ncurses/lib -elf2flt" CURSES=-lncurses CURSES_DEF=-DUSE_NCURSES_H >> ../build.log 2>&1
cd ..
# Copy over compiled file
echo "> Copying over compiled files..."
mkdir compiled
cp -rf compiling/frotz compiled/Frotz
cp -rf compiling/dfrotz compiled/DFrotz
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
PACK=ZeroSlackr/opt/Media/Frotz
cp -rf ../compiled/* $PACK/
cp -rf ../launcher/* $PACK/Launch/
# Documents
DOCS=$PACK/Misc/Docs
cp -rf "../../ReadMe from Keripo.txt" $PACK/
cp -rf ../../License.txt $PACK/
cp -rf ../../src/patches $PACK/Misc/Patches
FILES="AUTHORS BUGS ChangeLog COPYING DUMB frotz.lsm HOW_TO_PLAY README TODO"
for file in $FILES
do
	cp -rf ../compiling/$file $DOCS/
done
# Delete .svn folders - directory change done in case of previous failure
cd $BUILDDIR
cd release
sh -c "find -name '.svn' -exec rm -rf {} \;" >> /dev/null 2>&1
# Archive documents
cd $PACK/Misc
tar -cf Patches.tar Patches
gzip --best Patches.tar
rm -rf Patches
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