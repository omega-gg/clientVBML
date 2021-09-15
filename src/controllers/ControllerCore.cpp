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
#include <QTextStream>

// Sk includes
#include <WControllerApplication>
#include <WControllerFile>
#include <WControllerNetwork>
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

static const QString PATH_OUTPUT = "output.vbml";

//-------------------------------------------------------------------------------------------------
// Ctor / dtor
//-------------------------------------------------------------------------------------------------

ControllerCore::ControllerCore() : WController()
{
    _media    = NULL;
    _playlist = NULL;
    _folder   = NULL;

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

bool ControllerCore::usage() const
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

void ControllerCore::loadTrack(const QString & url)
{
    _playlist = new WPlaylist;

    connect(_playlist, SIGNAL(trackQueryCompleted()), this, SLOT(onTrack()));

    _playlist->addSource(url);

    _playlist->loadTrack(0);
}

void ControllerCore::loadPlaylist(const QString & url)
{
    _playlist = new WPlaylist;

    connect(_playlist, SIGNAL(queryCompleted()), this, SLOT(onPlaylist()));

    _playlist->loadSource(url);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::writeOutput() const
{
    // NOTE: Maybe another query is still loading.
    if (_media || _playlist || _folder) return;

    if (_output.isEmpty())
    {
        // NOTE: If the output is empty we return an erorr.
        QCoreApplication::exit(1);

        // NOTE: We need to return after 'exit'.
        return;
    }

    // NOTE: We are using the '%s' option otherwise we get random replacements when we have a '%1'.
    qDebug("%s", _output.C_STR);

    QFile file(PATH_OUTPUT);

    file.open(QIODevice::WriteOnly | QIODevice::Truncate);

    QTextStream stream(&file);

    stream << _output;

    QCoreApplication::exit(0);
}

//-------------------------------------------------------------------------------------------------

QString ControllerCore::vbml(const QString & content) const
{
    return "[VBML]\n" + content + "[/VBML]";
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

#if defined(SK_BACKEND_LOCAL) && defined(SK_DEPLOY) == false
    // NOTE: This makes sure that we have the latest local vbml loaded.
    WControllerFileReply * reply = copyBackends();

    connect(reply, SIGNAL(actionComplete(bool)), _index, SLOT(reload()));
#else
    _index->update();
#endif

    connect(_index, SIGNAL(loaded()), this, SLOT(onIndexUpdated()));
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

        // NOTE: We need to return after 'exit'.
        return;
    }

    bool exit = true;

    if (WBackendNet::checkQuery(_url))
    {
        qDebug("QUERY DETECTED");

        QUrl source(_url);

        WLibraryItem::Type type = backend->typeFromQuery(_url);

        if (type == WLibraryItem::Folder)
        {
            qDebug("FOLDER DETECTED");

            exit = false;

            _folder = new WLibraryFolder;

            connect(_folder, SIGNAL(queryCompleted()), this, SLOT(onFolder()));

            _folder->loadSource(_url);
        }
        else if (type == WLibraryItem::Playlist)
        {
            qDebug("PLAYLIST DETECTED");

            exit = false;

            loadPlaylist(_url);
        }

        QString method = WControllerNetwork::extractUrlValue(_url, "method");

        if (method == "cover")
        {
            qDebug("COVER DETECTED");

            exit = false;

            loadTrack(_url);
        }
    }
    else
    {
        QString id = backend->getTrackId(_url);

        if (id.isEmpty() == false)
        {
            qDebug("TRACK DETECTED");

            exit = false;

            _media = wControllerMedia->getMedia(_url);

            connect(_media, SIGNAL(loaded(WMediaReply *)), this, SLOT(onMedia()));

            loadTrack(_url);
        }

        WBackendNetPlaylistInfo info = backend->getPlaylistInfo(_url);

        if (info.isValid())
        {
            qDebug("PLAYLIST DETECTED");

            exit = false;

            loadPlaylist(_url);
        }
    }

    if (exit) QCoreApplication::exit(0);
}

//-------------------------------------------------------------------------------------------------

void ControllerCore::onMedia()
{
    qDebug("MEDIA LOADED");

    if (_media->medias().isEmpty() == false)
    {
        _output.append('\n' + vbml(_media->toVbml()));
    }

    _media = NULL;

    writeOutput();
}

void ControllerCore::onTrack()
{
    qDebug("TRACK LOADED");

    if (_playlist->trackTitle(0).isEmpty() == false
        ||
        _playlist->trackCover(0).isEmpty() == false)
    {
        // NOTE: We want the track VBML to appear first so we prepend it.
        _output.prepend(vbml(_playlist->trackVbml(0)));
    }

    // NOTE: Maybe we are still loading another query.
    if (_playlist->queryIsLoading()) return;

    _playlist = NULL;

    writeOutput();
}

void ControllerCore::onPlaylist()
{
    qDebug("PLAYLIST LOADED");

    if (_playlist->isEmpty() == false)
    {
        _output.append(vbml(_playlist->toVbml()));
    }

    // NOTE: Maybe we are still loading another query.
    if (_playlist->queryIsLoading()) return;

    _playlist = NULL;

    writeOutput();
}

void ControllerCore::onFolder()
{
    qDebug("FOLDER LOADED");

    if (_folder->isEmpty() == false)
    {
        _output.append(vbml(_folder->toVbml()));
    }

    // NOTE: Maybe we are still loading another query.
    if (_folder->queryIsLoading()) return;

    _folder = NULL;

    writeOutput();
}
