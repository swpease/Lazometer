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
    property alias confirmText: confirmButton.text
    property alias forgotText: forgotButton.text
    property int buttonWidth
    property string forgotToolTipText

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
            Layout.preferredWidth: buttonWidth
            Layout.fillWidth: true
            onClicked: sleepPopupRoot.confirmClicked();
        }

        Button {
            id: forgotButton

            text: qsTr("Forgot")
            Layout.fillWidth: true
            ToolTip.visible: pressed
            ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
            ToolTip.text: forgotToolTipText
            onClicked: sleepPopupRoot.forgotClicked();
        }
    }
}
