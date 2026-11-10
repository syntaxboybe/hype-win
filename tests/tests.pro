QT += core gui qml quick quickcontrols2 multimedia widgets testlib pdf concurrent svg
unix:QT += dbus
win32:DEFINES += HYPE_QT_WEBP_FALLBACK
TEMPLATE = app
TARGET = hype-tests
INCLUDEPATH += ../src
SOURCES += tests.cpp ../src/deck.cpp ../src/renderer.cpp
HEADERS += ../src/deck.h ../src/renderer.h ../src/budget.h
RESOURCES += ../src/resources.qrc

SOURCES += ../src/syntax.cpp
HEADERS += ../src/syntax.h
SOURCES += ../src/pptx.cpp
HEADERS += ../src/pptx.h
LIBS += -lz
unix:LIBS += -lwebpdemux -lwebp

SOURCES += ../src/animationexport.cpp
HEADERS += ../src/animationexport.h

SOURCES += ../src/apptheme.cpp
HEADERS += ../src/apptheme.h
SOURCES += ../src/images.cpp
HEADERS += ../src/images.h
SOURCES += ../src/filedialog.cpp
SOURCES += ../src/recovery.cpp
HEADERS += ../src/filedialog.h
