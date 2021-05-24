import QtQuick 2.0
import QtCharts 2.3

 Rectangle {
    id: diagnostics

    width: parent.width
    height: parent.height

    Component.onCompleted: {

    }

    ChartView {
        id: accelerometer

        width: parent.width
        height: parent.height / 2

        theme: ChartView.ChartThemeBlueNcs
        antialiasing: true


        ValueAxis {
            id: yAxis
            min: -1000
            max: 1000

        }
        ValueAxis {
            id: timeAxis
            min: -300
            max: 0
        }

        LineSeries {
            id: lineSeriesX
            name: "X"
            axisX: timeAxis
            axisY: yAxis
            useOpenGL: true

        }
        LineSeries {
            id: lineSeriesY
            name: "Y"
            axisX: timeAxis
            axisYRight: yAxis
            useOpenGL: true
        }
        LineSeries {
            id: lineSeriesZ
            name: "Z"
            axisX: timeAxis
            axisYRight: yAxis
            useOpenGL: true
        }

        Timer {
            property int  amountOfData: 0
            id: refreshTimer
            interval: 100
            running: true
            repeat: true
            onTriggered: {
                hndl.update(accelerometer.series(0),
                                  accelerometer.series(1),
                                  accelerometer.series(2));
//                accelerometer.scrollRight(1);
                if(amountOfData > timeAxis.max){
                           timeAxis.min++;
                           timeAxis.max++;
                       } else {
                           amountOfData++; //This else is just to stop incrementing the variable unnecessarily
                       }
            }
        }
    }
}
