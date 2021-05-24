import QtQuick 2.12
import QtQuick.Controls 2.5

Item {
    id: interfacesTab
    anchors.fill: parent

    Rectangle {
        id: borderInterfaceTab
        border.color: "gray"
        width: parent.width
        height: 130
        radius: 5

        Rectangle {
            id: labelRect
            anchors.top: parent.top
            width: parent.width
            height: 25
            radius: 5
            color: "lightgray"

            Text {
                id: labelTab
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter

                width: 201
                height: 25
                text: "Интерфейсы"
                font.pixelSize: 20
//                font.bold: true
                color: "black"
            }
        }

        GroupBox {
            id: canGroup
            width: 200
            height: 100
            anchors.top: labelRect.bottom
//            anchors.right: parent.horizontalCenter
            anchors.left: parent.left
            anchors.leftMargin: parent.width / 2 - canGroup.width - 20

            title: qsTr("CAN")

            ComboBox {
                id: comboBoxCan1
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 8
                height: 20
                model: ["none","J1939","АСКУМ", "ОГМ-240", "ОНК-160"]

                delegate: ItemDelegate {
                    width: comboBoxCan1.width
                    contentItem: Text {
                        text: modelData
                        color: "#21be2b"
                        font: comboBoxCan1.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: comboBoxCan1.highlightedIndex === index
                }

                indicator: Canvas {
                    id: canvas
                    x: comboBoxCan1.width - width - comboBoxCan1.rightPadding
                    y: comboBoxCan1.topPadding + (comboBoxCan1.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: comboBoxCan1
                        onPressedChanged: canvas.requestPaint()
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = comboBoxCan1.pressed ? "gray" : "lightgray"; //"#17a81a" : "#21be2b";
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 0
                    rightPadding: comboBoxCan1.indicator.width + comboBoxCan1.spacing

                    text: comboBoxCan1.displayText
                    font: comboBoxCan1.font
                    color: comboBoxCan1.pressed ? "#17a81a" : "#21be2b"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    border.color: comboBoxCan1.currentIndex === 0? "lightgray" : comboBoxCan1.pressed ? "#17a81a" : "#21be2b"
                    border.width: comboBoxCan1.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: comboBoxCan1.height - 1
                    width: comboBoxCan1.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBoxCan1.popup.visible ? comboBoxCan1.delegateModel : null
                        currentIndex: comboBoxCan1.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        border.color: "#21be2b"
                        radius: 2
                    }
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
                id: comboBoxCan2
                anchors.left: parent.left
                anchors.top: comboBoxCan1.bottom
                anchors.margins: 8
                height: 20
                model: ["none","J1939","АСКУМ", "АС-01"]

                delegate: ItemDelegate {
                    width: comboBoxCan2.width
                    contentItem: Text {
                        text: modelData
                        color: "#21be2b"
                        font: comboBoxCan2.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: comboBoxCan2.highlightedIndex === index
                }

                indicator: Canvas {
                    id: canvas2
                    x: comboBoxCan2.width - width - comboBoxCan2.rightPadding
                    y: comboBoxCan2.topPadding + (comboBoxCan2.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: comboBoxCan2
                        onPressedChanged: canvas2.requestPaint()
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = comboBoxCan2.pressed ? "gray" : "lightgray";//"#17a81a" : "#21be2b";
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 0
                    rightPadding: comboBoxCan2.indicator.width + comboBoxCan2.spacing

                    text: comboBoxCan2.displayText
                    font: comboBoxCan2.font
                    color: comboBoxCan2.pressed ? "#17a81a" : "#21be2b"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 40
                    border.color: comboBoxCan2.currentIndex === 0? "lightgray" : comboBoxCan2.pressed ? "#17a81a" : "#21be2b"
                    border.width: comboBoxCan2.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: comboBoxCan2.height - 1
                    width: comboBoxCan2.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBoxCan2.popup.visible ? comboBoxCan2.delegateModel : null
                        currentIndex: comboBoxCan2.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        border.color: "#21be2b"
                        radius: 2
                    }
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

        GroupBox {
            id: rs485Group
            anchors.top: labelRect.bottom
            anchors.left: canGroup.right
            anchors.leftMargin:  20
            width: 200
            height: 100
            title: qsTr("RS-485")

            ComboBox {
                id: comboBoxRs1
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.margins: 8
                height: 20
                model: ["none","ModBus Master","ModBus Slave"]

                delegate: ItemDelegate {
                    width: comboBoxRs1.width
                    contentItem: Text {
                        text: modelData
                        color: "#21be2b"
                        font: comboBoxRs1.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: comboBoxRs1.highlightedIndex === index
                }

                indicator: Canvas {
                    id: canvas3
                    x: comboBoxRs1.width - width - comboBoxRs1.rightPadding
                    y: comboBoxRs1.topPadding + (comboBoxRs1.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: comboBoxRs1
                        onPressedChanged: canvas3.requestPaint()
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = comboBoxRs1.pressed ? "gray" : "lightgray"; //"#17a81a" : "#21be2b";
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 0
                    rightPadding: comboBoxRs1.indicator.width + comboBoxRs1.spacing

                    text: comboBoxRs1.displayText
                    font: comboBoxRs1.font
                    color: comboBoxRs1.pressed ? "#17a81a" : "#21be2b"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 30
                    border.color: comboBoxRs1.currentIndex === 0? "lightgray" :comboBoxRs1.pressed ? "#17a81a" : "#21be2b"
                    border.width: comboBoxRs1.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: comboBoxRs1.height - 1
                    width: comboBoxRs1.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBoxRs1.popup.visible ? comboBoxRs1.delegateModel : null
                        currentIndex: comboBoxRs1.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        border.color: "#21be2b"
                        radius: 2
                    }
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
                id: comboBoxRs2
                anchors.left: parent.left
                anchors.top: comboBoxRs1.bottom
                anchors.margins: 8
                height: 20
                model: ["none","J1939","АСКУМ", "АС-01"]

                delegate: ItemDelegate {
                    width: comboBoxRs2.width
                    contentItem: Text {
                        text: modelData
                        color: "#21be2b"
                        font: comboBoxRs2.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }
                    highlighted: comboBoxRs2.highlightedIndex === index
                }

                indicator: Canvas {
                    id: canvas4
                    x: comboBoxRs2.width - width - comboBoxRs2.rightPadding
                    y: comboBoxRs2.topPadding + (comboBoxRs2.availableHeight - height) / 2
                    width: 12
                    height: 8
                    contextType: "2d"

                    Connections {
                        target: comboBoxRs2
                        onPressedChanged: canvas4.requestPaint()
                    }

                    onPaint: {
                        context.reset();
                        context.moveTo(0, 0);
                        context.lineTo(width, 0);
                        context.lineTo(width / 2, height);
                        context.closePath();
                        context.fillStyle = comboBoxRs2.pressed ? "gray" : "lightgray"; //"#17a81a" : "#21be2b";
                        context.fill();
                    }
                }

                contentItem: Text {
                    leftPadding: 0
                    rightPadding: comboBoxRs2.indicator.width + comboBoxRs2.spacing

                    text: comboBoxRs2.displayText
                    font: comboBoxRs2.font
                    color: comboBoxRs2.pressed ? "#17a81a" : "#21be2b"
                    verticalAlignment: Text.AlignVCenter
                    elide: Text.ElideRight
                }

                background: Rectangle {
                    implicitWidth: 120
                    implicitHeight: 30
                    border.color: comboBoxRs2.currentIndex === 0? "lightgray" : comboBoxRs2.pressed ? "#17a81a" : "#21be2b"
                    border.width: comboBoxRs2.visualFocus ? 2 : 1
                    radius: 2
                }

                popup: Popup {
                    y: comboBoxRs2.height - 1
                    width: comboBoxRs2.width
                    implicitHeight: contentItem.implicitHeight
                    padding: 1

                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: comboBoxRs2.popup.visible ? comboBoxRs2.delegateModel : null
                        currentIndex: comboBoxRs2.highlightedIndex

                        ScrollIndicator.vertical: ScrollIndicator { }
                    }

                    background: Rectangle {
                        border.color: "#21be2b"
                        radius: 2
                    }

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

        Button {
            id: saveChangesButton
            x: 540
            y: 104
            width: 100
            height: 26
            anchors.bottom: parent.bottom
            anchors.right: parent.right

            text: qsTr("Готово")
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
