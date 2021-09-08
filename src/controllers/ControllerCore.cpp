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
#include <WPlaylist>

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
    _media    = NULL;
    _playlist = NULL;

    _error = false;

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

    if (argc != 2)
    {
        usage();

        return false;
    }

    _url = argv[1];

    qDebug("url: %s", _url.C_STR);

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
    qDebug("Usage: clientVBML <url>");

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

void ControllerCore::writeOutput()
{
    if (_error) QCoreApplication::exit(1);
    else        QCoreApplication::exit(0);
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
    // NOTE: This makes sure that we have the latest local vbml loaded.
    WControllerFileReply * reply = copyBackends();

    connect(reply, SIGNAL(actionComplete(bool)), _index, SLOT(reload()));

    // NOTE: We are mapping the 'loaded' signal on 'onIndexUpdated' to make sure we get notified
    //       when the index is reloaded.
    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexUpdated()));
#else
    _index->update();
#endif
}

void ControllerCore::onIndexUpdated()
{
    // NOTE: We don't want this slot to be called again.
    disconnect(_index, 0, this, SLOT(onIndexUpdated()));

    WBackendNet * backend = wControllerPlaylist->backendFromUrl(_url);

    if (backend == NULL)
    {
        qWarning("ControllerCore::onIndexUpdated: Cannot find a backend for %s.", _url.C_STR);

        QCoreApplication::exit(1);
    }

    bool exit = true;

    QString id = backend->getTrackId(_url);

    if (id.isEmpty() == false)
    {
        qDebug("TRACK DETECTED");

        exit = false;

        _media = wControllerMedia->getMedia(_url);

        connect(_media, SIGNAL(loaded(WMediaReply *)), this, SLOT(onMedia()));

        _playlist = new WPlaylist;

        connect(_playlist, SIGNAL(trackQueryCompleted()), this, SLOT(onTrack()));

        _playlist->addSource(_url);

        _playlist->loadTrack(0);
    }

    WBackendNetPlaylistInfo info = backend->getPlaylistInfo(_url);

    if (info.isValid())
    {
        qDebug("PLAYLIST DETECTED");

        exit = false;

        _playlist = new WPlaylist;

        connect(_playlist, SIGNAL(queryCompleted()), this, SLOT(onPlaylist()));

        _playlist->loadSource(_url);
    }

    if (exit) QCoreApplication::exit(0);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onMedia()
{
    qDebug("MEDIA LOADED");

    // NOTE: If 'medias' are empty then something is wrong.
    if (_media->medias().isEmpty())
    {
        _error = true;
    }

    _media = NULL;

    if (_playlist == NULL) // Maybe our 'track' is still loading.
    {
        writeOutput();
    }
}

void ControllerCore::onTrack()
{
    qDebug("TRACK LOADED");

    // NOTE: If the track 'title' is empty then something is wrong.
    if (_playlist->trackTitle(0).isEmpty())
    {
        _error = true;
    }

    _playlist = NULL;

    if (_media == NULL) // Maybe our 'media' is still loading.
    {
        writeOutput();
    }
}

void ControllerCore::onPlaylist()
{
    qDebug("PLAYLIST LOADED");

    // NOTE: If the playlist is empty then something is wrong.
    if (_playlist->isEmpty())
    {
        _error = true;
    }

    writeOutput();
}
