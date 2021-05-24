import QtQuick 2.0
import QtQuick.Window 2.12
import QtQuick.Controls 2.5

Dialog {
    id: settingsDialogView

    property string nameCurrentPort : settingsDialog.portsInfoList[0].name

    function onConnectedClicked() {
        if( hndl.onConnectedClicked( nameCurrentPort, parseInt(modelBaudRate.get(baudRate.currentIndex).text),
                    parseInt(modelDataBits.get(dataBits.currentIndex).text),
                    parseInt(modelPairty.get(pairty.currentIndex).text),
                    parseInt(modelStopBits.get(stopBits.currentIndex).text) )) {
            close()
            hndl.setDiscreteSettings()
//            hndl.readAnalogCount()
            device.nameDevice = nameCurrentPort
            mainWindow.addIDIntoModel()
        } else
            close()
    }

    Connections {
        target: settingsDialog
    }

    Component.onCompleted: {
        portsListView.currentIndex = 0
    }

    width: parent.width
    height: parent.height
    anchors.centerIn: parent.Center
    modal: true

    GroupBox {
        id: portsInfo

        width: parent.width / 2
        height: parent.height  - statusBar.height
        anchors.top: parent.top
        anchors.left: parent.left
        title: qsTr("Доступные порты")

        ListView {
            id: portsListView
            interactive: false

            width: parent.width
            height: parent.height
            model: settingsDialog.portsInfoList
            delegate: Rectangle {
                id: rect
                width: parent.width
                height: 30
                color:  ListView.isCurrentItem? "#338cd4" : "gray"
                border.width: 0.5
                border.color: ListView.isCurrentItem? "lightgray" : "gray"
                Text {
                    id: txt
                    text: modelData.name
                    anchors.verticalCenter: parent.verticalCenter
                    font.bold: true
                    color: "white"
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        portsListView.currentIndex = index
                        nameCurrentPort = modelData.name
                    }
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }

            }
        }
    }

    GroupBox {
        id: parameters
        width: parent.width / 2
        height: parent.height - statusBar.height
        anchors.top: parent.top
        anchors.right: parent.right
        title: qsTr("Параметры")

        Row {
            id: labelsRow
            anchors.fill: parent
            spacing: 20

            Column {
                id: labelsColumn
                spacing: stopBits.height

                Label {
                    id: baudRateLabel
                    width: 98
                    height: 25
                    text: "Бит в секунду:"
                    font.pointSize: 11
                }
                Label {
                    id: dataBitsLabel
                    width: 98
                    height: 25
                    text: "Биты данных:"
                    font.pointSize: 11
                }
                Label {
                    id: pairyLabel
                    width: 98
                    height: 25
                    text: "Четность:"
                    font.pointSize: 11
                }
                Label {
                    id: stopBitsLabel
                    width: 107
                    height: 25
                    text: "Стоповые биты:"
                    font.pointSize: 11
                }
            }

            Column {
                id: cmbColumn
                spacing: baudRate.height

                ComboBox {
                    id: baudRate

                    width: 130
                    height: 25
                    editable: false
                    model: ListModel {
                        id: modelBaudRate
                        ListElement { text: "9600" }
                        ListElement { text: "19200" }
                        ListElement { text: "38400" }
                        ListElement { text: "115200"}
                    }
                    currentIndex: 3
                    MouseArea {
                        onEntered: {
                            cursorShape = Qt.PointingHandCursor
                        }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                        }
                    }
                }
                ComboBox {
                    id: dataBits

                    width: 130
                    height: 25
                    editable: false
                    model: ListModel {
                        id: modelDataBits
                        ListElement { text: "5"}
                        ListElement { text: "6"}
                        ListElement { text: "7"}
                        ListElement { text: "8"}
                    }
                    currentIndex: 3
                    MouseArea {
                        onEntered: {
                            cursorShape = Qt.PointingHandCursor
                        }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                        }
                    }
                }
                ComboBox {
                    id: pairty

                    width: 130
                    height: 25
                    editable: false
                    model: ListModel {
                        id: modelPairty
                        ListElement { text: "None"}
                        ListElement { text: "Even"}
                        ListElement { text: "Odd"}
                        ListElement { text: "Mark"}
                        ListElement { text: "Space"}
                    }
                    MouseArea {
                        onEntered: {
                            cursorShape = Qt.PointingHandCursor
                        }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                        }
                    }
                }
                ComboBox {
                    id: stopBits

                    width: 130
                    height: 25
                    editable: false
                    model: ListModel {
                        id: modelStopBits
                        ListElement { text: "1"}
                        ListElement { text: "1.5"}
                        ListElement { text: "2"}
                    }
                    MouseArea {
                        onEntered: {
                            cursorShape = Qt.PointingHandCursor
                        }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                        }
                    }
                }
            }
        }
    }

    Rectangle {
        id: statusBar

        width: parent.width
        height: 25
        anchors.top: parameters.bottom

        Row{
            id: buttonPanel
            spacing: 10
            anchors.right: parent.right

            RoundButton {
                id: connect

                width: 100
                height: 25
                text: "Подключить"
                onClicked: onConnectedClicked()
                MouseArea {
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }
            }
            RoundButton {
                id: cancel

                width: 100
                height: 25
                text: "Отмена"
                onClicked: close()
                MouseArea {
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                }
            }
        }

    }
}
