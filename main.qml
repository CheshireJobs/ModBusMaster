import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.3

Rectangle {
    id: mainWindow

    property string namePort: portsListModel.get(portsListView.currentIndex).name

    visible: true
    width: parent.width
    height: parent.height
    color: "#949fb1"

    GroupBox {
        id: groupBox

        x: 24
        y: 12
        width: parent.width * 3/4
        height: parent.height * 3/4
        title: qsTr("ВЫБЕРИТЕ УСТРОЙСТВО:")
        font.pixelSize: 16

        ListView {
            id: portsListView

            x: 36
            y: 61
            width: parent.width* 3/4
            height: parent.height * 3/4
            model: portsListModel
            delegate: Rectangle {
                width: parent.width
                height: 30
                color:  ListView.isCurrentItem? "transparent": "#E21A1A"
                border.width: 2
                border.color: ListView.isCurrentItem? "white" : "black"
                Text {
                    text: name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    color: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: portsListView.currentIndex = index
                }
            }
        }

    }

    RoundButton {
        id: roundButton

        x: 510
        y: 420
        width: 120
        height: 35
        text: "ПОДКЛЮЧИТЬ"
        font.pixelSize: 16
    }

    RoundButton {
        id: button

        x: 510
        y: 62
        width: 120
        height: 35
        text: qsTr("НАСТРОЙКА")
        font.pixelSize: 16
        onClicked: {
            settingsDialog.show()
        }
    }

    ListModel {
        id: portsListModel

        ListElement {
            name: "COM 1"
        }

        ListElement {
            name: "COM 2"
        }

        ListElement {
            name: "COM 3"
        }

        ListElement {
            name: "COM 4"
        }
    }

    Text {
        id: element
        x: 24
        y: 425
        width: 480
        height: 25
        text: qsTr("Text")
        font.pixelSize: 12
    }
}
