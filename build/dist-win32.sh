#!/bin/bash
#
# This script packages up .zip and .exe binary releases of
# Fyre for windows. It requires access to the cross-compilation
# environment to yank out binaries, and it needs Wine installed
# to run the NSIS installer.
#
# This is a modified version of make-runtime.sh from
# the Workrave project.
#

ALL_LINGUAS=""
ALL_DOCS="AUTHORS BUGS COPYING README TODO"

FYREDIR=..

# The NSIS installer, running under wine. This points
# to a trivial wrapper script with the right paths.
NSIS=$HOME/bin/nsis

. $HOME/bin/win32-cross

################ Fyre itself

# Check the current version number
VERSION=`./extract-var.py $FYREDIR/configure.ac VERSION`
TARGETDIR=staging/fyre-$VERSION

# Copy data files, as marked in Makefile.am
DATAFILES=`./extract-var.py $FYREDIR/data/Makefile.am fyredata_DATA`
mkdir -p $TARGETDIR/data
for datafile in $DATAFILES; do
    cp -av $FYREDIR/data/$datafile $TARGETDIR/data/
done

# Copy and strip the binary itself
mkdir -p $TARGETDIR/lib
cp -av $FYREDIR/src/fyre.exe $TARGETDIR/lib
$STRIP $TARGETDIR/lib/fyre.exe

# Documentation. This adds a .txt extension and converts newlines
for doc in $ALL_DOCS; do
    cat $FYREDIR/$doc | sed 's/$/\r/' > $TARGETDIR/$doc.txt
done

################ Dependencies

function copy_dir()
{
    sourcedir=$1;
    source=$2
    dest=$3;

    prefix=`dirname $source`
    mkdir -p $TARGETDIR/$dest/$prefix
    cp -av $PREFIX/$sourcedir/$source $TARGETDIR/$dest/$prefix
}

copy_dir bin     gnet-2.0.dll                                   lib

copy_dir  etc    gtk-2.0                                        etc
copy_dir  etc    pango						etc
copy_dir  bin    zlib1.dll					lib
copy_dir  bin    iconv.dll					lib
copy_dir  bin    intl.dll                           		lib
copy_dir  bin    libpng12.dll                         		lib
copy_dir  bin    libatk-1.0-0.dll                   		lib
copy_dir  bin    libgdk-win32-2.0-0.dll             		lib
copy_dir  bin    libgdk_pixbuf-2.0-0.dll            		lib
copy_dir  bin    libglib-2.0-0.dll                  		lib
copy_dir  bin    libgmodule-2.0-0.dll               		lib
copy_dir  bin    libgobject-2.0-0.dll               		lib
copy_dir  bin    libgthread-2.0-0.dll               		lib
copy_dir  bin    libgtk-win32-2.0-0.dll             		lib
copy_dir  bin    libpango-1.0-0.dll                 		lib
copy_dir  bin    libpangoft2-1.0-0.dll              		lib
copy_dir  bin    libpangowin32-1.0-0.dll            		lib
copy_dir  lib    gtk-2.0/2.4.0/immodules/                       lib
copy_dir  lib    gtk-2.0/2.4.0/loaders/libpixbufloader-ico.dll  lib
copy_dir  lib    gtk-2.0/2.4.0/loaders/libpixbufloader-png.dll  lib
copy_dir  lib    gtk-2.0/2.4.0/loaders/libpixbufloader-pnm.dll  lib
copy_dir  lib    pango/1.4.0/modules      			lib
for lang in $ALL_LINGUAS; do
    copy_dir lib locale/$lang lib
done

find $TARGETDIR -name "*.dll" -not -name "iconv.dll" -not -name "intl.dll" -print | xargs $STRIP

################ Generate an NSIS installer

$NSIS - <<EOF

    Name "Fyre $VERSION"

    OutFile "fyre-$VERSION.exe"

    ; The default installation directory
    InstallDir \$PROGRAMFILES\\Fyre

    ; Registry key to check for directory (so if you install again, it will 
    ; overwrite the old one automatically)
    InstallDirRegKey HKLM Software\\Fyre "Install_Dir"

    Page components
    Page directory
    Page instfiles

    UninstPage uninstConfirm
    UninstPage instfiles

    Section "Fyre"

      SectionIn RO

      SetOutPath \$INSTDIR
      File /r "$TARGETDIR\\*.*"

      ; Write the installation path into the registry
      WriteRegStr HKLM Software\Fyre "Install_Dir" "\$INSTDIR"

      ; Write the uninstall keys for Windows
      WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Fyre" "DisplayName" "Fyre"
      WriteRegStr HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\Fyre" "UninstallString" '"\$INSTDIR\\uninstall.exe"'
      WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Fyre" "NoModify" 1
      WriteRegDWORD HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Fyre" "NoRepair" 1
      WriteUninstaller "uninstall.exe"

    SectionEnd

    Section "Start Menu Shortcuts"

      CreateDirectory "\$SMPROGRAMS\\Fyre"
      CreateShortCut "\$SMPROGRAMS\\Fyre\\Uninstall.lnk" "\$INSTDIR\\uninstall.exe"
      CreateShortCut "\$SMPROGRAMS\\Fyre\\Read Me.lnk" "\$INSTDIR\\README.txt"
      CreateShortCut "\$SMPROGRAMS\\Fyre\\License.lnk" "\$INSTDIR\\COPYING.txt"
      CreateShortCut "\$SMPROGRAMS\\Fyre\\Fyre $VERSION.lnk" "\$INSTDIR\\lib\\fyre.exe"
      CreateShortCut "\$SMPROGRAMS\\Fyre\\Fyre Rendering Server.lnk" "\$INSTDIR\\lib\\fyre.exe" "-vr"

    SectionEnd

    ;--------------------------------

    ; Uninstaller

    Section "Uninstall"

      ; Remove registry keys
      DeleteRegKey HKLM "Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\Fyre"
      DeleteRegKey HKLM SOFTWARE\\Fyre

      ; Remove directories used
      RMDir /r "\$SMPROGRAMS\\Fyre"
      RMDir /r "\$INSTDIR"

    SectionEnd

EOF


### The End ###