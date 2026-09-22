import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: root
    property string selectedDay: DeadlineStore.today
    property int month: -1
    property int year: 2026
    signal daySelected(string day)

    function dateKey(date) {
        return date.getFullYear() + "-" + String(date.getMonth() + 1).padStart(2, "0") + "-" + String(date.getDate()).padStart(2, "0");
    }
    function goToday() {
        const parts = DeadlineStore.today.split("-");
        if (parts.length !== 3) return;
        year = Number(parts[0]); month = Number(parts[1]) - 1;
        selectedDay = DeadlineStore.today;
        daySelected(selectedDay);
    }
    function moveMonth(delta) {
        const date = new Date(year, month + delta, 1, 12);
        year = date.getFullYear(); month = date.getMonth();
    }
    function tasksOn(day) { return DeadlineStore.all.filter(task => task.day === day); }

    Component.onCompleted: goToday()
    Connections { target: DeadlineStore; function onTodayChanged() { if (root.month < 0) root.goToday(); } }
    spacing: 8

    RowLayout {
        Layout.fillWidth: true
        DeadlineButton { text: "‹"; Accessible.name: "Previous month"; onClicked: root.moveMonth(-1) }
        Text {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(new Date(root.year, Math.max(0, root.month), 1, 12), "MMMM yyyy")
            color: DeadlineTheme.text
            font.family: DeadlineTheme.fontTitle
            font.pixelSize: 16
            font.bold: true
        }
        DeadlineButton { text: "›"; Accessible.name: "Next month"; onClicked: root.moveMonth(1) }
        DeadlineButton { text: "Today"; onClicked: root.goToday() }
    }

    GridLayout {
        Layout.fillWidth: true
        columns: 7
        columnSpacing: 4
        rowSpacing: 4

        Repeater {
            model: ["M", "T", "W", "T", "F", "S", "S"]
            Text {
                required property string modelData
                Layout.fillWidth: true
                text: modelData
                horizontalAlignment: Text.AlignHCenter
                color: DeadlineTheme.muted
                font.family: DeadlineTheme.fontMain
                font.pixelSize: 11
            }
        }

        Repeater {
            model: 42
            Rectangle {
                id: cell
                required property int index
                readonly property var date: new Date(root.year, Math.max(0, root.month), 1 - ((new Date(root.year, Math.max(0, root.month), 1, 12).getDay() + 6) % 7) + index, 12)
                readonly property string day: root.dateKey(date)
                readonly property var tasks: root.tasksOn(day)
                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: 47
                radius: DeadlineTheme.radiusSmall
                color: day === root.selectedDay ? DeadlineTheme.accentContainer : DeadlineTheme.card
                border.width: day === DeadlineStore.today && day !== root.selectedDay ? 1 : 0
                border.color: DeadlineTheme.accent
                opacity: date.getMonth() === root.month ? 1 : 0.42

                Text {
                    anchors { horizontalCenter: parent.horizontalCenter; top: parent.top; topMargin: 5 }
                    text: cell.date.getDate()
                    color: cell.day === root.selectedDay ? DeadlineTheme.onAccentContainer : DeadlineTheme.cardText
                    font.family: DeadlineTheme.fontMain
                    font.pixelSize: 12
                    font.bold: cell.day === DeadlineStore.today || cell.day === root.selectedDay
                }

                Row {
                    anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 7 }
                    spacing: 2
                    Repeater {
                        model: cell.tasks.slice(0, 3)
                        Rectangle {
                            required property var modelData
                            width: 5; height: 5; radius: 2.5
                            color: modelData.color
                            opacity: modelData.completed ? 0.4 : 0.9
                        }
                    }
                    Text {
                        visible: cell.tasks.length > 3
                        text: "+"
                        color: cell.day === root.selectedDay ? DeadlineTheme.onAccentContainer : DeadlineTheme.muted
                        font.family: DeadlineTheme.fontMain
                        font.pixelSize: 8
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: { root.selectedDay = cell.day; root.daySelected(cell.day); }
                }
                activeFocusOnTab: true
                Accessible.role: Accessible.Button
                Accessible.name: day + ", " + tasks.length + " deadlines"
                Accessible.onPressAction: { root.selectedDay = cell.day; root.daySelected(cell.day); }
                Keys.onReturnPressed: { root.selectedDay = cell.day; root.daySelected(cell.day); }
                Keys.onSpacePressed: { root.selectedDay = cell.day; root.daySelected(cell.day); }
            }
        }
    }

    Text {
        Layout.fillWidth: true
        text: "Course colours mark due dates · " + DeadlineStore.timezone
        color: DeadlineTheme.muted
        font.family: DeadlineTheme.fontMain
        font.pixelSize: 11
        wrapMode: Text.Wrap
    }
}
