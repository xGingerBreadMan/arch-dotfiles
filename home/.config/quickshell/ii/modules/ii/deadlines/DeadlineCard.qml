import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    required property var task
    property bool expanded: false
    signal toggleRequested()
    signal editRequested(var task)
    implicitHeight: body.implicitHeight + 24
    radius: DeadlineTheme.radiusLarge
    color: DeadlineTheme.card
    border.width: expanded ? 1 : 0
    border.color: DeadlineTheme.accent

    // Course identity stays visible, but as a quiet accent rather than a full
    // neon outline around every card.
    Rectangle {
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom; leftMargin: 0 }
        width: 3
        radius: 2
        color: root.task.color
        opacity: root.task.completed ? 0.45 : 0.9
    }

    ColumnLayout {
        id: body
        anchors { left: parent.left; right: parent.right; top: parent.top; leftMargin: 16; rightMargin: 14; topMargin: 12 }
        spacing: 10

        Item {
            Layout.fillWidth: true
            implicitHeight: summary.implicitHeight
            ColumnLayout {
                id: summary
                width: parent.width
                spacing: 7

                RowLayout {
                    Layout.fillWidth: true
                    Rectangle {
                        Layout.maximumWidth: summary.width * 0.58
                        implicitWidth: courseRow.implicitWidth + 16
                        implicitHeight: 25
                        radius: DeadlineTheme.radiusFull
                        color: DeadlineTheme.field
                        RowLayout {
                            id: courseRow
                            anchors.centerIn: parent
                            spacing: 6
                            Rectangle {
                                width: 7; height: 7; radius: 4
                                color: root.task.color
                                opacity: root.task.completed ? 0.5 : 1
                            }
                            Text {
                                id: courseLabel
                                text: root.task.course
                                textFormat: Text.PlainText
                                color: DeadlineTheme.cardText
                                font.family: DeadlineTheme.fontMain
                                font.pixelSize: 11
                                font.bold: true
                                elide: Text.ElideRight
                            }
                        }
                    }
                    Item { Layout.fillWidth: true }
                    Text {
                        text: (root.task.urgent ? "!  " : "") + root.task.countdown
                        color: root.task.urgent ? DeadlineTheme.warning : DeadlineTheme.muted
                        font.family: DeadlineTheme.fontMain
                        font.pixelSize: 11
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.task.title
                    textFormat: Text.PlainText
                    color: DeadlineTheme.cardText
                    font.family: DeadlineTheme.fontMain
                    font.pixelSize: 15
                    font.bold: true
                    wrapMode: Text.Wrap
                }

                RowLayout {
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        text: root.task.date
                        color: DeadlineTheme.muted
                        font.family: DeadlineTheme.fontMain
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                    Text {
                        text: root.expanded ? "⌃" : "⌄"
                        color: DeadlineTheme.muted
                        font.family: DeadlineTheme.fontMain
                        font.pixelSize: 17
                    }
                }
            }

            MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.toggleRequested() }
            Accessible.role: Accessible.Button
            Accessible.name: root.task.title + (root.expanded ? ", collapse details" : ", expand details")
            Accessible.onPressAction: root.toggleRequested()
            activeFocusOnTab: true
            Keys.onReturnPressed: root.toggleRequested()
            Keys.onSpacePressed: root.toggleRequested()
        }

        ColumnLayout {
            visible: root.expanded
            Layout.fillWidth: true
            spacing: 10
            Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: DeadlineTheme.border; opacity: 0.55 }
            Text {
                Layout.fillWidth: true
                text: root.task.courseName
                textFormat: Text.PlainText
                color: DeadlineTheme.cardText
                font.family: DeadlineTheme.fontMain
                font.pixelSize: 14
                font.bold: true
                wrapMode: Text.Wrap
            }
            DeadlinePaper {
                Layout.fillWidth: true
                Layout.preferredHeight: 310
                visible: !!root.task.descriptionHtml || !!root.task.file
                documentHtml: root.task.descriptionHtml
                pdfFile: root.task.file
            }
            Text {
                visible: root.task.notes.length > 0
                Layout.fillWidth: true
                text: "Your notes\n" + root.task.notes
                textFormat: Text.PlainText
                color: DeadlineTheme.muted
                font.family: DeadlineTheme.fontMain
                font.pixelSize: 12
                wrapMode: Text.Wrap
            }
            Text {
                visible: !root.task.dropbox && !root.task.custom
                Layout.fillWidth: true
                text: "No dropbox link in this feed. Add it in Edit details."
                color: DeadlineTheme.muted
                font.family: DeadlineTheme.fontMain
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            Flow {
                Layout.fillWidth: true
                spacing: 6
                DeadlineButton { visible: !!root.task.dropbox; text: "Dropbox ↗"; selected: true; onClicked: DeadlineStore.open(root.task.dropbox) }
                DeadlineButton { text: "Edit / attach PDF"; onClicked: root.editRequested(root.task) }
                DeadlineButton {
                    text: root.task.completed ? "Mark unfinished" : "Mark done"
                    enabled: !DeadlineStore.saving
                    onClicked: DeadlineStore.save({action: "complete", key: root.task.key, completed: !root.task.completed})
                }
            }
        }
    }
}
