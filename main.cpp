#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>
#include "settingsDialog.h"
#include "ModBusMaster.h"
#include "GuiHandler.h"
#include "StandTester.h"
#include <QJsonDocument>

int main(int argc, char *argv[])
{
    QApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    QApplication app(argc, argv);

    app.setOrganizationName("NIAC");
    app.setOrganizationDomain("vniizht.com");
    app.setApplicationName(QString("Assistant"));


    QQmlApplicationEngine engine;

//    QQuickView viewer;
//    QQmlContext *context = viewer.engine()->rootContext();
//    viewer.setSource(QUrl("qrc:/MainWindow.qml"));

    QQmlContext *context = engine.rootContext();
    qmlRegisterType<DiscreteOutSequenceModel>("DiscreteOutSequenceModel", 0, 1, "DiscreteOutSequenceModel");
    qmlRegisterType<TimerOutSequenceModel>("TimerOutSequenceModel", 0, 1, "TimerOutSequenceModel");
    qmlRegisterType<AnalogOutSequenceModel>("AnalogOutSequenceModel", 0, 1, "AnalogOutSequenceModel");
    GuiHandler hndl(context);
    engine.load(QUrl("qrc:/MainWindow.qml"));

    return app.exec();

}
