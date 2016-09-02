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

                SleepButton {
                    id: inBedButton

                    function confirmed() {
                        console.log(sqlNewTable);
                        console.log(sqlConfirm);
                        enabled = false;
                    }

                    function forgot() {
                        console.log(sqlNewTable);
                        console.log(sqlForgot);
                        enabled = false;
                    }

                    text: qsTr("In Bed")
                    enabled: true
                    onClicked: {
                        initialPopup.open();
                        initialPopup.sleepButton = inBedButton;
                    }
                }
                SleepButton {
                    id: toSleepButton

                    function confirmed() {
                        if(!inBedButton.enabled) {
                            console.log(sqlConfirm);
                            changeEnabled();
                        } else {
                            sameTimePopup.sleepButton = toSleepButton;
                            sameTimePopup.open();
                        }
                    }

                    function forgot() {
                        console.log(sqlNewTable); // may get rid of this later...
                        console.log(sqlForgot);
                        changeEnabled();
                    }

                    function changeEnabled() {
                        enabled = false;
                        inBedButton.enabled = false;  // necessary?
                        awakeButton.enabled = true;
                        gotUpButton.enabled = true;
                    }

                    sameTimeFn: function() {
                        console.log(sqlNewTable);
                        console.log(sqlConfirmSameTime);
                        changeEnabled();
                    }

                    text: qsTr("Going to Sleep")
                    enabled: true
                    priorSleepButton: inBedButton
                    onClicked: {
                        initialPopup.open();
                        initialPopup.sleepButton = toSleepButton;
                        initialPopup.forgotEnabled = !inBedButton.enabled;
                    }
                }
                SleepButton {
                    id: awakeButton

                    function confirmed() {
                        console.log(sqlConfirm);
                        enabled = false;
                    }

                    function forgot() {
                        enabled = false;
                    }

                    text: qsTr("Awake")
                    enabled: false
                    onClicked: {
                        initialPopup.open();
                        initialPopup.sleepButton = awakeButton;
                    }
                }
                SleepButton {
                    id: gotUpButton

                    function confirmed() {
                        if(!awakeButton.enabled) {
                            console.log(sqlConfirm);
                            reset();
                        } else {
                            sameTimePopup.sleepButton = gotUpButton
                            sameTimePopup.open();
                        }
                    }

                    function forgot() {
                        reset();
                    }

                    function reset() {
                        enabled = false;
                        awakeButton.enabled = false;
                        toSleepButton.enabled = true;
                        inBedButton.enabled = true;
                        initialPopup.sleepButton = null;
                    }

                    sameTimeFn: function() {
                        console.log(sqlConfirmSameTime);
                        reset();
                    }
                    text: qsTr("Out of Bed")
                    enabled: false
                    priorSleepButton: awakeButton
                    onClicked: {
                        initialPopup.open();
                        initialPopup.sleepButton = gotUpButton;
                    }
                }
            }

            SleepPopup {
                id: initialPopup

                x: (root.width - width) / 2
                y: (root.height - height) / 2
                onConfirmClicked: {
                    sleepButton.confirmed();
                    close();
                }
                onForgotClicked: {
                    sleepButton.forgot();
                    close();
                }
                onClosed: forgotEnabled = true
            }

            SleepPopup {
                id: sameTimePopup

                x: (root.width - width) / 2
                y: (root.height - height) / 2
                forgotText: "Same Time"
                onConfirmClicked: {
                    console.log(sleepButton.sqlNewTable);  // maybe put this in the root C.onC
                    sleepButton.sameTimeFn();
                    close();
                }
                onForgotClicked: {
                    console.log(sleepButton.sqlNewTable);
                    sleepButton.priorSleepButton.enabled = false;
                    sleepButton.confirmed();
                    close();
                    // need to close initialPopup?
                }
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
