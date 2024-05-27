clientVBML
---
[![Discord](https://img.shields.io/discord/705770212485496852)](https://omega.gg/discord)
[![azure](https://dev.azure.com/bunjee/clientVBML/_apis/build/status/omega-gg.clientVBML)](https://dev.azure.com/bunjee/clientVBML/_build)
[![appveyor](https://ci.appveyor.com/api/projects/status/nc4cf1k90abftiyj?svg=true)](https://ci.appveyor.com/project/3unjee/clientVBML)
[![GPLv3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl.html)

clientVBML is a [VBML](https://omega.gg/VBML) console application built with Sky kit.<br>
Designed to retrieve and extract video resources through VBML [backends](https://github.com/omega-gg/backend).

## Usage

    clientVBML <url>

    Where <url> is the resource you want to retrieve and extract.

## Technology

clientVBML is built in C++ with [Sky kit](https://omega.gg/Sky/sources).<br>

## Platforms

- Windows XP and later.
- macOS 64 bit.
- Linux 32 bit and 64 bit.
- Android 32 bit and 64 bit.

## Requirements

- [Sky](https://omega.gg/Sky/sources) latest version.
- [Qt](https://download.qt.io/official_releases/qt) 4.8.0 / 5.5.0 or later.

On Windows:
- [MinGW](https://sourceforge.net/projects/mingw) or [Git for Windows](https://git-for-windows.github.io) with g++ 4.9.2 or later.

Recommended:
- [Qt Creator](https://download.qt.io/official_releases/qtcreator) 3.6.0 or later.

## Quickstart

You can configure and build clientVBML with a single line:

    sh build.sh <win32 | win64 | macOS | linux | android> all

For instance you would do that for Windows 64 bit:

    * open Git Bash *
    git clone https://github.com/omega-gg/clientVBML.git
    cd clientVBML
    sh build.sh win64 all

That's a convenient way to configure and build everything the first time.

Note: This will create the 3rdparty and Sky folder in the parent directory.

## Building

Alternatively, you can run each step of the build yourself by calling the following scripts:

Install the dependencies:

    sh 3rdparty.sh <win32 | win64 | macOS | linux | android> [all]

Configure the build:

    sh configure.sh <win32 | win64 | macOS | linux | android> [sky | clean]

Build the application:

    sh build.sh <win32 | win64 | macOS | linux | android> [all | deploy | clean]

Deploy the application and its dependencies:

    sh deploy.sh <win32 | win64 | macOS | linux | android> [clean]

## License

Copyright (C) 2015 - 2024 clientVBML authors | https://omega.gg/clientVBML

### Authors

- Benjamin Arnaud aka [bunjee](https://bunjee.me) | <bunjee@omega.gg>

### GNU General Public License Usage

clientVBML may be used under the terms of the GNU General Public License version 3 as published
by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
of this file. Please review the following information to ensure the GNU General Public License
requirements will be met: https://www.gnu.org/licenses/gpl.html.

### Private License Usage

clientVBML licensees holding valid private licenses may use this file in accordance with the
private license agreement provided with the Software or, alternatively, in accordance with the
terms contained in written agreement between you and clientVBML authors. For further information
contact us at contact@omega.gg.
