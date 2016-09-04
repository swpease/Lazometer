import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0
import QtCharts 2.1

// A page that contains buttons for displaying and resetting the current database.

Page {
    Label {
        text: qsTr("Third page")
        anchors.centerIn: parent
    }
    // Buttons for checking table accuracy.
    Button {
        text: "setDateAndReset Table"
        onClicked: {
            var db = LocalStorage.openDatabaseSync("LazometerDB", "1.0", "The Sleep Database", 1000000);
            db.transaction(
                function(tx) {
                    tx.executeSql('DROP TABLE IF EXISTS Times');
                    tx.executeSql('CREATE TABLE IF NOT EXISTS Times'
                                  + '(day TEXT, inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)');
                    tx.executeSql('DROP VIEW IF EXISTS TimesView');
                    // WILL NEED TO RESTART THE PROGRAM FOR NOW. SOMETHING GOES AWRY
//                            tx.executeSql('CREATE VIEW IF NOT EXISTS TimesView'
//                                          + '(day, inBedDiff, toSleepDiff, awakeDiff, gotUpDiff)'
//                                          + 'AS SELECT strftime(\'%s\', day) * 1000,'  // msecs for QML use
//                                          + 'strftime(\'%s\', inBed) - strftime(\'%s\', day),'
//                                          + 'strftime(\'%s\', toSleep) - strftime(\'%s\', day),'
//                                          + 'strftime(\'%s\', awake) - strftime(\'%s\', day),'
//                                          + 'strftime(\'%s\', gotUp) - strftime(\'%s\', day) FROM Times');
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
                             + rs.rows.item(i).awake + ", " + rs.rows.item(i).gotUp + "\n"
                             + rs.rows.item(i).day
                        console.log(r);
                    }
                    var rs2 = tx.executeSql('SELECT * FROM TimesView');
                    var r2 = "";
                    for(var i2 = 0; i2 < rs.rows.length; i2++) {
                        r2 = rs2.rows.item(i2).inBedDiff + ", " + rs2.rows.item(i2).toSleepDiff + ", "
                             + rs2.rows.item(i2).awakeDiff + ", " + rs2.rows.item(i2).gotUpDiff + "\n"
                             + rs2.rows.item(i2).day
                        console.log(r2);
                    }
                }
            );
        }
    }
}
