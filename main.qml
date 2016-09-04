import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0
import QtCharts 2.1


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
    Component.onCompleted: {
        basicSqlQuery('CREATE TABLE IF NOT EXISTS Times'
                      + '(day TEXT, inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)');
        basicSqlQuery('CREATE VIEW IF NOT EXISTS TimesView'
                      + '(day, inBedDiff, toSleepDiff, awakeDiff, gotUpDiff)'
                      + 'AS SELECT strftime(\'%s\', day) * 1000,'  // msecs for QML use
                      + 'strftime(\'%s\', inBed) - strftime(\'%s\', day),'
                      + 'strftime(\'%s\', toSleep) - strftime(\'%s\', day),'
                      + 'strftime(\'%s\', awake) - strftime(\'%s\', day),'
                      + 'strftime(\'%s\', gotUp) - strftime(\'%s\', day) FROM Times');
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
                        root.basicSqlQuery(sqlConfirm);
                        enabled = false;
                    }
                    forgotFn: function() {
                        root.basicSqlQuery(sqlForgot);
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
                        root.basicSqlQuery(sqlConfirm);
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

                    function setDateAndReset() {
                        enabled = false;
                        awakeButton.enabled = false;
                        toSleepButton.enabled = true;
                        inBedButton.enabled = true;
                        initialPopup.sleepButton = null;

                        /*
                          Sets the "day" column for the entry. Takes the date() for graphing, since
                          it will provide a zero of sorts for comparisons and graphs across entries.
                          Will be converted into msec in the view per the Qt graphing rules.
                          Subtracts 12 hours based on the logic that one typically goes to sleep
                          after 12 PM on a given day and wakes up before 12 PM on the next day.
                          */
                        var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                        db.transaction(
                            function(tx) {
                                var rs = tx.executeSql('SELECT * FROM Times '
                                                       + 'WHERE ROWID = (SELECT max(ROWID) FROM Times)');
                                var row = rs.rows.item(0)
                                var dayEntry = row.inBed != null ?
                                               row.inBed : (row.toSleep != null ?
                                               row.toSleep : (row.awake != null ?
                                               row.awake : row.gotUp));
                                var dayUpdate = "UPDATE Times SET day = date('" + dayEntry
                                                + "', '-12 hours') WHERE ROWID = (SELECT max(ROWID) FROM Times)";
                                tx.executeSql(dayUpdate);
                            }
                        );
                    }

                    confirmedFn: function() {
                        if(!awakeButton.enabled) {
                            root.basicSqlQuery(sqlConfirm);
                            setDateAndReset();
                        } else {
                            sameTimePopup.sleepButton = gotUpButton
                            sameTimePopup.open();
                        }
                    }
                    forgotFn: function() {
                        setDateAndReset();
                    }
                    sameTimeFn: function() {
                        root.basicSqlQuery(sqlConfirmSameTime);
                        setDateAndReset();
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
            id: datePage

            ChartView {
                title: "Bedtime Data"
                anchors.fill: parent
                antialiasing: true
                theme: ChartView.ChartThemeDark

                DateTimeAxis {
                    id: xAxis
                    format: "M d"
                }
                DateTimeAxis {
                    id: yAxis
                    format: "h:mm a"
                }

                LineSeries {
                    id: inBedSeries
                    axisX: xAxis
                    axisY: yAxis
                }
                LineSeries {
                    id: toSleepSeries
                    axisX: xAxis
                    axisY: yAxis
                }
                LineSeries {
                    id: awakeSeries
                    axisX: xAxis
                    axisY: yAxis
                }
                LineSeries {
                    id: gotUpSeries
                    axisX: xAxis
                    axisY: yAxis
                }
            }

            // Add all the data to the basic output chart
            Component.onCompleted: {
                var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
                db.transaction(
                    function(tx) {
                        var data = tx.executeSql('SELECT * FROM TimesView');
                        var hourSecs = 3600
                        for(var i = 0; i < data.rows.length; i++) {
                            inBedSeries.append(data.rows.item(i).day, data.rows.item(i).inBedDiff / hourSecs);
                            toSleepSeries.append(data.rows.item(i).day, data.rows.item(i).toSleepDiff / hourSecs);
                            awakeSeries.append(data.rows.item(i).day, data.rows.item(i).awakeDiff / hourSecs);
                            gotUpSeries.append(data.rows.item(i).day, data.rows.item(i).gotUpDiff / hourSecs);

//                            var r = data.rows.item(i).inBedDiff + ", " + data.rows.item(i).toSleepDiff + ", "
//                                 + data.rows.item(i).awakeDiff + ", " + data.rows.item(i).gotUpDiff + "\n"
//                                 + data.rows.item(i).day
//                            console.log(r);
                        }
                    }
                );
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
