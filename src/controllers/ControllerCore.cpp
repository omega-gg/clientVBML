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

// Qt includes
#include <QCoreApplication>
#include <QDir>

// Sk includes
#include <WControllerApplication>
#include <WControllerFile>
#include <WControllerPlaylist>
#include <WControllerMedia>
#include <WBackendIndex>

W_INIT_CONTROLLER(ControllerCore)

//-------------------------------------------------------------------------------------------------
// Static variables

static const QString CORE_VERSION = "1.0.0-0";

#ifndef SK_DEPLOY
static const QString PATH_STORAGE = "/storage";
static const QString PATH_BACKEND = "../../backend";
#endif

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

ControllerCore::ControllerCore() : WController()
{
    //---------------------------------------------------------------------------------------------
    // Settings

    sk->setName("clientVBML");

    sk->setVersion(CORE_VERSION);

#ifdef SK_DEPLOY
    _path = QDir::fromNativeSeparators(WControllerFile::pathWritable());
#else
    _path = QDir::currentPath() + PATH_STORAGE;
#endif
}

//-------------------------------------------------------------------------------------------------
// Interface
//-------------------------------------------------------------------------------------------------

/* Q_INVOKABLE */ bool ControllerCore::run(int & argc, char ** argv)
{
    //---------------------------------------------------------------------------------------------
    // Log

    wControllerFile->initMessageHandler();

    //---------------------------------------------------------------------------------------------
    // Usage

    qDebug("clientVBML %s", sk->version().C_STR);

    if (argc < 2)
    {
        usage();

        return false;
    }

    QString url = argv[1];

    qDebug("url: %s", url.C_STR);

    //---------------------------------------------------------------------------------------------
    // Controllers

    W_CREATE_CONTROLLER(WControllerPlaylist);
    W_CREATE_CONTROLLER(WControllerMedia);

    //---------------------------------------------------------------------------------------------
    // Backend index

    QString path = _path + "/backend";

    if (QFile::exists(path) == false)
    {
        if (QDir().mkpath(path) == false)
        {
             qWarning("ControllerCore::run: Failed to create folder %s.", path.C_STR);

             return false;
        }

        WControllerFileReply * reply = copyBackends();

        connect(reply, SIGNAL(actionComplete(bool)), this, SLOT(onLoaded()));
    }
    else createIndex();

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
//-------------------------------------------------------------------------------------------------

void ControllerCore::createIndex()
{
    _index = new WBackendIndex(WControllerFile::fileUrl(_path + "/backend"));

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));
}

//-------------------------------------------------------------------------------------------------

WControllerFileReply * ControllerCore::copyBackends() const
{
#ifdef SK_DEPLOY
#ifdef Q_OS_ANDROID
    return WControllerPlaylist::copyBackends("assets:/backend", _path + "/backend/");
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath("backend"),
                                             _path + "/backend/");
#endif
#else
    return WControllerPlaylist::copyBackends(WControllerFile::applicationPath(PATH_BACKEND),
                                             _path + "/backend/");
#endif
}

//-------------------------------------------------------------------------------------------------
// Private slots
//-------------------------------------------------------------------------------------------------

void ControllerCore::onLoaded()
{
    createIndex();
}

void ControllerCore::onIndexLoaded()
{
    disconnect(_index, SIGNAL(loaded()), this, SLOT(onIndexLoaded()));

    connect(_index, SIGNAL(updated()), this, SLOT(onIndexUpdated()));

#if defined(SK_BACKEND_LOCAL) && defined(SK_DEPLOY) == false
    qDebug("INDEX UPDATING!");

    // NOTE: This makes sure that we have the latest local vbml loaded.
    WControllerFileReply * reply = copyBackends();

    connect(reply, SIGNAL(actionComplete(bool)), _index, SLOT(reload()));

    // NOTE: We are mapping the 'loaded' signal on the 'onIndexUpdated' slot to make sure we get
    //       notified when the index is reloaded.
    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexUpdated()));
#else
    _index->update();
#endif
}

void ControllerCore::onIndexUpdated()
{
    qDebug("INDEX UPDATED!");

    QCoreApplication::exit(0);
}
