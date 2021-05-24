import QtQuick 2.0
import QtQuick.Controls 2.5

Rectangle {
    id: commonTestTab
    anchors.fill: parent
    property double timer: 0.0

    Timer {
        id: timerWait
        interval: 1000; running: false; repeat: true

        onTriggered: {
            if(timer < 90000) {
                timer += 900
                progressBar.value = timer

            } else {
                stop()
                busyIndicator.visible = false
                busyIndicator.running = false
                buttonGetResult.enabled = true
                timer = 0.0
            }
        }
    }

    Item {
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        z:+1

        Text {
            id: testText
            text: progressBar.value < 90000? "Пожалуйста, подождите. Идет тестирование" : "Тестирование окончено."
            font.pixelSize: 16
            color: "green"
            anchors.bottom: progressBar.top
            anchors.horizontalCenter: parent.horizontalCenter
            height: 20
            width: 200
            visible: false
        }
        ProgressBar {
            id: progressBar
            z:+1
            y: 129
            anchors.horizontalCenter: parent.horizontalCenter
            value: 0
            visible: false
            from: 0
            to: 90000
            height: 20
            width: 200
        }
    }
    Connections {
        target: hndl
        onStopTestByTypeCar: {
//            busyIndicator.visible = false
//            busyIndicator.running = false
            timerWait.start()
            testText.visible = true
            progressBar.visible = true

        }
        onOnParamListChanged: {
            busyIndicator.visible = false
            busyIndicator.running = false
        }
        onTestResultChanged: {
            testIndicator.color = hndl.testResult == 0 ? " green" : hndl.testResult == 1? "orange" : "red";
            testIndicator.text = hndl.resultTest
        }
    }

    Rectangle {
        id: step1
        width: parent.width
        height: parent.height
        border.color: "black"
        border.width: 0.5

        Rectangle {
            id: headStep1
            width: parent.width
            height: 30
            color: "dark gray"
            border.color: "black"
            border.width: 0.5

            Text {
                id: txtHead
                text: "Тестирование"
                color: "white"
                width: 50
                font.bold: true
                font.pixelSize: 16
            }
        }

        Rectangle {
            id: headKr
            anchors.left: parent.left
            anchors.leftMargin: 5
            anchors.top: headStep1.bottom
            border.color: "transparent"
            width: 120
            height: 30
            anchors.topMargin: 20
            Text {
                width: 120
                height: 30
                text: "Введите КР/IMEI"
                font.pixelSize: 14
                color: "#338cd4"
            }
        }

        ComboBox {
            id: kr
            anchors.left: headKr.right
            anchors.top: headStep1.bottom
            anchors.topMargin: 20

            width: 80
            height: 30
            model: ListModel {
                id: modelKr

                ListElement { text: "KP" }
                ListElement { text: "IMEI"}
            }
        }

        TextField {
            id: krTxt
            anchors.left: kr.right
            anchors.top: headStep1.bottom
            anchors.topMargin: 20
            width: 130
            height: 30
        }

        Rectangle {
            id: headTypeCar
            anchors.left: parent.left
            anchors.top: krTxt.bottom
            border.color: "transparent"
            anchors.leftMargin: 5
            anchors.topMargin: 5
            width: 120
            height: 30
            Text {
                width: 120
                height: 30
                text: "Тип машины"
                font.pixelSize: 14
                color: "#338cd4"
            }
        }

        ComboBox {
            id: typeCar
            anchors.top: krTxt.bottom
            anchors.left: headTypeCar.right
            anchors.topMargin: 5

            width: 130
            height: 25
            editable: false

            model: ListModel {
                id: modelBaudRate
                ListElement { text: "не выбран" }
                ListElement { text: "ДУОМАТИК" }
                ListElement { text: "ДИНАМИК" }
                ListElement { text: "ПУМА" }
                ListElement { text: "ПМА"}
                ListElement { text: "ПМА-С"}
                ListElement { text: "УНИМАТ КОМПАКТ" }
                ListElement { text: "УНИМАТ" }
                ListElement { text: "ВПР-02" }
                ListElement { text: "ВПР-02М" }
                ListElement { text: "ВПР-02К" }
                ListElement { text: "ВПРС-02" }
                ListElement { text: "ВПРС-03" }
                ListElement { text: "ВПРС-03К" }
                ListElement { text: "РБ" }
                ListElement { text: "РПБ"}
                ListElement { text: "ПБ" }
                ListElement { text: "ПМГ" }
                ListElement { text: "ТЭС" }

            }
            MouseArea {
                onEntered: {
                    cursorShape = Qt.PointingHandCursor
                }
                onExited: {
                    cursorShape = Qt.ArrowCursor
                }
            }
            onCurrentIndexChanged: {
                hndl.setTypeCar(modelBaudRate.get(currentIndex).text)
            }
        }

        Row {
            id: headerParamsRow
            width: 940
            height: 20
            z: +1
            anchors.top: boardList.top
            visible: (hndl.paramList.isEmpty || !boardList.show)? false : true

            Rectangle {
                id: name
                width: 370
                height: 20
                border.color: "black"
                Text {
                    width: 100
                    height: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Параметр"
                    font.pixelSize: 15
                    font.bold: true
                }
            }
            Rectangle {
                width: 280
                height: 20
                border.color: "black"
                Text {
                    width: 100
                    height: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Значение"
                    font.pixelSize: 15
                    font.bold: true
                }
            }
            Rectangle {
                width: 300
                height: 20
                border.color: "black"
                Text {
                    width: 200
                    height: 20
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: "Результат тестирования"
                    font.pixelSize: 15
                    font.bold: true
                }
            }
        }

        Rectangle {
            id: headerTableParam
            anchors.top: buttonGetResult.bottom
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 5

            height: 20
            width: 100

            border.color: "transparent"

            Text {
                x: 0
                y: 0
                height: 20
                width: 165
                text: "Состав оборудования:"
                font.pixelSize: 15
            }
        }

        ListView {
            id: boardList
            width: 400
            height: 60
            anchors.top: elementsResult.bottom
            anchors.left: parent.left
            anchors.leftMargin: 3
            property bool show: false

            model: hndl.boardsResult.isEmpty? 0 : hndl.boardsResult
            delegate:  Row {
                id: boardListDelegaate
                width: 400
                height: 20

                Rectangle {
                    width: 200
                    height: 20
                    color:  /*(boardListDelegaate.ListView.isCurrentItem && boardList.show)? "#338cd4":*/ "white" //"#338cd4"
                    border.color: "light gray"
                    opacity: (boardListDelegaate.ListView.isCurrentItem && boardList.show)? 0.7 : 1
                    Text {
                        width: 200
                        height: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.name
                        font.pixelSize: 15
                        font.bold: true
                        color: /*(boardListDelegaate.ListView.isCurrentItem && boardList.show)? "white" :*/ "black"
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            if(modelData.color !== "gray") {
                                boardList.currentIndex = index
                                boardList.show = !boardList.show
                                parametersList.visible = boardList.show? true : false
                                headerParamsRow.anchors.topMargin =  boardListDelegaate.height * (boardList.currentIndex + 1)
                                boardListDelegaate.anchors.topMargin = boardList.currentIndex !== 2?
                                            parametersList.height * (boardList.show? -1 : 1) : 0
                            }

                        }
                    }
                }
                Rectangle {
                    width: 200
                    height: 20
                    border.color: "light gray"
                    color:  /*(boardListDelegaate.ListView.isCurrentItem && boardList.show)? "#338cd4":*/ "white"
//                    opacity: (boardListDelegaate.ListView.isCurrentItem && boardList.show)? 0.7 : 1

                    Text {
                        width: 200
                        height: 20
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: modelData.description
                        font.pixelSize: 15
                        font.bold: true
                        color: modelData.color
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                                if(modelData.color !== "gray"){
                                boardList.currentIndex = index
                                boardList.show = !boardList.show
                                parametersList.visible = boardList.show? true : false
                                headerParamsRow.anchors.topMargin =  boardListDelegaate.height * (boardList.currentIndex + 1)
                                boardListDelegaate.anchors.topMargin = boardList.currentIndex !== 2?
                                            parametersList.height * (boardList.show? -1 : 1) : 0
                            }
                        }
                    }
                }
            }
        }

        ListView {
            id: parametersList
            anchors.top: headerParamsRow.bottom
            visible: false
            z: +1

            width: commonTestTab.width
            height: 400
            boundsBehavior: Flickable.StopAtBounds
            flickableDirection: Flickable.VerticalFlick
            clip: true

            model: boardList.currentIndex === 0?
                       (hndl.paramList.isEmpty? 0 : hndl.paramList ) :
                       boardList.currentIndex === 1? (hndl.sadcoF1ParamList.isEmpty ? 0 : hndl.sadcoF1ParamList) :
                                                     hndl.sadcoF4ParamList.isEmpty? 0 : hndl.sadcoF4ParamList

            ScrollBar.vertical: ScrollBar { }

            delegate: Row {
                    id: headerRow
                    width: 940
                    height: 20

                    Rectangle{
                        width: 370
                        height: 20
                        border.color: "light gray"
                        Text {
                            width: 200
                            height: 20
                            anchors.leftMargin: 10
                            text: (index + 1) + " " + modelData.description
                            font.bold: true
                        }
                    }
                    Rectangle {
                        width: 280
                        height: 20
                        border.color: "light gray"
                        Text {
                            width: 200
                            height: 20
                            anchors.leftMargin: 10
                            text: modelData.value

                        }
                    }
                    Rectangle {
                        width: 300
                        height: 20
                        border.color: "light gray"
                        Text {
                            width: 200
                            height: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.flag === "red"? "Неисправность": modelData.flag === "orange"? "Предупреждение" :
                                                                                    modelData.flag === "blue"? "не проверяется" :
                                                                                                               "В норме"
                            color: modelData.flag
                            font.bold: true
                        }
                    }

                }
        }

        Button {
            id: buttonGetType
            anchors.top: typeCar.bottom
            text: "Начать тестирование"
            anchors.topMargin: 10
            anchors.left: parent.left
            anchors.leftMargin: 10

            onClicked: {
                hndl.getType(kr.currentIndex, "868136035383846", typeCar.currentText)
                busyIndicator.visible = true
                busyIndicator.running = true
                console.log(krTxt.text)
                console.log(typeCar.modelBaudRate.get(typeCar.currentIndex).text)
            }
        }

        Button {
            id: buttonGetResult
            anchors.top: typeCar.bottom
            anchors.left: buttonGetType.right
            anchors.leftMargin: 10
            anchors.topMargin: 10
            enabled: true

            text: "Результат тестирования"
            onClicked: {
                hndl.getLocsRequest(kr.currentIndex, "868136035383846", typeCar.currentText) //krTxt.text
                busyIndicator.visible = true
                busyIndicator.running = true
                console.log(krTxt.text)
                console.log(typeCar.modelBaudRate.get(typeCar.currentIndex).text)
            }

        }

        Row {
            anchors.top: headStep1.bottom
            anchors.right: parent.right
            anchors.rightMargin: 3
            height: 50
            width: 340
            Rectangle {
                width: 200
                height: 50
                border.color: "transparent"
                Text {
                    width: 200
                    height: 50
                    text: "Результат тестирования:"
                    font.bold: true
                    font.pixelSize: 15
                }
            }
            Rectangle {
                width: 140
                height: 50

                Text {
                    id: testIndicator
                    width: 140
                    height: 50

                    text: hndl.testResult == -1? "нет данных" : hndl.resultTest;

                    font.bold: true
                    color: "gray"
                    font.pixelSize: 15
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

                }
            }
        }

        Rectangle {
            height: 20
            width: 100
            anchors.left: elementsResult.right
            anchors.top: elementsResult.verticalCenter
            anchors.topMargin: -28

            Text {
                x: 0
                y: 19
                height: 20
                width:200
                text: "посмотреть геопозицию"
                color: "blue"
//                wrapMode: Text.WrapAtWordBoundaryOrAnywhere
            }
            MouseArea {
                anchors.fill: parent
                anchors.rightMargin: 8
                onClicked: {
                    hndl.openMapToCoordinates(59.876328, 30.307585)
                }
            }
        }

        ListView {
            id: elementsResult
            anchors.top: headerTableParam.bottom
            anchors.left: parent.left
            anchors.leftMargin: 3
            orientation: ListView.Vertical

            width: 400
            height: 60

            model: hndl.elementsResult.isEmpty? 0 : hndl.elementsResult

            delegate: Row {
                width: parent.width
                height: 20

                Rectangle {
                    width: 200
                    height: 20
                    border.color: "light gray"
                    Text {
                        width: 200
                        height: 20
                        anchors.leftMargin: 10
                        text: modelData.name
                        font.bold: true
                    }
                }
                Rectangle {
                    width: 200
                    height: 20
                    border.color: "light gray"
                    Text {
                        width: 100
                        height: 20
                        anchors.leftMargin: 10
                        text: modelData.color === "red"? "неисправность":
                                        modelData.color === "green"? "в норме" :
                                            modelData.color === "orange"? "предупреждение" : "нет данных"
                        font.bold: true
                        color: modelData.color
                   }
                }
            }
        }

        BusyIndicator {
            id: busyIndicator
            height: 45
            width: 45
            running: false
            visible: false
            anchors.right: headerParamsRow.right
            anchors.bottom: headerParamsRow.top
            anchors.topMargin: 20
        }
    }
}

/*##^##
Designer {
    D{i:0;autoSize:true;height:480;width:640}
}
##^##*/
