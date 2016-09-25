import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0
import QtCharts 2.1

// A page that contains buttons for displaying and resetting the current database.

//Converting a time() type to a time since epoch type assumes that it's in GMT at Jan 1, 2000 for some reason.

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
//                    tx.executeSql('DROP TABLE IF EXISTS Times');
//                    tx.executeSql('CREATE TABLE IF NOT EXISTS Times'
//                                  + '(day TEXT, inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)');
                    tx.executeSql('DROP VIEW IF EXISTS TimesView');
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
                             + rs.rows.item(i).day + "\n\n"
                        console.log(r);
                    }
                    var rs2 = tx.executeSql('SELECT * FROM TimesView');
                    var r2 = "";
//                    for(var i2 = 0; i2 < rs.rows.length; i2++) {
//                        r2 = new Date(rs2.rows.item(i2).inBedDiff) + ", " + rs2.rows.item(i2).toSleepDiff + ", "
//                             + rs2.rows.item(i2).awakeDiff + ", " + rs2.rows.item(i2).gotUpDiff + "\n"
//                             + rs2.rows.item(i2).day
//                        console.log(r2);
//                    }
                    for(var i2 = 0; i2 < rs.rows.length; i2++) {
                        r2 = new Date(rs2.rows.item(i2).dayview) + ", IBT: " + rs2.rows.item(i2).inBedTime + ", TD: "
                             + rs2.rows.item(i2).timediff + ", IBTS: " + rs2.rows.item(i2).inBedTimeSecs + "\n"
                             + rs2.rows.item(i2).dayview
                        console.log(r2);
                    }
                }
            );
        }
    }
}

/*
                    var rs3 = tx.executeSql('SELECT * FROM TestGMT');
                    var r3 = "";
                    for(var i3 = 0; i3 < rs.rows.length; i3++) {
                        r3 = new Date(rs3.rows.item(i2).inBedDiff) + ", " + rs3.rows.item(i3).toSleepDiff + ", "
                             + rs3.rows.item(i3).awakeDiff + ", " + rs3.rows.item(i3).gotUpDiff + "\n"
                             + new Date(rs3.rows.item(i3).day)
                        console.log(r3);
                    }

        basicSqlQuery('CREATE VIEW IF NOT EXISTS TestGMT'
                      + '(dayb TEXT, inBedb TEXT, toSleepb TEXT, awakeb TEXT, gotUpb TEXT)'
                      + 'AS SELECT datetime(day, \'localtime\'),'
                      + 'datetime(inBed, \'localtime\'), datetime(toSleep, \'localtime\')'
                      + 'datetime(awake, \'localtime\'), datetime(gotUp, \'localtime\')'
                      + 'FROM Times')
  */
