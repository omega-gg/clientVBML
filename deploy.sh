#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

target="clientVBML"

Sky="../Sky"

#--------------------------------------------------------------------------------------------------
# environment

compiler_win="mingw"

qt="qt5"

#--------------------------------------------------------------------------------------------------
# Syntax
#--------------------------------------------------------------------------------------------------

if [ $# != 1 -a $# != 2 ] \
   || \
   [ $1 != "win32" -a $1 != "win64" -a $1 != "macOS" -a $1 != "linux" -a $1 != "android" ] \
   || \
   [ $# = 2 -a "$2" != "clean" ]; then

    echo "Usage: deploy <win32 | win64 | macOS | linux | android> [clean]"

    exit 1
fi

#--------------------------------------------------------------------------------------------------
# Configuration
#--------------------------------------------------------------------------------------------------

if [ $1 = "win32" -o $1 = "win64" ]; then

    os="windows"

    compiler="$compiler_win"
else
    os="default"

    compiler="default"
fi

#--------------------------------------------------------------------------------------------------
# Clean
#--------------------------------------------------------------------------------------------------

echo "CLEANING"

rm -rf deploy/*

touch deploy/.gitignore

if [ "$2" = "clean" ]; then

    exit 0
fi

echo ""

#--------------------------------------------------------------------------------------------------
# Sky
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING Sky"
echo "-------------"

cd "$Sky"

sh deploy.sh $1 tools

cd -

path="$Sky/deploy"

if [ $os = "windows" ]; then

    if [ $compiler = "mingw" ]; then

        cp "$path"/libgcc_s_*-1.dll    deploy
        cp "$path"/libstdc++-6.dll     deploy
        cp "$path"/libwinpthread-1.dll deploy
    fi

    if [ $qt = "qt4" ]; then

        cp "$path"/QtCore4.dll        deploy
        cp "$path"/QtNetwork4.dll     deploy
        cp "$path"/QtScript4.dll      deploy
        cp "$path"/QtXml4.dll         deploy
        cp "$path"/QtXmlPatterns4.dll deploy
    else
        cp "$path"/Qt5Core.dll        deploy
        cp "$path"/Qt5Network.dll     deploy
        cp "$path"/Qt5Qml.dll         deploy
        cp "$path"/Qt5Xml.dll         deploy
        cp "$path"/Qt5XmlPatterns.dll deploy
    fi

elif [ $1 = "macOS" ]; then

    if [ $qt = "qt5" ]; then

        # FIXME Qt 5.14 macOS: We have to copy qt.conf to avoid a segfault.
        cp "$path"/qt.conf deploy

        cp "$path"/QtCore.dylib        deploy
        cp "$path"/QtNetwork.dylib     deploy
        cp "$path"/QtQml.dylib         deploy
        cp "$path"/QtXml.dylib         deploy
        cp "$path"/QtXmlPatterns.dylib deploy
    fi

elif [ $1 = "linux" ]; then

    if [ $qt = "qt4" ]; then

        cp "$path"/libQtCore.so.4        deploy
        cp "$path"/libQtNetwork.so.4     deploy
        cp "$path"/libQtScript.so.4      deploy
        cp "$path"/libQtXml.so.4         deploy
        cp "$path"/libQtXmlPatterns.so.4 deploy
    else
        cp "$path"/libQt5Core.so.5        deploy
        cp "$path"/libQt5Network.so.5     deploy
        cp "$path"/libQt5Qml.so.5         deploy
        cp "$path"/libQt5Xml.so.5         deploy
        cp "$path"/libQt5XmlPatterns.so.5 deploy
    fi

elif [ $1 = "android" ]; then

    if [ $qt = "qt5" ]; then

        cp "$path"/libQt5Core_*.so        deploy
        cp "$path"/libQt5Network_*.so     deploy
        cp "$path"/libQt5Qml_*.so         deploy
        cp "$path"/libQt5Xml_*.so         deploy
        cp "$path"/libQt5XmlPatterns_*.so deploy
    fi
fi

echo "-------------"
echo ""

#--------------------------------------------------------------------------------------------------
# clientVBML
#--------------------------------------------------------------------------------------------------

echo "COPYING $target"

if [ $os = "windows" ]; then

    cp bin/$target.exe deploy

elif [ $1 = "macOS" ]; then

    cp bin/$target deploy

    cd deploy

    #----------------------------------------------------------------------------------------------
    # Qt

    install_name_tool -change @rpath/QtCore.framework/Versions/5/QtCore \
                              @loader_path/QtCore.dylib $target

    install_name_tool -change @rpath/QtNetwork.framework/Versions/5/QtNetwork \
                              @loader_path/QtNetwork.dylib $target

    install_name_tool -change @rpath/QtQml.framework/Versions/5/QtQml \
                              @loader_path/QtQml.dylib $target

    install_name_tool -change @rpath/QtXml.framework/Versions/5/QtXml \
                              @loader_path/QtXml.dylib $target

    install_name_tool -change @rpath/QtXmlPatterns.framework/Versions/5/QtXmlPatterns \
                              @loader_path/QtXmlPatterns.dylib $target

    #----------------------------------------------------------------------------------------------

    cd -

elif [ $1 = "linux" ]; then

    cp bin/$target deploy

elif [ $1 = "android" ]; then

    cp bin/lib$target* deploy
fi
