//=================================================================================================
/*
    Copyright (C) 2015-2020 clientVBML authors united with omega. <http://omega.gg/about>

    Author: Benjamin Arnaud. <http://bunjee.me> <bunjee@omega.gg>

    This file is part of clientVBML.

    - GNU General Public License Usage:
    This file may be used under the terms of the GNU General Public License version 3 as published
    by the Free Software Foundation and appearing in the LICENSE.md file included in the packaging
    of this file. Please review the following information to ensure the GNU General Public License
    requirements will be met: https://www.gnu.org/licenses/gpl.html.

    - Private License Usage:
    clientVBML licensees holding valid private licenses may use this file in accordance with the
    private license agreement provided with the Software or, alternatively, in accordance with the
    terms contained in written agreement between you and clientVBML authors. For further
    information contact us at contact@omega.gg.
*/
//=================================================================================================

#include "ControllerCore.h"

// Sk includes
#include <WControllerApplication>
#include <WControllerFile>
#include <WControllerPlaylist>
#include <WControllerMedia>

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString CORE_VERSION = "1.0.0-0";

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

ControllerCore::ControllerCore() : WController()
{
    //---------------------------------------------------------------------------------------------
    // Settings

    QString name = "clientVBML";

    sk->setName(name);

    sk->setVersion(CORE_VERSION);

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(WControllerPlaylist);
    W_CREATE_CONTROLLER(WControllerMedia);

    //---------------------------------------------------------------------------------------------
    // Log

    wControllerFile->initMessageHandler();

    //---------------------------------------------------------------------------------------------

    qDebug("%s %s", name.C_STR, CORE_VERSION.C_STR);
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::run(int & argc, char ** argv)
{
    if (argc < 3)
    {
        usage();

        return false;
    }

    return true;
}

//-------------------------------------------------------------------------------------------------
// Functions private
//-------------------------------------------------------------------------------------------------

bool ControllerCore::usage()
{
    qDebug("Usage: %s <backend> <function> <url>", sk->name().C_STR);

    return false;
}
