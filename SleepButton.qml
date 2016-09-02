import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0

Button {

    // Note: single quotes for direct SQLite inputs, either (I think) for variables as inputs.
//    property string sqlNewTable: 'CREATE TABLE IF NOT EXISTS Times'
//                                 + '(inBed TEXT, toSleep TEXT, awake TEXT, gotUp TEXT)'
    property string sqlForgot: "Forgot called"
    property string sqlConfirm: "Confirm called"
    property string sqlConfirmSameTime: "Confirm Same Time called"

    property var confirmedFn: function() { console.log("confirmedFn not implemented"); }
    property var forgotFn: function() { console.log("forgotFn not implemented"); }
    property var sameTimeFn: function() { console.log("sameTimeFn not implemented"); }
    property var priorSleepButton  // For holding a SleepButton

    Layout.minimumWidth: root.minimumWidth  // might want to remove the 'root' dependencies...
    Layout.maximumWidth: 450
    Layout.preferredWidth: root.width / 2
}
