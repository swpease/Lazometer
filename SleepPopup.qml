import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0

Popup {
    // Popups (0, 0) to the (0, 0) of their parent.
    id: sleepPopupRoot

    modal: true
    Material.foreground: Material.Indigo
    Material.background: "transparent"

    contentItem: ColumnLayout {
        id: popupContent

        Button {
            text: qsTr("Confirm")
            Layout.preferredWidth: inBedButton.width / 2
        }

        Button {
            text: qsTr("Forgot")
            Layout.fillWidth: true
            ToolTip.visible: pressed
            ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
            ToolTip.text: qsTr("Tap here if you forgot to\nconfirm your start time.")
        }
    }
}
