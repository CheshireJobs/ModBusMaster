import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.15
import DiscreteOutSequenceModel 0.1
import Qt.labs.qmlmodels 1.0

Rectangle {
    id: customTestPage
    property int countPages: 0
    property bool isTesting: false
    property var nameCurrentPort: hndl.getState()? settingsDialog.m_currentNamePort : "нет данных"

    color: "#F7F8FC"

    Component.onCompleted: {
        hndl.setDiscreteSettings()
        hndl.readDiscreteCount()
        hndl.setAnalogSettings()
        hndl.readAnalogCount()
    }

    Component.onDestruction: {
        if(isTesting){
            stopCommonTest()
            console.log("stop")
        }
    }

    function startCommonTest() {
        isTesting = true
         if( discreteCheck.isSelect)  {
             discretePage.startTest()
         }
         if(analogCheck.isSelect) {
             analogPage.startTest()
         }
         if(timerCheck.isSelect ) {
             timerPage.startTest()
         }
        hndl.commonTimerStart()
    }

    function stopCommonTest() {
        isTesting = false
        hndl.commonTimerStop()
        if(analogCheck.isSelect) {
            analogPage.stopTest()
        }
        if(discreteCheck.isSelect) {
            discretePage.stopTest()
        }
        if(timerCheck.isSelect ) {
            timerPage.stopTest()
        }
    }

    Text {
        id: text1
        x: 27
        y: 22
        color: "#252733"
        text: qsTr("Настраиваемое тестирование")
        font.pixelSize: 20
        font.weight: Font.Bold
        font.family: "Mulish"
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

    Rectangle {
        id: equipment
        x: 1045
        y: 93
        width: 347
        height: 271
        color: "#ffffff"
        radius: 8
        border.color: "#dfe0eb"

        DropShadow {
            id: equipmentShadow
            color: "#dde2ff"
            radius: 8
            anchors.fill: equipment
            source: equipment
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
            x: 22
            y: 23
            color: "#252733"
            text: qsTr("Состав оборудования")
            font.pixelSize: 14
            font.weight: Font.Bold
            font.bold: true
            font.family: "Mulish"
        }

        Text {
            id: text4
            x: 22
            y: 49
            width: 194
            height: 16
            color: "#9fa2b4"
            text: qsTr("состав тестирующего оборудования")
            font.pixelSize: 10
            verticalAlignment: Text.AlignVCenter
            font.bold: true
        }

        Rectangle {
            id: analogRow

            property bool isCurrentItem: true
            x: 2
            y: 119
            width: 343
            height: 50
            color: "#F7F8FC"

            Text {
                id: text5
                x: 49
                y: 19
                color: "#252733"
                text: qsTr("Аналоговые выходы")
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

            Text {
                id: analogCount
                x: 218
                y: 19
                color: "#252733"
                text: qsTr("12")
                font.pixelSize: 12
                font.family: "Mulish"
            }

            Rectangle {
                id: analogCheck
                property bool isSelect: false
                width: 15
                height: 15
                color: analogCheck.isSelect ? "#3751FF" : "transparent"
                radius: height / 2
                border.color: analogCheck.isSelect? "#3751FF" : "#dfe0eb"
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
                        analogCheck.isSelect = !analogCheck.isSelect
                        analogCheck.isSelect? countPages++ : countPages--
                    }
                }
            }

            MouseArea {
                anchors.left: analogCheck.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                onClicked: {
                    analogRow.isCurrentItem = true
                    analogRow.color = "#F7F8FC"

                    discreteRow.isCurrentItem = false
                    timerRow.isCurrentItem = false

                    discreteRow.color = "#ffffff"
                    timerRow.color = "#ffffff"
                    analogPage.visible = true
                    discretePage.visible = false
                    timerPage.visible = false
                }
            }
        }

        Rectangle {
            id: discreteRow

            property bool isCurrentItem: false
            x: 2
            y: 169
            width: 343
            height: 50
            color: "#ffffff"

            Text {
                id: text6
                x: 50
                y: 19
                color: "#252733"
                text: qsTr("Дискретные выходы")
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

            Text {
                id: discreteCount
                x: 218
                y: 19
                color: "#252733"
                text: qsTr("16")
                font.pixelSize: 12
                font.family: "Mulish"
            }

            Rectangle {
                id: discreteCheck
                property bool isSelect: false
                width: 15
                height: 15
                color: discreteCheck.isSelect ? "#3751FF" : "transparent"
                radius: height / 2
                border.color: discreteCheck.isSelect? "#3751FF" : "#dfe0eb"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenterOffset: 2
                Text {
                    anchors.fill: parent
                    text: qsTr("\u2713")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        discreteCheck.isSelect = !discreteCheck.isSelect
                        discreteCheck.isSelect? countPages++ : countPages--
                    }
                }
            }
            MouseArea {
                anchors.left: discreteCheck.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                onClicked: {
                    discreteRow.isCurrentItem = true
                    discreteRow.color = "#F7F8FC"

                    analogRow.isCurrentItem = false
                    timerRow.isCurrentItem = false

                    analogRow.color = "#ffffff"
                    timerRow.color = "#ffffff"
                    discretePage.visible = true
                    analogPage.visible = false
                    timerPage.visible = false
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
                anchors.leftMargin: 20
                font.family: "Mulish"
                font.pointSize: 8
            }

            Text {
                id: valueText
                color: "#9fa2b4"
                text: qsTr("Количество")
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 219
                font.family: "Mulish"
                anchors.verticalCenterOffset: -1
                font.pointSize: 8
            }
            anchors.leftMargin: 2
        }

        Rectangle {
            id: timerRow

            property bool isCurrentItem: false
            x: 2
            y: 218
            width: 343
            height: 50
            color: "#ffffff"

            Text {
                id: text8
                x: 51
                y: 19
                color: "#252733"
                text: qsTr("Таймеры")
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

            Text {
                id: timerCount
                x: 218
                y: 19
                color: "#252733"
                text: qsTr("4")
                font.pixelSize: 12
                font.family: "Mulish"
            }

            Rectangle {
                id: timerCheck
                property bool isSelect: false
                width: 15
                height: 15
                color: timerCheck.isSelect ? "#3751FF" : "transparent"
                radius: height / 2
                border.color: timerCheck.isSelect? "#3751FF" : "#dfe0eb"
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenterOffset: 2
                Text {
                    anchors.fill: parent
                    text: qsTr("\u2713")
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color: "white"
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        timerCheck.isSelect = !timerCheck.isSelect
                        countPages+= timerCheck.isSelect? 1 : -1
                    }
                }
            }
            MouseArea {
                anchors.left: timerCheck.right
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                onClicked: {
                    timerRow.isCurrentItem = true
                    timerRow.color = "#F7F8FC"

                    discreteRow.isCurrentItem = false
                    analogRow.isCurrentItem = false

                    discreteRow.color = "#ffffff"
                    analogRow.color = "#ffffff"
                    timerPage.visible = true
                    discretePage.visible = false
                    analogPage.visible = false
                }
            }

        }
    }

    Rectangle {
        id: workArea
        x: 31
        y: 93
        width: 994
        height: 819

        AnalogPage {
            id: analogPage
            visible: true
            anchors.fill: parent
            anchors.rightMargin: 0
        }
        DiscretePage {
            id: discretePage
            visible: false
            anchors.fill: parent
            anchors.rightMargin: 0
        }
        TimerPage {
            id: timerPage
            visible: false
            anchors.fill: parent
            anchors.rightMargin: 0
        }
    }

    Text {
        id: startTestButton
        property bool isStart: false
        x: 1274
        y: 391
        width: 107
        height: 48
        color: "#3751ff"
        text: isStart? "Завершить тестирование" : qsTr("Начать тестирование")
        font.pixelSize: 13
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
        font.bold: true
        font.family: "Mulish"
        font.weight: Font.Bold
        enabled: analogCheck.isSelect? analogPage.canTest() : true

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {
                startTestButton.isStart = !startTestButton.isStart
                startTestButton.isStart? startCommonTest() : stopCommonTest()
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

/*##^##
Designer {
    D{i:0;autoSize:true;formeditorZoom:0.9;height:1000;width:1400}
}
##^##*/
