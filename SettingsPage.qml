import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import DiscreteOutSequenceModel 0.1
import QtQuick.Dialogs 1.2


Rectangle {
    id: settings
    width: 1226
    height: 796
    color: "#f7f8fc"

    Text {
        id: text11
        x: 28
        y: 25
        color: "#252733"
        text: qsTr("Настройки")
        font.pixelSize: 18
        font.weight: Font.Bold
        font.bold: true
        font.family: "Mulish"
    }

    Rectangle {
            id: leftPanelSettings
            x: 28
            y: 78
            width: 347
            height: 271
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"

            DropShadow {
                id: equipmentShadow
                color: "#dde2ff"
                radius: 8
                anchors.fill: leftPanelSettings
                source: leftPanelSettings
                anchors.topMargin: 0
                z: -1
                fast: true
                verticalOffset: 2
                spread: 0
                anchors.rightMargin: 0
                samples: 18
                anchors.leftMargin: 0
                anchors.bottomMargin: 0
                horizontalOffset: 2
            }

            Text {
                id: text3
                x: 15
                y: 16
                width: 153
                height: 40
                color: "#252733"
                text: qsTr("Настройки боковой панели")
                font.pixelSize: 14
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                font.bold: true
                font.family: "Mulish"
            }

            Rectangle {
                id: obmen
                property bool isCurrentItem: true
                x: 2
                y: 69
                width: 343
                height: 50
                color: "#F7F8FC"

                Text {
                    id: text5
                    x: 49
                    y: 19
                    color: "#252733"
                    text: qsTr("Включить отображение журнала обмена данными")
                    font.pixelSize: 12
                    font.family: "Mulish"
                }

                Rectangle {
                    x: 0
                    y: 0
                    width: 345
                    height: 1
                    color: "#dfe0eb"
                    border.color: "#dfe0eb"
                }

                Rectangle {
                    id: obmenCheck
                    property bool isSelect: true
                    width: 15
                    height: 15
                    color: obmenCheck.isSelect ? "#3751FF" : "transparent"
                    radius: height / 2
                    border.color: obmenCheck.isSelect? "#3751FF" : "#dfe0eb"
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 16
                    anchors.verticalCenterOffset: 2

                    Text {
                        anchors.fill: parent
                        text: qsTr("\u2713")
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pointSize: 9
                        color: "white"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
//                            obmenCheck.isSelect = !obmenCheck.isSelect
//                            mainWindow.listView.model.get(4).visible =
//                                    obmenCheck.isSelect? true : false
                        }
                    }
                }

                MouseArea {
                    anchors.left: obmenCheck.right
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    onClicked: {
                        obmen.isCurrentItem = true
                        obmen.color = "#F7F8FC"
                    }
                }
            }
        }


}


