import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: device

    property alias nameDevice : settings.nameCurrentPort
    property bool connected: master.status
    property string statusOff: " \u274C Устройство отключено"
    property string statusOn: " \u2713 " + nameDevice + " - подключено"
    property bool enabledInfo: master.status

    width: parent.width
    height: parent.height

    SettingsDialog {
        id: settings
    }

    Rectangle {
        id: statusBar
        width: parent.width
        height: 40

        Button{
            id: selectDevice
            width: 150
            height: 30
            anchors.left: parent.left
            text: "Выберите устройство..."
            font.pixelSize: 12
            onClicked: {
                settings.visible = true
            }
        }

        Text {
            id: statusDevice
            anchors.right: parent.right
            color: connected ?  "#21be2b" : "red"
            text: connected ? statusOn : statusOff
            font.pixelSize: 16
        }
    }

    GroupBox {
        id: deviceInfo
        width: parent.width
        height: parent.height - statusBar.height
        anchors.top: statusBar.bottom
        title: "Идентификационные данные"
        enabled: enabledInfo

        TextArea {
            id: idxData
            anchors.fill: parent
            text: hndl.infoText
            font.pixelSize: 14
        }
    }
}
