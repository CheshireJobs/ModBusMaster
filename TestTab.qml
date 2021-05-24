import QtQuick 2.0
import QtQuick.Controls 2.12

Item {
    id: testTab

    height: parent.height
    width: parent.width

    Component.onCompleted: {
        hndl.setDiscreteSettings()
        hndl.readDiscreteCount()
        hndl.setAnalogSettings()
        hndl.readAnalogCount()
    }

    function startCommonTest() {
        discreteTab.startTesting()
        analogTab.startTesting()
        timerTab.startTest()
        hndl.commonTimerStart()
    }

    function stopCommonTest() {
        hndl.commonTimerStop()
        analogTab.stopTesting()
        discreteTab.stopTest()
        timerTab.stopTest()
    }

    ScrollView {
        width: parent.width
        height: parent.height
        contentWidth: testingTabsColumn.width
        contentHeight: testingTabsColumn.height + 500 + 500
        clip: true

        Column {

            id: testingTabsColumn

            width: parent.width
            height: parent.height

            AnalogOutputsTab {
                id: analogTab
                anchors.top: parent.top
                height: 430 // parent.height* 3/6
            }

            DiscreteOutputsTab {
                id: discreteTab
                anchors.top: analogTab.bottom
                height: 500 // parent.height* 4/6
            }

            TimerOutputsTab {
                id: timerTab
                anchors.top: discreteTab.bottom
                height: 500 // parent.height* 4/6
                width: parent.width
            }
        }
    }

    Button {
        id: startTest

        property bool start: false

        anchors.bottom: parent.bottom
        anchors.right: parent.right
        width: 150
        height: 50

        text: start? "Завершить тестирование" : "Начать тестирование"

        onClicked: {
            start = !start
            if (start)  {
                startCommonTest()
            } else {
                stopCommonTest()
//                hndl.readDiscreteCount()
//                hndl.readAnalogCount()
            }
        }
    }

}
