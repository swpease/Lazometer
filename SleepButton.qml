import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0

Button {

    // Note: single quotes for direct SQLite inputs, either (I think) for variables as inputs.
    property string sqlNewTable: 'CREATE TABLE IF NOT EXISTS Times'
                                 + '(inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)'
    property string sqlForgot: "Forgot called"
    property string sqlConfirm: "Confirm called"
    property string sqlConfirmSameTime: "Confirm Same Time called"

//    property var resetFn: function() { return; }
    property var sameTimeFn: function() { return; }
    property var priorSleepButton  // to hold a SleepButton
//    property bool verified: false
    // make a property to house the JS fn for the sql.

    Layout.minimumWidth: root.minimumWidth  // might want to remove the 'root' dependencies...
    Layout.maximumWidth: 450
    Layout.preferredWidth: root.width / 2
}
