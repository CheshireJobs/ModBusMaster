import QtQuick 2.0
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15

Item {
    id: autoTestPage
    property var nameCurrentPort: hndl.getState()? settingsDialog.m_currentNamePort : "нет данных"

    width: parent.width
    height: parent.height
    property double timer: 0.0

    Component.onDestruction: {
       if(timerStartTest.running) {
           timerStartTest.stop()
       }
    }

    Connections {
        target: hndl
        onStopTestByTypeCar: {
            timerStartTest.start()
            progressBarTest.visible = true
        }
        onParamListChanged: {
            progressBarTest.value = 0.0
            timer = 0.0
        }
        onTestResultChanged: {
            resultTest.visible = true
            errorCard.visible = true
            okCard.visible = true
            warningCard.visible = true
            noCard.visible = true

            textResult.text = hndl.resultTest
            additionalResultInfo.text = hndl.additionalInfo
            errorCountText.text = hndl.countErrors.toString()
            okCountText.text = hndl.countOk.toString()
            warningCountText.text = hndl.countWarnings.toString()
            noCheckCountText.text = hndl.countCheck.toString()
        }
    }

    Timer {
        id: timerStartTest
        interval: 1000; running: false; repeat: true

        onTriggered: {
            if(timer < 150000) {
                timer += 1000
                progressBarTest.value = timer
            } else {
                stop()
                typeCar.enabled = true
                timer = 0.0
                hndl.getLocsRequest(1, imei.text , typeCar.currentText)
            }
        }
    }

    Rectangle {
        id: workArea
        width: 800
        anchors.fill: parent
        anchors.rightMargin: 0
        anchors.bottomMargin: 0
        anchors.leftMargin: 0
        anchors.topMargin: 0

        color: "#f7f8fc"
        border.color: "#dfe0eb"

        Rectangle {
            id: headerPage
            x: 22
            y: 21
            width: 800
            height: 42
            color: "#f7f8fc"

            Text {
                id: text1
                x: 0
                y: 7
                color: "#252733"
                text: qsTr("Тестирование")
                font.family: "Mulish"
                font.pixelSize: 20
                font.weight: Font.Bold
            }
        }

        Rectangle {
            id: testParameters
            x: 22
            y: 92
            width: 428
            height: 250
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"

            DropShadow {
                id: testParametersShadow
                color: "#dde2ff"
                anchors.fill: testParameters
                horizontalOffset: 2
                radius: 8.0
                spread: 0
                fast: true
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                verticalOffset: 2
                samples: 18
                source: testParameters
                z: -1
            }

            Text {
                id: text2
                x: 22
                y: 23
                color: "#252733"
                text: qsTr("Параметры оборудования")
                font.family: "Mulish"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                id: text4
                x: 22
                y: 49
                width: 377
                height: 16
                color: "#9fa2b4"
                text: qsTr("введите IMEI и выберите тип машины для начала тестирования")
                font.bold: true
                verticalAlignment: Text.AlignVCenter
                font.pixelSize: 11
            }

            Rectangle {
                id: namePage3
                x: 1
                y: 83
                width: 426
                height: 42
                color: "#ffffff"
                Text {
                    id: text5
                    x: 22
                    y: 13
                    color: "#252733"
                    text: qsTr("IMEI")
                    font.family: "Mulish"
                    font.pixelSize: 14
                }
                Item {
                    id: imeiItem
                    property int selectStart
                    property int selectEnd
                    property int curPos
                    x: 258
                    y: 11
                    width: 132
                    height: 20
                    MouseArea {
                        anchors.fill: imeiItem
                        hoverEnabled: true
                        onEntered: {
                            cursorShape = Qt.IBeamCursor
                        }
                        onExited: {
                            cursorShape = Qt.ArrowCursor
                         }
                        acceptedButtons: Qt.RightButton
                        onClicked: {
                            imeiItem.selectStart = imei.selectionStart;
                            imeiItem.selectEnd = imei.selectionEnd;
                            imeiItem.curPos = imei.cursorPosition;
                            contextMenu.x = mouse.x;
                            contextMenu.y = mouse.y;
                            contextMenu.open();
                            imei.cursorPosition = imeiItem.curPos;
                            imei.select(imeiItem.selectStart,imeiItem.selectEnd);
                        }
                        onPressAndHold: {
                            if (mouse.source === Qt.MouseEventNotSynthesized) {
                                imeiItem.selectStart = imei.selectionStart;
                                imeiItem.selectEnd = imei.selectionEnd;
                                imeiItem.curPos = imei.cursorPosition;
                                contextMenu.x = mouse.x;
                                contextMenu.y = mouse.y;
                                contextMenu.open();
                                imei.cursorPosition = imeiItem.curPos;
                                imei.select(imeiItem.selectStart,imeiItem.selectEnd);
                            }
                        }
                    }

                    TextInput {
                        id: imei

                        width: 132
                        height: 20
                        color: "#9fa2b4"
                        text: ""
                        enabled: timerStartTest.running? false : true
                        font.pixelSize: 12
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        selectByMouse: true
                        inputMask: "999999999999999"
                        maximumLength: 15
                        font.family: "Mulish"
                        cursorVisible: true
                    }
                    Menu {
                        id: contextMenu
                        MenuItem {
                            text: "Cut"
                            onTriggered: {
                                imei.cut()
                            }
                        }
                        MenuItem {
                            text: "Copy"
                            onTriggered: {
                                imei.copy()
                            }
                        }
                        MenuItem {
                            text: "Paste"
                            onTriggered: {
                                imei.paste()
                            }
                        }
                    }
                }


                Rectangle {
                    x: 0
                    y: 0
                    width: 426
                    height: 1
                    color: "#dfe0eb"
                    border.color: "#dfe0eb"
                }
            }

            Rectangle {
                id: namePage6
                x: 1
                y: 126
                width: 426
                height: 42
                color: "#ffffff"
                Text {
                    id: text6
                    x: 24
                    y: 13
                    color: "#252733"
                    text: qsTr("Тип машины")
                    font.family: "Mulish"
                    font.pixelSize: 14
                }

                ComboBox {
                    id: typeCar
                    model: ["не выбран","дуоматик", "динамик", "ВПРС",
                        "ПУМА","ПМА", "ПМА-С", "УНИМАТ КОМПАКТ",
                        "УНИМАТ", "ВПР-02", "ВПР-02М", "ВПР-02К",
                        "ВПРС-02", "ВПРС-03", "ВПРС-03К", "РБ",
                        "РПБ", "ПБ", "ПМГ", "ТЭС"]

                    x: 282
                    y: 2
                    font.family: "Mulish"
                    font.bold: true
                    font.pointSize: 10

                    delegate: ItemDelegate {

                        width: typeCar.width
                        contentItem: Text {
                            id: delegate
                            text: modelData
                            color: "#9fa2b4"
                            font: typeCar.font
                            elide: Text.ElideRight
                            verticalAlignment: Text.AlignVCenter
                        }
                        highlighted: typeCar.highlightedIndex === index
                    }

                    indicator: Canvas {
                        id: canvas
                        x: typeCar.width - width - typeCar.rightPadding
                        y: typeCar.topPadding + (typeCar.availableHeight - height) / 2
                        width: 12
                        height: 8
                        contextType: "2d"

                        Connections {
                            target: typeCar
                            function onPressedChanged() { canvas.requestPaint(); }
                        }

                        onPaint: {
                            context.reset();
                            context.moveTo(0, 0);
                            context.lineTo(width, 0);
                            context.lineTo(width / 2, height);
                            context.closePath();
                            context.fillStyle = "#9fa2b4";
                            context.fill();
                        }
                    }

                    contentItem: Text {
                        font: typeCar.font
                        color: "#9fa2b4"
                        text: typeCar.displayText
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }

                    background: Rectangle {
                        implicitWidth: 120
                        implicitHeight: 40
                        border.color: "transparent"
                        border.width: typeCar.visualFocus ? 2 : 1
                        radius: 2
                    }

                    popup: Popup {
                        y: typeCar.height - 1
                        width: typeCar.width
                        implicitHeight: contentItem.implicitHeight
                        padding: 1

                        contentItem: ListView {
                            clip: true
                            implicitHeight: contentHeight
                            model: typeCar.popup.visible ? typeCar.delegateModel : null
                            currentIndex: typeCar.highlightedIndex

                            ScrollIndicator.vertical: ScrollIndicator { }
                        }

                        background: Rectangle {
                            border.color: "#9fa2b4"
                            radius: 2
                        }
                    }
                    onCurrentIndexChanged: {
                        hndl.setTypeCar(model[currentIndex])
                    }

                }

                Rectangle {
                    x: 0
                    y: 41
                    width: 426
                    height: 1
                    color: "#dfe0eb"
                    border.color: "#dfe0eb"
                }

                Rectangle {
                    x: 0
                    y: 0
                    width: 426
                    height: 1
                    color: "#dfe0eb"
                    border.color: "#dfe0eb"
                }
            }

            ProgressBar {
                id: progressBarTest
                visible: false
                value: 0
                padding: 2
                to: 150000
                x: 22
                y: 215
                height: 10

                background: Rectangle {
                    implicitWidth: 200
                    implicitHeight: 6
                    color: "#e6e6e6"
                    radius: 3
                }

                contentItem: Item {
                    height: 8
                    implicitWidth: 200
                    implicitHeight: 4

                    Rectangle {
                        width: progressBarTest.visualPosition * parent.width
                        height: parent.height
                        radius: 2
                        color: "#3751ff"
                    }
                }
            }

            Text {
                id: startTestButton
                x: 299
                y: 196
                width: 100
                height: 46
                color: "#3751ff"
                text: qsTr("Начать тестирование")
                styleColor: "#000000"
                style: Text.Normal
                font.family: "Mulish"
                font.pixelSize: 14
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.WordWrap
                font.weight: Font.Bold
                enabled: timerStartTest.running? false : imei.text.length < 15 ? false : typeCar.currentText === "не выбран"? false : true
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                    onClicked: {
                        typeCar.enabled = false
                        hndl.getType(1, "868136035383846", typeCar.currentText)
                        resultTest.visible = false
                        errorCard.visible = false
                        okCard.visible = false
                        warningCard.visible = false
                        noCard.visible = false
                        deviceElements.visible = false
                        detailsButton.text = "Подробнее..."
                        detailsButton.isOpen = true
                        timerStartTest.start()
                        progressBarTest.visible = true
                    }
                }
            }
        }

        Rectangle {
            id: resultTest
            visible: false
            x: 485
            y: 92
            width: 428
            height: 250
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"

            DropShadow {
                id: resultTestShadow
                color: "#dde2ff"
                anchors.fill: resultTest
                horizontalOffset: 2
                radius: 8.0
                fast: true
                spread: 0
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                verticalOffset: 2
                samples: 18
                source: resultTest
                z: -1
            }

            Text {
                id: text3
                x: 19
                y: 21
                color: "#252733"
                text: qsTr("Результат тестирования")
                font.family: "Mulish"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Rectangle {
                id: namePage11
                x: 1
                y: 85
                width: 426
                height: 51
                color: "#ffffff"
                Text {
                    id: additionalResultInfo
                    x: 32
                    y: 13
                    width: 359
                    height: 31
                    color: "#252733" //"#c5c7cd"
                    text: qsTr("Нет данных")
                    font.family: "Mulish"
                    font.pixelSize: 12
                    wrapMode: Text.WordWrap
                }

                Rectangle {
                    id: namePage9
                    x: 0
                    y: 50
                    width: 428
                    height: 1
                    color: "#dfe0eb"
                    border.color: "#dfe0eb"
                }
            }

            Text {
                id: detailsButton
                property bool isOpen: true
                x: 261
                y: 21
                width: 146
                height: 22
                color: "#3751ff"
                text: qsTr("Подробнее...")
                font.bold: true
                font.family: "Mulish"
                font.pixelSize: 13
                horizontalAlignment: Text.AlignRight
                wrapMode: Text.WrapAnywhere
                font.weight: Font.Bold
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: {
                        cursorShape = Qt.PointingHandCursor
                    }
                    onExited: {
                        cursorShape = Qt.ArrowCursor
                    }
                    onClicked: {
                        if(detailsButton.isOpen) {
                            deviceElements.visible = true
                            detailsButton.text = "Скрыть..."
                            detailsButton.isOpen = !detailsButton.isOpen
                        } else {
                            deviceElements.visible = false
                            detailsButton.text = "Подробнее..."
                            detailsButton.isOpen = !detailsButton.isOpen
                        }


                    }
                }
            }

            Rectangle {
                id: rectResultTest
                x: 19
                y: 48
                width: textResult.contentWidth + 15
                height: 25

                color: textResult.text == "нет данных"? "#dfe0eb" :
                                                        hndl.testResult == 1? "#FEC400" :
                                                                              hndl.testResult == 2? "#F12B2C" : "#29CC97"
                radius: 21
                Text {
                    id: textResult
                    x: 6
                    y: 5
                    color: "#ffffff"
                    text: qsTr("нет данных")
                    font.family: "Mulish"
                    font.pixelSize: 13
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.bold: true
                    font.weight: Font.Normal
                    //                    color: "#252733"
                }
            }
        }

        Rectangle {
            id: deviceElements
            visible: false
            x: 20
            y: 369
            width: 1285
            height: 524
            color: "#ffffff"
            radius: 8
            border.color: "#dde2ff"

            DropShadow {
                id: deviceElementsShadow
                color: "#dfe0eb"
                anchors.fill: deviceElements
                horizontalOffset: 2
                radius: 8.0
                spread: 0
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                verticalOffset: 2
                samples: 18
                source: deviceElements
                z: -1
            }

            Text {
                id: text8
                x: 27
                y: 32
                color: "#252733"
                text: qsTr("Состав оборудования")
                font.family: "Mulish"
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                id: dateElementsResult
                x: 27
                y: 61
                width: 310
                height: 16
                color: "#9fa2b4"
                text: qsTr("as of 23 Mar 2021, 10:20 PM")
                font.family: "Mulish"
                font.pixelSize: 12
            }


            Rectangle {
                id: parametersTableRect // таблица параметров
                width: 800
                height: 392
                anchors.top: parent.top
                anchors.topMargin: 89
                anchors.left: parent.left
                anchors.leftMargin: 463
                radius: 8
                border.color: "#dfe0eb"

                Text {
                    id: headerParamsText
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 24
                    anchors.leftMargin: 21
                    text: "Все параметры"
                    font.family: "Mulish"
                    font.pixelSize: 14
                    font.bold: true
                }

                Rectangle {
                    id: headerParamsList
                    width: 798 // шапка таблицы параметров
                    height: 40
                    anchors.top: headerParamsText.bottom
                    anchors.topMargin: 10
                    anchors.left: parent.left
                    anchors.leftMargin: 1

                    Text {
                        id: parameterText
                        text: qsTr("Параметр")
                        font.pointSize: 10
                        font.family: "Mulish"
                        anchors.left: parent.left
                        anchors.leftMargin: 20
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#9FA2B4"
                    }

                    Text {
                        id: valueText
                        text: qsTr("Значение")
                        font.pointSize: 10
                        font.family: "Mulish"
                        anchors.left: parent.left
                        anchors.leftMargin: 10 + 370
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#9FA2B4"
                    }
                    Text {
                        id: resultText
                        text: qsTr("Результат тестирования")
                        font.pointSize: 10
                        font.family: "Mulish"
                        anchors.right: parent.right
                        anchors.rightMargin: 10
                        anchors.verticalCenter: parent.verticalCenter
                        color: "#9FA2B4"
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 1
                        color: "#9FA2B4"
                    }

                }

                ListView {
                    id: parametersList
                    width: 798
                    height: 291

                    anchors.top: headerParamsList.bottom
                    anchors.left: parent.left
                    anchors.leftMargin: 1

                    visible: true

                    boundsBehavior: Flickable.StopAtBounds
                    flickableDirection: Flickable.VerticalFlick
                    clip: true


                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AlwaysOn
                    }

                    model: componentsList.currentIndex === 0?
                               (hndl.akbParamList.isEmpty? 0 : hndl.akbParamList) :
                               componentsList.currentIndex === 1?
                                   (hndl.gpsParamList.isEmpty? 0 : hndl.gpsParamList) :
                                   componentsList.currentIndex === 2?
                                       (hndl.sdCardParamList.isEmpty? 0 : hndl.sdCardParamList) :
                                       componentsList.currentIndex === 3?
                                           (hndl.paramList.isEmpty? 0 : hndl.paramList) :
                                           componentsList.currentIndex === 4? (hndl.sadcoF1ParamList.isEmpty ? 0 : hndl.sadcoF1ParamList) :
                                                                              componentsList.currentIndex === 5? hndl.sadcoF4ParamList.isEmpty? 0 : hndl.sadcoF4ParamList: 0
                    delegate: Rectangle {
                        width: parametersList.width
                        height: 50

                        Text {
                            id: parameterName
                            anchors.left: parent.left
                            anchors.leftMargin: 20
                            anchors.verticalCenter: parent.verticalCenter
                            text: (index + 1) + " " + modelData.description
                            font.pixelSize: 12
                            font.bold: true
                            color: "#252733"
                            font.family: "Mulish"
                        }

                        Text {
                            id: valueName
                            anchors.left: parent.left
                            anchors.leftMargin: 380
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.value
                            font.pixelSize: 13
                            font.bold: true
                            color: "#252733"
                            font.family: "Mulish"
                        }

                        Rectangle {
                            id: descriprionName
                            height: 20
                            implicitWidth: 100
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            color:  modelData.flag
                            radius: 8

                            Text {
                                id: descriprionParameterText2
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.flag === "#F12B2C"? "неисправность": modelData.flag === "#FEC400"? "предупреждение" :
                                                                                                                   modelData.flag === "#3751FF"? "не проверяется" :
                                                                                                                                                 "в норме"
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.bold: false
                                color: /* modelData.flag == "#FEC400"?*/  "#252733" /*: "white"*/
                                font.family: "Mulish"
                            }
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    descriprionName.width = descriprionParameterText2.contentWidth + 5
                                }
                            }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            width: parent.width
                            height: 1
                            color: "#C5C7CD"
                        }
                    }
                }
            }

            ListView {
                id: componentsList // таблица компонентов оборудования
                x: 27
                y: 89
                width: 400
                height: 240
                visible: true
                property bool show: false

                model:hndl.boardsResult? hndl.boardsResult.isEmpty? 0 : hndl.boardsResult : 0

                delegate:  Rectangle {
                    id: componentsListDelegate
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
                            radius: height/2
                            border.color: componentsListDelegate.ListView.isCurrentItem? "#3751FF" : "#dfe0eb"
                            color: componentsListDelegate.ListView.isCurrentItem? "#3751FF" : "transparent"
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.left: parent.left
                            anchors.leftMargin: 10
                        }

                        Text {
                            id: parameterName2
                            anchors.left: rectCurrentElement.right
                            anchors.leftMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            font.pixelSize: 13
                            font.bold: true
                            font.family: "Mulish"
                        }

                        Rectangle {
                            id: descriprionParameter
                            height: 20
                            implicitWidth: 100
                            anchors.right: parent.right
                            anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            color: modelData.color
                            radius: 8

                            Text {
                                id: descriprionParameterText
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: modelData.description
                                font.pixelSize: 13
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                                font.bold: false
                                color: /* modelData.color === "#FEC400"? */ "#252733" /*: "white"*/
                                font.family: "Mulish"
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                componentsList.currentIndex = index
                                parametersList.visible = true
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
                x: 1002
                y: 69
                width: 18
                height: 2
                color: "#f12b2c"
                border.color: "#f12b2c"
            }

            Rectangle {
                x: 1139
                y: 69
                width: 16
                height: 2
                color: "#9fa2b4"
                border.color: "#9fa2b4"
            }

            Text {
                id: text12
                x: 1160
                y: 61
                color: "#9fa2b4"
                text: qsTr("не проверяется")
                font.pixelSize: 12
                font.family: "Mulish"
                font.bold: false
                verticalAlignment: Text.AlignVCenter
                font.weight: Font.Bold
            }

            Text {
                id: text13
                x: 1026
                y: 62
                color: "#9fa2b4"
                text: qsTr("неисправность")
                font.pixelSize: 12
                font.family: "Mulish"
                font.bold: false
                font.weight: Font.Bold
            }

            Text {
                id: text14
                x: 872
                y: 62
                color: "#9fa2b4"
                text: qsTr("предупржедение")
                font.pixelSize: 12
                font.family: "Mulish"
                font.bold: false
                font.weight: Font.Bold
            }

            Rectangle {
                x: 848
                y: 69
                width: 18
                height: 2
                color: "#3751ff"
                border.color: "#ffc500"
            }

            Rectangle {
                x: 744
                y: 69
                width: 18
                height: 2
                color: "#29cc97"
                border.color: "#29cc97"
            }

            Text {
                id: text15
                x: 768
                y: 62
                color: "#9fa2b4"
                text: qsTr("в норме")
                font.pixelSize: 12
                font.family: "Mulish"
                font.bold: false
                font.weight: Font.Bold
            }

            Rectangle {
                id: geo
                property bool hovered: false
                x: 433
                y: 141
                width: 5
                height: 17
                radius: height/2
                border.color: "transparent"
                enabled: hndl.boardsResult[1].description === "в норме"? true : false

                ToolTip.visible: geo.hovered
                ToolTip.text: qsTr("Посмотреть геопозицию")

                MouseArea {
                    anchors.fill: parent
                    anchors.rightMargin: 0
                    anchors.bottomMargin: 0
                    anchors.leftMargin: 0
                    anchors.topMargin: 0

                    hoverEnabled: true
                    onClicked: {
                        hndl.openMapToCoordinates(parseFloat(hndl.gpsParamList[1].value), parseFloat(hndl.gpsParamList[2].value))
                    }
                    onEntered: {
                        geo.hovered = true
                        cursorShape = Qt.PointingHandCursor

                    }
                    onExited: {
                        geo.hovered = false
                        cursorShape = Qt.ArrowCursor
                    }
                }

                Rectangle {
                    x: 1
                    y: 7
                    width: 3
                    height: 3
                    color: "#9fa2b4"
                    radius: height/2
                    border.color: "#9fa2b4"
                }

                Rectangle {
                    x: 1
                    y: 13
                    width: 3
                    height: 3
                    color: "#9fa2b4"
                    radius: height/2
                    border.color: "#9fa2b4"
                }

                Rectangle {
                    x: 1
                    y: 1
                    width: 3
                    height: 3
                    color: "#9fa2b4"
                    radius: height/2
                    border.color: "#9fa2b4"
                }

            }

        }

        Rectangle {
            id: errorCard
            visible: false
            x: 942
            y: 92
            width: 169
            height: 105
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"

            DropShadow {
                id: errorCardShadow
                color: "#dde2ff"
                anchors.fill: errorCard
                horizontalOffset: 1
                radius: 8.0
                spread: 0
                fast: true
                verticalOffset: 1
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                samples: 18
                source: errorCard
                z: -1
            }

            Text {
                id: text7
                x: 26
                y: 17
                color: "#9fa2b4"
                text: qsTr("неисправностей")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Mulish"
                font.bold: false
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                id: errorCountText
                x: 21
                y: 45
                width: 127
                height: 40
                visible: true
                color: "#252733"
                text: "-"
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 35
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                font.weight: Font.Bold
            }

        }

        Rectangle {
            id: okCard
            visible: false
            x: 1138
            y: 92
            width: 169
            height: 105
            color: "#ffffff"
            radius: 8
            border.color: "#3751ff"

            DropShadow {
                id: okCardShadow
                color: "#dde2ff"
                anchors.fill: okCard
                horizontalOffset: 2
                fast: true
                radius: 8.0
                spread: 0
                verticalOffset: 2
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                samples: 18
                source: okCard
                z: -1
            }

            Text {
                id: text9
                x: 55
                y: 16
                color: "#3751ff"
                text: qsTr("в норме")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Mulish"
                font.bold: false
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                id: okCountText
                x: 21
                y: 45
                width: 127
                height: 40
                color: "#3751ff"
                text: qsTr("-")
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 35
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                font.weight: Font.Bold
            }
        }

        Rectangle {
            id: warningCard
            visible: false
            x: 942
            y: 228
            width: 169
            height: 105
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"

            DropShadow {
                id: warningCardShadow
                color: "#dde2ff"
                anchors.fill: warningCard
                horizontalOffset: 2
                radius: 8.0
                fast: true
                spread: 0
                verticalOffset: 2
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                samples: 18
                source: warningCard
                z: -1
            }

            Text {
                id: text10
                x: 22
                y: 14
                color: "#9fa2b4"
                text: qsTr("предупреждений")
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                font.family: "Mulish"
                font.bold: false
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                id: warningCountText
                x: 21
                y: 45
                width: 127
                height: 40
                color: "#252733"
                text: qsTr("-")
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 35
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                font.weight: Font.Bold
            }
        }

        Rectangle {
            id: noCard
            visible: false
            x: 1138
            y: 228
            width: 169
            height: 105
            color: "#ffffff"
            radius: 8
            border.color: "#dfe0eb"

            DropShadow {
                id: noCardShadow
                color: "#dde2ff"
                anchors.fill: noCard
                horizontalOffset: 2
                radius: 8.0
                fast: true
                anchors.rightMargin: 0
                anchors.bottomMargin: 0
                anchors.leftMargin: 0
                anchors.topMargin: 0
                spread: 0
                verticalOffset: 2
                samples: 18
                source: noCard
                z: -1
            }

            Text {
                id: text11
                x: 28
                y: 16
                color: "#9fa2b4"
                text: qsTr("не проверяется")
                horizontalAlignment: Text.AlignHCenter
                font.family: "Mulish"
                verticalAlignment: Text.AlignVCenter
                font.bold: false
                font.pixelSize: 14
                font.weight: Font.Bold
            }

            Text {
                id: noCheckCountText
                x: 21
                y: 45
                width: 127
                height: 40
                color: "#252733"
                text: qsTr("-")
                verticalAlignment: Text.AlignVCenter
                font.bold: true
                font.pixelSize: 35
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WrapAnywhere
                font.weight: Font.Bold
            }
        }

        Text {
            id: currentPort
            anchors.right: parent.right
            anchors.rightMargin: 20
            y: 34
            width: 79
            height: 17
            color: "#3751ff"
            text: nameCurrentPort
            font.pixelSize: 14
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font.family: "Mulish"
            font.weight: Font.Bold
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:0.2;height:1000;width:1400}
}
##^##*/
