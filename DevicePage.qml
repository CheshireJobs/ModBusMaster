import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15


Rectangle {
    id: devicePadge
    property var nameCurrentPort: hndl.getState()? settingsDialog.m_currentNamePort : "нет данных" //settingsDialog.portsInfoList[portsList.currentIndex].name

    color: "#F7F8FC"

    Text {
        id: text1
        x: 27
        y: 22
        color: "#252733"
        text: qsTr("Подключение устройства")
        font.pixelSize: 20
        font.family: "Mulish"
        font.weight: Font.Bold
    }

    Rectangle {
        id: connectCard
        x: 27
        y: 70
        width: 169
        height: 105
        visible: true
        color: "#ffffff"
        radius: 8
        border.color:hndl.getState()? "#3751FF" :  "#dfe0eb"

        DropShadow {
            id: errorCardShadow
            color: "#dde2ff"
            radius: 8
            anchors.topMargin: 0
            z: -1
            anchors.rightMargin: 0
            verticalOffset: 2
            spread: 0
            fast: true
            samples: 18
            anchors.bottomMargin: 0
            horizontalOffset: 2
            anchors.leftMargin: 0
            source: connectCard
        }

        Text {
            id: text7
            x: 33
            y: 8
            width: 105
            height: 37
            color: hndl.getState()? "#3751FF" : "#9fa2b4"
            text: hndl.getState()? "Подключено" : "Устройство отключено"
            font.pixelSize: 13
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            font.family: "Mulish"
            font.bold: false
            font.weight: Font.Bold
        }

        Text {
            id: currentPortName
            x: 22
            y: 39
            width: 127
            height: 40
            visible: true
            color:  hndl.getState()? "#3751FF" : "#252733"
            text:  nameCurrentPort
            font.pixelSize: 16
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WrapAnywhere
            font.bold: true
            font.weight: Font.Bold
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
//                if(hndl.getState()) {
                    hndl.dicsonnectDevice()
                    nameCurrentPort = "нет данных"
                    connectCard.border.color = "#dfe0eb"
                    text7.color = "#9fa2b4"
                    text7.text = "Устройство отключено"
                    currentPortName.color = "#252733"
//                }
            }
            onEntered: {
                if(hndl.getState()) {
                    cursorShape = Qt.PointingHandCursor
                    connectCard.opacity = 0.8
                    text7.text = "Отключить"
                }
            }
            onExited: {
                cursorShape = Qt.ArrowCursor
                connectCard.opacity = 1
                text7.text = hndl.getState()? "Подключено" : "Устройство отключено"
            }

        }
    }

    Rectangle {
        id: availablePorts
        x: 27
        y: 209
        width: 1013
        height: 513
        visible: true
        color: "#ffffff"
        radius: 8
        border.color: "#dfe0eb"

        DropShadow {
            id: availablePortsShadow

            color: "#dde2ff"
            radius: 8
            anchors.topMargin: 0
            z: -1
            anchors.rightMargin: 0
            verticalOffset: 2
            spread: 0
            fast: true
            samples: 18
            anchors.bottomMargin: 0
            horizontalOffset: 2
            anchors.leftMargin: 0
            source: availablePorts
        }

        Text {
            id: text2
            x: 27
            y: 22
            color: "#252733"
            text: qsTr("Доступные порты")
            font.pixelSize: 14
            font.family: "Mulish"
            font.weight: Font.Bold
        }

        ListView {
            id: portsList
            x: 27
            y: 64

            width: 400
            height: 240

            model: settingsDialog.portsInfoList

            delegate:  Rectangle {
                id: portsListDelegate
                width: 400
                height: 40

                Rectangle {
                    id: boardsListRect
                    width: 400
                    height: 40
                    border.color: "#dfe0eb"
                    radius: 8

                    Rectangle {
                        id: rectCurrentElement
                        width: 15
                        height: 15
                        radius: height / 2
                        border.color: portsListDelegate.ListView.isCurrentItem? "#3751FF" : "#dfe0eb"
                        color: portsListDelegate.ListView.isCurrentItem? "#3751FF" : "transparent"
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 10

                        Text {
                            anchors.fill: parent
                            text: qsTr("\u2713")
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            color: "white"
                        }
                    }

                    Text {
                        id: parameterName2
                        anchors.left: rectCurrentElement.right
                        anchors.leftMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.name
                        font.pointSize: 8
                        //font.bold: true
                        font.family: "Mulish"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            portsList.currentIndex = index
                        }
                        hoverEnabled: true
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

        Rectangle {
            id: testParameters
            x: 476
            y: 64
            width: 347
            height: 325
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"
            DropShadow {
                id: testParametersShadow
                color: "#dde2ff"
                radius: 8
                anchors.fill: testParameters
                source: testParameters
                anchors.topMargin: 0
                z: -1
                anchors.rightMargin: 0
                verticalOffset: 2
                spread: 0
                fast: true
                samples: 18
                anchors.bottomMargin: 0
                horizontalOffset: 2
                anchors.leftMargin: 0
            }

            Text {
                id: text3
                x: 22
                y: 23
                color: "#252733"
                text: qsTr("Параметры подключения")
                font.pixelSize: 14
                font.bold: true
                font.pointSize: 11
                font.family: "Mulish"
                font.weight: Font.Bold
            }

            Text {
                id: text4
                x: 22
                y: 49
                width: 174
                height: 16
                color: "#9fa2b4"
                text: qsTr("выберите параметры подключения")
                font.pixelSize: 10
                verticalAlignment: Text.AlignVCenter
                font.bold: false
            }

            Rectangle {
                id: namePage3
                x: 2
                y: 119
                width: 343
                height: 50
                color: "#ffffff"
                Text {
                    id: text5
                    x: 19
                    y: 19
                    color: "#252733"
                    text: qsTr("Бит в секунду")
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

                ComboBox {
                    id: bits
                    x: 217
                    y: 7
                    width: 108
                    height: 37
                    background: Rectangle {
                        radius: 2
                        border.color: "#00000000"
                        border.width: bits.visualFocus ? 2 : 1
                        implicitWidth: 120
                        implicitHeight: 40
                    }
                    font.pointSize: 8
                    font.family: "Mulish"
                    font.bold: true
                    indicator: Canvas {
                        id: canvas
                        x: bits.width - width - bits.rightPadding
                        y: bits.topPadding + (bits.availableHeight - height) / 2
                        width: 12
                        height: 8
                        Connections {
                            target: bits
                            function onPressedChanged() { canvas.requestPaint(); }
                        }
                        contextType: "2d"
                    }
                    popup: Popup {
                        y: bits.height - 1
                        width: bits.width
                        background: Rectangle {
                            radius: 2
                            border.color: "#9fa2b4"
                        }
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            ScrollIndicator.vertical: ScrollIndicator {
                            }
                            currentIndex: bits.highlightedIndex
                            implicitHeight: contentHeight
                            model: bits.popup.visible ? bits.delegateModel : null
                            clip: true
                        }
                    }
                    model: ["9600","19200", "38400", "115200"]
                    currentIndex: 3
                    delegate: ItemDelegate {
                        width: bits.width
                        highlighted: bits.highlightedIndex === index
                        contentItem: Text {
                            id: delegate
                            color: "#252733"
                            text: modelData
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            font: bits.font
                        }
                    }
                    contentItem: Text {
                        width: 100
                        color: "#252733"
                        text:  bits.displayText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font: bits.font
                    }
                }
            }

            Rectangle {
                id: namePage6
                x: 2
                y: 169
                width: 343
                height: 50
                color: "#ffffff"
                Text {
                    id: text6
                    x: 20
                    y: 19
                    color: "#252733"
                    text: qsTr("Биты данных")
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

                ComboBox {
                    id: bitsData
                    x: 215
                    y: 5
                    width: 97
                    height: 40
                    background: Rectangle {
                        radius: 2
                        border.color: "#00000000"
                        border.width: bitsData.visualFocus ? 2 : 1
                        implicitWidth: 120
                        implicitHeight: 40
                    }
                    font.pointSize: 10
                    font.family: "Mulish"
                    font.bold: true
                    indicator: Canvas {
                        id: canvas1
                        x: bitsData.width - width - bitsData.rightPadding
                        y: bitsData.topPadding + (bitsData.availableHeight - height) / 2
                        width: 12
                        height: 8
                        Connections {
                            target: bitsData
                        }
                        contextType: "2d"
                    }
                    popup: Popup {
                        y: bitsData.height - 1
                        width: bitsData.width
                        background: Rectangle {
                            radius: 2
                            border.color: "#9fa2b4"
                        }
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            ScrollIndicator.vertical: ScrollIndicator {
                            }
                            currentIndex: bitsData.highlightedIndex
                            implicitHeight: contentHeight
                            model: bitsData.popup.visible ? bitsData.delegateModel : null
                            clip: true
                        }
                    }
                    model: ["5","6", "7", "8"]
                    currentIndex: 3
                    delegate: ItemDelegate {
                        width: bitsData.width
                        highlighted: bitsData.highlightedIndex === index
                        contentItem: Text {
                            id: delegate1
                            color: "#252733"
                            text: modelData
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            font: bitsData.font
                        }
                    }
                    contentItem: Text {
                        color: "#252733"
                        text: bitsData.displayText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font: bitsData.font
                    }
                }
            }

            Rectangle {
                id: namePage7
                x: 2
                y: 218
                width: 343
                height: 50
                color: "#ffffff"
                Text {
                    id: text8
                    x: 22
                    y: 19
                    color: "#252733"
                    text: qsTr("Четность")
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

                ComboBox {
                    id: pairty
                    x: 215
                    y: 5
                    background: Rectangle {
                        radius: 2
                        border.color: "#00000000"
                        border.width: pairty.visualFocus ? 2 : 1
                        implicitWidth: 120
                        implicitHeight: 40
                    }
                    font.pointSize: 10
                    font.family: "Mulish"
                    font.bold: true
                    popup: Popup {
                        y: pairty.height - 1
                        width: pairty.width
                        background: Rectangle {
                            radius: 2
                            border.color: "#9fa2b4"
                        }
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            ScrollIndicator.vertical: ScrollIndicator {
                            }
                            currentIndex: pairty.highlightedIndex
                            model: pairty.popup.visible ? pairty.delegateModel : null
                            implicitHeight: contentHeight
                            clip: true
                        }
                    }
                    indicator: Canvas {
                        id: canvas2
                        x: pairty.width - width - pairty.rightPadding
                        y: pairty.topPadding + (pairty.availableHeight - height) / 2
                        width: 12
                        height: 8
                        Connections {
                            target: pairty
                        }
                        contextType: "2d"
                    }
                    model: ["None","Even", "Odd", "Mark","Space"]
                    delegate: ItemDelegate {
                        width: pairty.width
                        highlighted: pairty.highlightedIndex === index
                        contentItem: Text {
                            id: delegate2
                            color: "#252733"
                            text: modelData
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            font: pairty.font
                        }
                    }
                    contentItem: Text {
                        color: "#252733"
                        text: pairty.displayText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font: pairty.font
                    }
                }
            }

            Rectangle {
                id: namePage8
                x: 2
                y: 267
                width: 343
                height: 50
                color: "#ffffff"
                Text {
                    id: text9
                    x: 24
                    y: 19
                    color: "#252733"
                    text: qsTr("Стоповые биты")
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

                ComboBox {
                    id: stopBits
                    x: 215
                    y: 5
                    background: Rectangle {
                        radius: 2
                        border.color: "#00000000"
                        border.width: stopBits.visualFocus ? 2 : 1
                        implicitWidth: 120
                        implicitHeight: 40
                    }
                    font.pointSize: 10
                    font.family: "Mulish"
                    font.bold: true
                    popup: Popup {
                        y: stopBits.height - 1
                        width: stopBits.width
                        background: Rectangle {
                            radius: 2
                            border.color: "#9fa2b4"
                        }
                        implicitHeight: contentItem.implicitHeight
                        padding: 1
                        contentItem: ListView {
                            ScrollIndicator.vertical: ScrollIndicator {
                            }
                            currentIndex: stopBits.highlightedIndex
                            model: stopBits.popup.visible ? stopBits.delegateModel : null
                            implicitHeight: contentHeight
                            clip: true
                        }
                    }
                    indicator: Canvas {
                        id: canvas3
                        x: stopBits.width - width - stopBits.rightPadding
                        y: stopBits.topPadding + (stopBits.availableHeight - height) / 2
                        width: 12
                        height: 8
                        Connections {
                            target: stopBits
                        }
                        contextType: "2d"
                    }
                    model: ["1","1.5", "2"]
                    delegate: ItemDelegate {
                        width: stopBits.width
                        highlighted: stopBits.highlightedIndex === index
                        contentItem: Text {
                            id: delegate3
                            color: "#252733"
                            text: modelData
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                            font: stopBits.font
                        }
                    }
                    contentItem: Text {
                        color: "#252733"
                        text: stopBits.displayText
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                        font: stopBits.font
                    }
                }
            }

            Rectangle {
                id: headerParamsList
                y: 89
                width: 337
                height: 30
                anchors.left: parent.left
                anchors.topMargin: 10
                Text {
                    id: parameterText
                    color: "#9fa2b4"
                    text: qsTr("Параметр")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    font.pointSize: 8
                    font.family: "Mulish"
                    anchors.leftMargin: 20
                }

                Text {
                    id: valueText
                    color: "#9fa2b4"
                    text: qsTr("Значение")
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.verticalCenterOffset: -1
                    anchors.leftMargin: 219
                    font.pointSize: 8
                    font.family: "Mulish"
                }
                anchors.leftMargin: 2
            }


        }

        Text {
            id: connectButton
            x: 861
            y: 450
            width: 100
            height: 24
            color: "#3751ff"
            text: qsTr("Подключить")
            font.pixelSize: 13
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            style: Text.Normal
            font.family: "Mulish"
            font.weight: Font.Bold
            styleColor: "#000000"
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    if(!hndl.getState()) {
                        if( hndl.onConnectedClicked(settingsDialog.portsInfoList[portsList.currentIndex].name,
                                    parseInt(bits.model[bits.currentIndex]),
                                    parseInt(bitsData.model[bitsData.currentIndex]),
                                    pairty.model[pairty.currentIndex],
                                    parseInt(stopBits.model[pairty.currentIndex])) ) {
                            hndl.setDiscreteSettings()
                            nameCurrentPort = settingsDialog.m_currentNamePort//portsInfoList[portsList.currentIndex].name
                            connectCard.border.color = "#3751ff"
                            text7.color = "#3751ff"
                            text7.text = "Подключено"
                            currentPortName.color = "#3751ff"
                        }
                    }
                }
                onEntered: {
                    if(!hndl.getState()) {
                        cursorShape = Qt.PointingHandCursor
                        connectButton.opacity = 0.8
                    }
                }
                onExited: {
                    cursorShape = Qt.ArrowCursor
                    connectButton.opacity = 1
                }
            }
        }
    }

}

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:1.33;height:800;width:1200}
}
##^##*/
