SK = $$_PRO_FILE_PWD_/../Sky

SK_CORE    = $$SK/src/SkCore/src
SK_GUI     = $$SK/src/SkGui/src
SK_MEDIA   = $$SK/src/SkMedia/src
SK_BACKEND = $$SK/src/SkBackend/src

TARGET = clientVBML

DESTDIR = $$_PRO_FILE_PWD_/bin

contains(QT_MAJOR_VERSION, 4) {
    QT += network script xml xmlpatterns
} else {
    QT += network qml xml xmlpatterns
}

# NOTE: This makes sure we don't build against the gui dependency. It does not work for Qt4
#       because we need QDesktopServices.
contains(QT_MAJOR_VERSION, 5) {
    QT -= gui
}

CONFIG += console

macx:CONFIG -= app_bundle

contains(QT_MAJOR_VERSION, 5) {
    android:QT += androidextras
}

# C++17
contains(QT_MAJOR_VERSION, 4) {
    QMAKE_CXXFLAGS += -std=c++1z
} else {
    CONFIG += c++1z
}

DEFINES += QUAZIP_BUILD \
           SK_CONSOLE \
           SK_NO_QML SK_NO_PLAYER SK_NO_TORRENT \
           SK_CORE_LIBRARY SK_GUI_LIBRARY SK_MEDIA_LIBRARY SK_BACKEND_LIBRARY \
           SK_CHARSET SK_BACKEND_LOCAL #SK_BACKEND_LOG

deploy|android: DEFINES += SK_DEPLOY

unix:QMAKE_LFLAGS += "-Wl,-rpath,'\$$ORIGIN'"

include($$SK/src/Sk.pri)
include(src/global/global.pri)
include(src/controllers/controllers.pri)
include(src/kernel/kernel.pri)
include(src/io/io.pri)
include(src/thread/thread.pri)
include(src/media/media.pri)

include(src/3rdparty/qtsingleapplication/qtsingleapplication.pri)
include(src/3rdparty/quazip/quazip.pri)
include(src/3rdparty/libcharsetdetect/libcharsetdetect.pri)

INCLUDEPATH += $$SK/include/SkCore \
               $$SK/include/SkGui \
               $$SK/include/SkMedia \
               $$SK/include/SkBackend \
               $$SK/include \
               $$_PRO_FILE_PWD_/include/clientVBML

win32-msvc*:INCLUDEPATH += $$[QT_INSTALL_PREFIX]/include/QtZlib

win32:!win32-msvc*:LIBS += -L$$SK/lib -lz

# Windows dependency for ShellExecuteA
win32-msvc*:LIBS += shell32.lib

unix:LIBS += -lz

OTHER_FILES += 3rdparty.sh \
               configure.sh \
               build.sh \
               deploy.sh \
               environment.sh \
               README.md \
               LICENSE.md \
               AUTHORS.md \
               .azure-pipelines.yml \
               test/copy.sh \
               test/all.sh \
               test/duckduckgo.sh \
               test/youtube.sh \
               test/dailymotion.sh \
               test/vimeo.sh \
               test/twitch.sh \
               test/soundcloud.sh \
               test/tmdb.sh \
               test/lastfm.sh \
               test/opensubtitles.sh \
               dist/changes/1.1.0.md \
