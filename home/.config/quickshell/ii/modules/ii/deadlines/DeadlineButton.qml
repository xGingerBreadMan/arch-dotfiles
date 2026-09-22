import QtQuick
import QtQuick.Controls

Button {
    id: root
    property bool selected: false
    implicitHeight: 36
    implicitWidth: Math.max(36, contentItem.implicitWidth + 24)
    padding: 10
    opacity: enabled ? 1 : 0.45

    contentItem: Text {
        text: root.text
        color: root.selected ? "#f2f4f3" : DeadlineTheme.cardText
        font.family: DeadlineTheme.fontMain
        font.pixelSize: 12
        font.bold: root.selected
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: DeadlineTheme.radiusFull
        color: root.selected
            ? (root.down || root.hovered ? DeadlineTheme.accentContainerHover : DeadlineTheme.accentContainer)
            : (root.down || root.hovered ? DeadlineTheme.cardHover : "transparent")
        border.width: root.activeFocus ? 2 : 0
        border.color: DeadlineTheme.accent
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}
