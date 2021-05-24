QT  += charts qml quick gui
QT  += widgets serialport
QT  += quickwidgets
QT  += core gui serialbus

# remove possible other optimization flags
QMAKE_CXXFLAGS_RELEASE -= -O2

win32:RC_ICONS += icon.ico

CONFIG += c++11

INCLUDEPATH += $$PWD

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
        AnalogOutSequenceModel.cpp \
        DiscreteOutSequenceModel.cpp \
        GuiHandler.cpp \
        ModBusMaster.cpp \
        Requester.cpp \
        StandTester.cpp \
        TimerOutSequenceModel.cpp \
        log.cpp \
        main.cpp \
        settingsDialog.cpp

RESOURCES += qml.qrc \
    icons.qrc \
    sequences.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Additional import path used to resolve QML modules just for Qt Quick Designer
QML_DESIGNER_IMPORT_PATH =

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    AnalogOutSequenceModel.h \
    DiscreteOutSequenceModel.h \
    GuiHandler.h \
    ModBusMaster.h \
    Requester.h \
    StandTester.h \
    TimerOutSequenceModel.h \
    log.h \
    settingsDialog.h \
    stand_defs.h

DISTFILES += \
    AnalogPage.qml \
    AutoTestPage.qml \
    CustomTestPage.qml \
    DevicePage.qml \
    DiscretePage.qml \
    Log.qml \
    MainWindow.qml \
    SettingsPage.qml \
    TimerPage.qml \
    TypeCarTestTab.qml

