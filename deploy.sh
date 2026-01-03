#!/bin/sh
set -e

#--------------------------------------------------------------------------------------------------
# Settings
#--------------------------------------------------------------------------------------------------

target="clientVBML"

Sky="../Sky"

backend="../backend"

#--------------------------------------------------------------------------------------------------
# environment

compiler_win="mingw"

qt="qt6"

#--------------------------------------------------------------------------------------------------
# Functions
#--------------------------------------------------------------------------------------------------

deployMacOS()
{
    installMacOS "$target" ""

    if [ -f "QtWebEngineProcess" ]; then

        installMacOS "QtWebEngineProcess" ""
    fi

    for file in *.dylib; do

        [ -e "$file" ] || continue

        installMacOS "$file" ""
    done

    find platforms \
         imageformats \
         tls \
         multimedia \
         QtQuick \
         QtQml \
         QtMultimedia \
         QtWebView \
         QtWebEngine \
         QtWebChannel \
    -name "*.dylib" | while read -r plugin; do

        case "$plugin" in
            */*/*/*) path="../../" ;;
            *)       path="../"    ;;
        esac

        installMacOS "$plugin" "$path"
    done
}

installMacOS()
{
    list=$(otool -L "$1" | grep -o "Qt[A-Za-z0-9]*\.framework" | sed 's/\.framework//' | sort -u)

    for library in $list; do

        install_name_tool -change "@rpath/$library.framework/Versions/$qx/$library" \
                                  "@loader_path/${2}${library}.dylib" "$1" 2>/dev/null
    done
}

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

if [ $qt = "qt5" ]; then

    QtX="Qt5"

    qx="5"

elif [ $qt = "qt6" ]; then

    QtX="Qt6"

    if [ $1 = "macOS" ]; then

        qx="A"
    else
        qx="6"
    fi
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
# Bundle
#--------------------------------------------------------------------------------------------------

deploy="deploy"

#--------------------------------------------------------------------------------------------------
# Sky
#--------------------------------------------------------------------------------------------------

echo "DEPLOYING Sky"
echo "-------------"

cd "$Sky"

sh deploy.sh $1 tools

cd -

path="$Sky/deploy"

#--------------------------------------------------------------------------------------------------
# Qt
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    if [ $compiler = "mingw" ]; then

        cp "$path"/libgcc_s_*-1.dll    $deploy
        cp "$path"/libstdc++-6.dll     $deploy
        cp "$path"/libwinpthread-1.dll $deploy
    fi

    if [ $qt = "qt4" ]; then

        cp "$path"/QtCore4.dll        $deploy
        cp "$path"/QtNetwork4.dll     $deploy
        cp "$path"/QtScript4.dll      $deploy
        cp "$path"/QtXml4.dll         $deploy
        cp "$path"/QtXmlPatterns4.dll $deploy
    else
        if [ $qt = "qt6" ]; then

            mkdir -p $deploy/tls
        fi

        cp "$path/$QtX"Core.dll    $deploy
        cp "$path/$QtX"Network.dll $deploy
        cp "$path/$QtX"Qml.dll     $deploy
        cp "$path/$QtX"Xml.dll     $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/$QtX"XmlPatterns.dll $deploy
        else
            cp "$path/$QtX"Core5Compat.dll $deploy

            cp "$path"/tls/qopensslbackend.dll  $deploy/tls
            cp "$path"/tls/qschannelbackend.dll $deploy/tls
        fi
    fi

elif [ $1 = "macOS" ]; then

    if [ $qt != "qt4" ]; then

        if [ $qt = "qt6" ]; then

            mkdir -p $deploy/tls
        fi

        # FIXME Qt 5.14 macOS: We have to copy qt.conf to avoid a segfault.
        cp "$path"/qt.conf $deploy

        cp "$path"/QtCore.dylib    $deploy
        cp "$path"/QtNetwork.dylib $deploy
        cp "$path"/QtQml.dylib     $deploy
        cp "$path"/QtXml.dylib     $deploy

        if [ $qt = "qt5" ]; then

            cp "$path"/QtXmlPatterns.dylib $deploy
        else
            cp "$path"/QtCore5Compat.dylib $deploy

            cp "$path"/tls/libqopensslbackend.dylib         $deploy/tls
            cp "$path"/tls/libqsecuretransportbackend.dylib $deploy/tls
        fi
    fi

elif [ $1 = "linux" ]; then

    if [ $qt = "qt4" ]; then

        cp "$path"/libQtCore.so.4        $deploy
        cp "$path"/libQtNetwork.so.4     $deploy
        cp "$path"/libQtScript.so.4      $deploy
        cp "$path"/libQtXml.so.4         $deploy
        cp "$path"/libQtXmlPatterns.so.4 $deploy
    else
        if [ $qt = "qt6" ]; then

            mkdir -p $deploy/tls
        fi

        cp "$path"/libicudata.so.* $deploy
        cp "$path"/libicui18n.so.* $deploy
        cp "$path"/libicuuc.so.*   $deploy

        cp "$path/lib$QtX"Core.so.$qx    $deploy
        cp "$path/lib$QtX"Network.so.$qx $deploy
        cp "$path/lib$QtX"Qml.so.$qx     $deploy
        cp "$path/lib$QtX"Xml.so.$qx     $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/lib$QtX"XmlPatterns.so.$qx $deploy
        else
            cp "$path/lib$QtX"Core5Compat.so.$qx $deploy

            cp "$path"/tls/libqopensslbackend.so $deploy/tls
        fi
    fi

elif [ $1 = "android" ]; then

    if [ $qt != "qt4" ]; then

        cp "$path/lib$QtX"Core_*.so    $deploy
        cp "$path/lib$QtX"Network_*.so $deploy
        cp "$path/lib$QtX"Qml_*.so     $deploy
        cp "$path/lib$QtX"Xml_*.so     $deploy

        if [ $qt = "qt5" ]; then

            cp "$path/lib$QtX"XmlPatterns_*.so $deploy
        else
            cp "$path/lib$QtX"Core5Compat_*.so $deploy
        fi
    fi
fi

#--------------------------------------------------------------------------------------------------
# SSL
#--------------------------------------------------------------------------------------------------

if [ $os = "windows" ]; then

    if [ $qt = "qt4" ]; then

        cp "$path"/libeay32.dll $deploy
        cp "$path"/ssleay32.dll $deploy
    else
        cp "$path"/libssl*.dll    $deploy
        cp "$path"/libcrypto*.dll $deploy
    fi

elif [ $1 = "linux" ]; then

    cp "$path"/libssl.so*    $deploy
    cp "$path"/libcrypto.so* $deploy
fi

echo "-------------"
echo ""

#--------------------------------------------------------------------------------------------------
# clientVBML
#--------------------------------------------------------------------------------------------------

echo "COPYING $target"

if [ $os = "windows" ]; then

    cp bin/$target.exe $deploy

elif [ $1 = "macOS" ]; then

    cp bin/$target $deploy

    cd $deploy

    deployMacOS

    cd -

    codesign --force --deep --sign - deploy/$target.app

elif [ $1 = "linux" ]; then

    cp bin/$target $deploy

elif [ $1 = "android" ]; then

    cp bin/lib$target* $deploy
fi

#--------------------------------------------------------------------------------------------------
# backend
#--------------------------------------------------------------------------------------------------

if [ $1 != "android" ]; then

    echo "COPYING backend"

    mkdir -p $deploy/backend/cover

    cp "$backend"/cover/* $deploy/backend/cover

    cp "$backend"/*.vbml $deploy/backend
fi
