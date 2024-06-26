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

#ifndef CONTROLLERCORE_H
#define CONTROLLERCORE_H

// Sk includes
#include <WController>

// Defines
#define core ControllerCore::instance()

// Forward declarations
class WControllerFileReply;
class WBackendIndex;
class WMediaReply;
class WPlaylist;
class WLibraryFolder;

class ControllerCore : public WController
{
    Q_OBJECT

private:
    ControllerCore();

public: // Interface
    Q_INVOKABLE bool run(int & argc, char ** argv);

private: // Functions
    void usage() const;

    void createIndex();

    WControllerFileReply * copyBackends() const;

    bool loadTrack   (const QString & url);
    bool loadPlaylist(const QString & url);

    bool loadCover(const QString & label, const QString & q);

    void writeOutput() const;

    QString vbml(const QString & content) const;

private slots:
    void onLoaded();

    void onIndexLoaded ();
    void onIndexUpdated();

    void onMedia   ();
    void onTrack   ();
    void onPlaylist();
    void onFolder  ();

private: // Variables
    QString _path;

    WBackendIndex * _index;

    WMediaReply    * _media;
    WPlaylist      * _playlist;
    WLibraryFolder * _folder;

    QString _url;

    QString _output;

private:
    Q_DISABLE_COPY      (ControllerCore)
    W_DECLARE_CONTROLLER(ControllerCore)
};

#endif // CONTROLLERCORE_H
