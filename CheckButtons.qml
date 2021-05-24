import QtQuick 2.0
import QtQuick.Controls 2.3

Item {
    property var count

    height: 600//parent.height
    width: 1000



    CheckDelegate {
        id: checkDelegate
        x: 76
        y: 56
        text: qsTr("Check Delegate")
    }

    CheckDelegate {
        id: checkDelegate1
        x: 76
        y: 140
        text: qsTr("Check Delegate")
    }

    CheckDelegate {
        id: checkDelegate2
        x: 240
        y: 56
        text: qsTr("Check Delegate")
    }

    CheckDelegate {
        id: checkDelegate3
        x: 240
        y: 140
        text: qsTr("Check Delegate")
    }//parent.width

}
