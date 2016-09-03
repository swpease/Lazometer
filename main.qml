import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0

ApplicationWindow {
    id: root

    function basicSqlQuery(query) {
        // For all of the single-query moments below.
        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
        db.transaction(
            function(tx) {
                tx.executeSql(query);
            }
        );
    }

    visible: true
    width: Math.min(640, Screen.width)
    height: Math.min(480, Screen.height)
    title: qsTr("Lazometer")
    minimumWidth: 200
    Component.onCompleted: basicSqlQuery('CREATE TABLE IF NOT EXISTS Times'
                                        + '(inBed INTEGER, toSleep INTEGER, awake INTEGER, gotUp INTEGER)')
    // Store as Unix time (need to *1000 for msecs) for use in DateTimeAxis (see qml axes example)

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
                        root.basicSqlQuery(sqlConfirm);
                        enabled = false;
                    }
                    forgotFn: function() {
                        root.basicSqlQuery(sqlForgot);
                        enabled = false;
                    }
                    sqlConfirm: "INSERT INTO Times(inBed) VALUES (strftime('%s','now') * 1000)"
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
                            root.basicSqlQuery(sqlConfirm);
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
                        root.basicSqlQuery(sqlConfirmSameTime);
                        changeEnabled();
                    }
                    sqlConfirm: "UPDATE Times SET toSleep = strftime('%s','now') * 1000 "
                                + "WHERE ROWID = (SELECT max(ROWID) FROM Times)"
                    sqlConfirmSameTime: "INSERT INTO Times(inBed, toSleep) "
                                        + "VALUES (strftime('%s','now') * 1000, strftime('%s','now') * 1000)"
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
                        root.basicSqlQuery(sqlConfirm);
                        enabled = false;
                    }
                    forgotFn: function() {
                        enabled = false;
                    }
                    sqlConfirm: "UPDATE Times SET awake = strftime('%s','now') * 1000 "
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
                            root.basicSqlQuery(sqlConfirm);
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
                        root.basicSqlQuery(sqlConfirmSameTime);
                        reset();
                    }
                    sqlConfirm: "UPDATE Times SET gotUp = strftime('%s','now') * 1000 "
                                + "WHERE ROWID = (SELECT max(ROWID) FROM Times)"
                    sqlConfirmSameTime: "UPDATE Times SET awake = strftime('%s','now') * 1000, gotUp = strftime('%s','now') * 1000 "
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
        }

        Page {
            Label {
                text: qsTr("Third page")
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
