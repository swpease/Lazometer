import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.0
import QtQuick.Window 2.0
import QtQuick.LocalStorage 2.0
import QtQuick.Controls.Material 2.0

Popup {
    // Popups (0, 0) to the (0, 0) of their parent.
    id: sleepPopupRoot

    property SleepButton sleepButton
    property alias forgotEnabled: forgotButton.enabled
    property alias forgotText: confirmButton.text
//    property alias forgotToolTipText: forgotButton.ToolTip.text  // can't do this.

    signal confirmClicked()
    signal forgotClicked()

    modal: true
    Material.foreground: Material.Indigo
    Material.background: "transparent"

    contentItem: ColumnLayout {
        id: popupContent

        Button {
            id: confirmButton

            text: qsTr("Confirm")
            Layout.preferredWidth: inBedButton.width / 2  // fix this dependency
            onClicked: sleepPopupRoot.confirmClicked();
        }

        Button {
            id: forgotButton

            text: qsTr("Forgot")
            Layout.fillWidth: true
            ToolTip.visible: pressed
            ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
            ToolTip.text: qsTr("Tap here if you forgot to\nconfirm your start time.")
            onClicked: sleepPopupRoot.forgotClicked();
        }
    }
}
