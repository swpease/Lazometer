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

    Component.onCompleted: {
        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);

        db.transaction(
            function(tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS Times'
                              + '(inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)');
            }
        );
    }

    SwipeView {
        id: swipeView
        anchors.fill: parent
        currentIndex: tabBar.currentIndex

        Page {
            ColumnLayout {
                id: sleepButtonsCol

                anchors.centerIn: parent

                SleepButton {
                    id: inBedButton

                    confirmedFn: function() {
                        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                        db.transaction(
                            function(tx) {
                                tx.executeSql(sqlConfirm);
                            }
                        );
                        enabled = false;
                    }
                    forgotFn: function() {
                        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                        db.transaction(
                            function(tx) {
                                tx.executeSql(sqlForgot);
                            }
                        );
                        enabled = false;
                    }
                    sqlConfirm: "INSERT INTO Times(inBed) VALUES (datetime('now'))"
                    sqlForgot: "INSERT INTO Times(inBed) VALUES (null)"
                    text: qsTr("In Bed")
                    enabled: true
                    onClicked: {
                        initialPopup.open();
                        initialPopup.sleepButton = inBedButton;
                    }
                }
                SleepButton {
                    id: toSleepButton

                    function changeEnabled() {
                        enabled = false;
                        inBedButton.enabled = false;
                        awakeButton.enabled = true;
                        gotUpButton.enabled = true;
                    }

                    confirmedFn: function() {
                        if(!inBedButton.enabled) {
                            var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                            db.transaction(
                                function(tx) {
                                    tx.executeSql(sqlConfirm);
                                }
                            );
                            changeEnabled();
                        } else {
                            sameTimePopup.sleepButton = toSleepButton;
                            sameTimePopup.open();
                        }
                    }
                    forgotFn: function() {
                        changeEnabled();
                    }
                    sameTimeFn: function() {
                        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                        db.transaction(
                            function(tx) {
                                tx.executeSql(sqlConfirmSameTime);
                            }
                        );
                        changeEnabled();
                    }
                    sqlConfirm: "UPDATE Times SET toSleep = datetime('now') "
                                + "WHERE ROWID = (SELECT max(ROWID) FROM Times)"
                    sqlConfirmSameTime: "INSERT INTO Times(inBed, toSleep) "
                                        + "VALUES (datetime('now'), datetime('now'))"
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

                    confirmedFn: function() {
//                        console.log(sqlConfirm);
                        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                        db.transaction(
                            function(tx) {
                                tx.executeSql(sqlConfirm);
                            }
                        );
                        enabled = false;
                    }
                    forgotFn: function() {
                        enabled = false;
                    }
                    sqlConfirm: "UPDATE Times SET awake = datetime('now') "
                                + "WHERE ROWID = (SELECT max(ROWID) FROM Times)"
                    text: qsTr("Awake")
                    enabled: false
                    onClicked: {
                        initialPopup.open();
                        initialPopup.sleepButton = awakeButton;
                    }
                }
                SleepButton {
                    id: gotUpButton

                    function reset() {
                        enabled = false;
                        awakeButton.enabled = false;
                        toSleepButton.enabled = true;
                        inBedButton.enabled = true;
                        initialPopup.sleepButton = null;
                    }

                    confirmedFn: function() {
                        if(!awakeButton.enabled) {
//                            console.log(sqlConfirm);
                            var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                            db.transaction(
                                function(tx) {
                                    tx.executeSql(sqlConfirm);
                                }
                            );
                            reset();
                        } else {
                            sameTimePopup.sleepButton = gotUpButton
                            sameTimePopup.open();
                        }
                    }
                    forgotFn: function() {
                        reset();
                    }
                    sameTimeFn: function() {
//                        console.log(sqlConfirmSameTime);
                        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                        db.transaction(
                            function(tx) {
                                tx.executeSql(sqlConfirmSameTime);
                            }
                        );
                        reset();
                    }
                    sqlConfirm: "UPDATE Times SET gotUp = datetime('now') "
                                + "WHERE ROWID = (SELECT max(ROWID) FROM Times)"
                    sqlConfirmSameTime: "UPDATE Times SET awake = datetime('now'), gotUp = datetime('now') "
                                        + "WHERE ROWID = (SELECT max(ROWID) FROM Times)"
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
                buttonWidth: sleepButtonsCol.width / 2
                forgotToolTipText: qsTr("Tap here if you forgot to\nconfirm your start time.")
                onConfirmClicked: {
                    sleepButton.confirmedFn();
                    close();
                }
                onForgotClicked: {
                    sleepButton.forgotFn();
                    close();
                }
                onClosed: forgotEnabled = true
            }

            SleepPopup {
                id: sameTimePopup

                x: (root.width - width) / 2
                y: (root.height - height) / 2
                buttonWidth: sleepButtonsCol.width / 2
                confirmText: "Same Time"
                forgotText: "Forgot Last Step"
                forgotToolTipText: qsTr("Tap here if you forgot to\nconfirm your start time\nfor last step")
                onConfirmClicked: {
                    sleepButton.sameTimeFn();
                    close();
                }
                onForgotClicked: {
                    sleepButton.priorSleepButton.enabled = false;
                    if(sleepButton.text == "Going to Sleep") {
                        sleepButton.priorSleepButton.forgotFn();  // Does what I want it to.
                    }
                    sleepButton.confirmedFn();
                    close();
                }
            }
        }

        Page {
            Label {
                text: qsTr("Second page")
                anchors.centerIn: parent
            }
            // Buttons for checking table accuracy.
            Button {
                text: "Reset Table"
                onClicked: {
                    var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                    db.transaction(
                        function(tx) {
                            tx.executeSql('DROP TABLE IF EXISTS Times');
                            tx.executeSql('CREATE TABLE IF NOT EXISTS Times'
                                          + '(inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)');
                        }
                    );
                }
            }

            Button {
                text: "Show Table"
                anchors.right: parent.right
                onClicked: {
                    var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                    db.transaction(
                        function(tx) {
                            var rs = tx.executeSql('SELECT * FROM Times');
                            var r = "";
                            for(var i = 0; i < rs.rows.length; i++) {
                                r = rs.rows.item(i).inBed + ", " + rs.rows.item(i).toSleep + ", "
                                     + rs.rows.item(i).awake + ", " + rs.rows.item(i).gotUp
                                console.log(r);
                            }
                        }
                    );
                }
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
