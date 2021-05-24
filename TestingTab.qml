import QtQuick 2.12
import QtQuick.Controls 2.5
import QtQuick.Controls 2.12

Item {
    id: testTab
    anchors.fill: parent

    GroupBox {
        id: discreteGroup
        anchors.top: parent.top
        anchors.left: parent.left
        width: parent.width
        height: 125
        title: "Дискретные выходы"

        Label {
            id: plusLabel
            height: discreteList.height
            width: 50
            anchors.top: parent.top

            anchors.left: parent.left
            Text {
                text: "+24"
                font.pixelSize: 12
                font.bold: true
                topPadding: 20
                leftPadding: 24
            }
        }
        Label {
            id: minusLabel
            height: discreteList.height
            width: 50
            anchors.top: plusLabel.bottom
            anchors.left: parent.left
            Text {
                text: "GND"
                font.pixelSize: 12
                font.bold: true
                topPadding: 20
                leftPadding: 24
            }
        }

        ListView {
            id: discreteList

            anchors.top: parent.top
            anchors.left: plusLabel.right
            anchors.right: parent.right
            height: parent.height / 2
            pixelAligned: true
            orientation: ListView.Horizontal
            model: 16
            interactive: false
            enabled: false

            delegate: CheckDelegate {
                id: checkElement
                width: 50
                checked: true// modelData.value === 1? true : false
                spacing: 0
                opacity: checked? 1 : 0.5
                enabled: false

                indicator: Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        x: checkElement.width - width - checkElement.rightPadding
                        y: checkElement.topPadding + checkElement.availableHeight / 2 - height / 2
                        radius: 3
                        color: "transparent"
                        border.color: checkElement.down ? "#17a81a" : "#21be2b"

                        Rectangle {
                            width: 25
                            height: 25
                            x: 2.5
                            y: 2.5
                            radius: 3
                            color: checkElement.checked ? "#21be2b" : "gray"
                            border.color: checkElement.down ? "#17a81a" : "#21be2b"

                            Text {
                                text: index + 1
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideMiddle
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                            }
                        }

                    }

                background: Rectangle {
                    implicitWidth: 60
                    implicitHeight: 40
                    visible: checkElement.down || checkElement.highlighted
                    color: checkElement.down ? "#bdbebf" : "#eeeeee"
                }
            }
        }

        ListView {
            id: discreteList2
            anchors.top: discreteList.bottom
            anchors.left: minusLabel.right
            anchors.right: parent.right
            height: parent.height / 2
            orientation: ListView.Horizontal
            model: 16
            interactive: false
            enabled: false

            delegate: CheckDelegate {
                id: checkElement2

                width: 50
                checked: modelData.value === 1? true : false
                spacing: 0
                opacity: checked? 1 : 0.5
                enabled: false

                indicator: Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
                        x: checkElement2.width - width - checkElement2.rightPadding
                        y: checkElement2.topPadding + checkElement2.availableHeight / 2 - height / 2
                        radius: 3
                        color: "transparent"
                        border.color: checkElement2.down ? "#17a81a" : "#21be2b"

                        Rectangle {
                            width: 25
                            height: 25
                            x: 2.5
                            y: 2.5
                            radius: 3
                            color: checkElement2.checked ? "#21be2b" : "gray"
                            border.color: checkElement2.down ? "#17a81a" : "#21be2b"

                            Text {
                                text: index + 1
                                anchors.fill: parent
                                horizontalAlignment: Text.AlignHCenter
                                elide: Text.ElideMiddle
                                font.pixelSize: 18
                                font.bold: true
                                color: "white"
                            }
                        }
                    }

                background: Rectangle {
                    implicitWidth: 60
                    implicitHeight: 40
                    visible: checkElement2.down || checkElement2.highlighted
                    color: checkElement2.down ? "#bdbebf" : "#eeeeee"
                }

            }
        }
    }

    GroupBox {
        id: analogGroup
        anchors.top: discreteGroup.bottom
        anchors.left: parent.left
        width: parent.width
        height: 125
        title: "Аналоговые выходы"

        ListView {
            id: analogList

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 10
            height: parent.height / 2
            pixelAligned: true
            orientation: ListView.Horizontal
            model: 10
            interactive: false
            enabled: false

            delegate: CheckDelegate {
                id: checkElementAnalog
                width: 50
                checked: true //modelData.value === 1? true : false
                spacing: 0

                indicator: Rectangle {
                        implicitWidth: 30
                        implicitHeight: 30
//                        x: checkElementAnalog.width - width - checkElementAnalog.rightPadding
//                        y: checkElementAnalog.topPadding + checkElementAnalog.availableHeight / 2 - height / 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 15
                        color: "transparent"
                        border.color: checkElementAnalog.checked ? "gray" : "transparent"
                        border.width: 2

                        Rectangle {
                            width: 20
                            height: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            radius: 10
                            color: checkElementAnalog.checked ? "#21be2b" : "transparent"
                            opacity: 0.5

                            Rectangle {
                                width: 20
                                height: 20
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                color: "transparent"
                                border.color: checkElementAnalog.checked? "#21be2b" : "gray"
                                border.width: 3
                                radius: 10
                            }
                        }
                    }
                Text {
                    text: index + 1
                    anchors.fill: parent
                    elide: Text.ElideMiddle
                    font.pixelSize: 12
                    font.bold: checkElementAnalog.checked ? true : false
                    color: checkElementAnalog.checked ? "#21be2b" : "gray"
                }
                Text {
                    text: "-24" + "В"
                    z: +1
                    anchors.fill: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignBottom
                    elide: Text.ElideMiddle
                    font.pixelSize: 12
                    font.bold: checkElementAnalog.checked ? true : false
                    color: checkElementAnalog.checked ? "black" : "transparent"
                }
                background: Rectangle {
                    implicitWidth: 20
                    implicitHeight: 20
                    radius: 10
                    visible: checkElementAnalog.down || checkElementAnalog.highlighted
                    color: checkElementAnalog.down ? "#bdbebf" : "#eeeeee"
                }
            }

        }


    }

    GroupBox {
        id: interfacesGroup
        anchors.top: analogGroup.bottom
        anchors.left: parent.left
        width: parent.width
        height: 130
        title: "Интерфейсы"

        Rectangle {
            id: canGroup
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.leftMargin: 15
            border.color: "lightgray"
            width: 300
            height: 80

            Rectangle {
                id: titileInterfaseCanGroup
                anchors.top: parent.top
                color: "lightgray"
                border.color: "gray"
                width: parent.width
                height: 15
                radius: 5

                Text {
                    id: txt
                    text: "CAN"
                    anchors.right: parent.right
                    width: 30
                    height: parent.height
                }
            }

            Rectangle {
                id: rectCan1
                width: 120
                anchors.left: parent.left
                anchors.top: titileInterfaseCanGroup.bottom
                anchors.margins: 8
                height: 20
                border.color: "#21be2b"

                Text {
                    anchors.fill: parent
                    text: "J1939" //modelData
                    color: "#21be2b"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: rectCan2
                width: 120
                anchors.left: parent.left
                anchors.top: rectCan1.bottom
                anchors.margins: 8
                height: 20
                border.color: "#21be2b"

                Text {
                    anchors.fill: parent
                    text: "АСКУМ" //modelData
                    color: "#21be2b"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: indicatorCan1
                anchors.left: rectCan1.right
                anchors.verticalCenter: rectCan1.verticalCenter
                anchors.margins: 10
                width: 16
                height: 16
                radius: 8
                color: "#21be2b" //"#bdbebf" //: "#eeeeee"
            }

            Rectangle {
                id: indicatorCan2
                anchors.left: rectCan2.right
                anchors.verticalCenter: rectCan2.verticalCenter
                anchors.margins: 10
                width: 16
                height: 16
                radius: 8
                opacity: 0.5
                color: "red" // "#bdbebf" //: "#eeeeee"
            }
        }

        Rectangle {
            id: rs485Group
            anchors.left: canGroup.right
            anchors.leftMargin: 15
            width: 300
            height: 80
            border.color: "lightgray"
            border.width: 0.5
            Rectangle {
                id: titileInterfaseRsGroup
                color: "lightgray"
                border.color: "gray"
                width: parent.width
                height: 15
                radius: 5

                Text {
                    id: txt2
                    text: "RS-485"
                    width: 70
                    height: parent.height
                    anchors.right: parent.right
                }
            }

            Rectangle {
                id: rectRs1
                width: 120
                anchors.left: parent.left
                anchors.top: titileInterfaseRsGroup.bottom
                anchors.margins: 8
                height: 20
                border.color: "#21be2b"

                Text {
                    anchors.fill: parent
                    text: "J1939" //modelData
                    color: "#21be2b"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: rectRs2
                width: 120
                anchors.left: parent.left
                anchors.top: rectRs1.bottom
                anchors.margins: 8
                height: 20
                border.color: "#21be2b"

                Text {
                    anchors.fill: parent
                    text: "АСКУМ" //modelData
                    color: "#21be2b"
                    elide: Text.ElideRight
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Rectangle {
                id: indicatorRs1
                anchors.left: rectRs1.right
                anchors.verticalCenter: rectRs1.verticalCenter
                anchors.margins: 10
                width: 16
                height: 16
                radius: 8
                color: "#21be2b" //"#bdbebf" //: "#eeeeee"
            }

            Rectangle {
                id: indicatorRs2
                anchors.left: rectRs2.right
                anchors.verticalCenter: rectRs2.verticalCenter
                anchors.margins: 10
                width: 16
                height: 16
                radius: 8
                opacity: 0.5
                color: "red" // "#bdbebf" //: "#eeeeee"
            }
        }
    }

    GroupBox {
        id: functionalGroup
        anchors.top: interfacesGroup.bottom
        anchors.left: parent.left
        width: parent.width
        height: 125

        Button {
            id: testingButton
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.margins: 8
            enabled: false
            width: 70
            height: 28
            text: "Начать"
        }
    }


}
