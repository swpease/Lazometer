import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0
//import QtQuick.Controls.Universal 2.0

ApplicationWindow {
    id: root

    visible: true
    width: Math.min(640, Screen.width)
    height: Math.min(480, Screen.height)
    title: qsTr("Lazometer")
    minimumWidth: 200

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            ColumnLayout {

                anchors.centerIn: parent

                Button {
                    id: inBedButton

                    text: qsTr("In Bed")
                    enabled: true
                    // the other Buttons follow suit b/c of Layout.fillWidth in them
                    Layout.minimumWidth: root.minimumWidth
                    Layout.maximumWidth: 450
                    Layout.preferredWidth: root.width / 2
                    onClicked: thePopup.open()
                }
                Button {
                    id: toSleepButton

                    text: qsTr("Going to Sleep")
                    enabled: true
                    Layout.fillWidth: true
                    onClicked: thePopup.open()
                }
                Button {
                    id: awakeButton

                    text: qsTr("Awake")
                    enabled: false
                    Layout.fillWidth: true
                    onClicked: thePopup.open()
                }
                Button {
                    id: gotUpButton

                    text: qsTr("Out of Bed")
                    enabled: false
                    Layout.fillWidth: true
                    onClicked: thePopup.open()
                }
            }

            SleepPopup {
                id: thePopup

                x: (root.width - width) / 2
                y: (root.height - height) / 2
            }
        }

        Page {
            Label {
                text: qsTr("Second page")
                anchors.centerIn: parent
            }
        }
    }

    footer: TabBar {
        id: tabBar
        currentIndex: swipeView.currentIndex
        TabButton {
            text: qsTr("Collect Data")
        }
        TabButton {
            text: qsTr("View Data")
        }
    }
}
