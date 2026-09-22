import qs
import qs.modules.ii.deadlines
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root
    required property var scopeRoot
    property int sidebarPadding: 10
    property int view: 0 // agenda, calendar, finished
    property bool editing: false
    property bool showingSettings: false
    property var expandedKeys: ({})
    property string selectedDay: DeadlineStore.today
    readonly property var groups: ["Past Due!", "Due Today:", "Due This Week:", "Coming Up:"]
    anchors.fill: parent
    function openSettings() { showingSettings = true; settingsPage.openPage(); }
    function focusActiveItem() { scroll.forceActiveFocus(); }
    function toggle(key) {
        const next = Object.assign({}, expandedKeys);
        next[key] = !next[key];
        expandedKeys = next;
    }
    function edit(item) {
        editing = true;
        editor.load(item, view === 1 ? selectedDay : DeadlineStore.today);
    }
    function groupRows(name) { if (name === "Past Due!") return DeadlineStore.overdue; return DeadlineStore.upcoming.filter(task => task.group === name); }
    function dayRows() { return DeadlineStore.all.filter(task => task.day === selectedDay); }
    Connections {
        target: GlobalStates
        function onSidebarLeftOpenChanged() { if (GlobalStates.sidebarLeftOpen) DeadlineStore.refresh(); }
    }
    Rectangle { anchors.fill: parent; anchors.margins: 3; radius: DeadlineTheme.radiusLarge; color: DeadlineTheme.background }
    ColumnLayout {
        anchors { fill: parent; margins: root.sidebarPadding + 3 }
        visible: !root.editing && !root.showingSettings
        spacing: 10
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: "Deadline Center"
                color: DeadlineTheme.text
                font { family: DeadlineTheme.fontTitle; pixelSize: 22; bold: true }
                elide: Text.ElideRight
            }
            DeadlineButton { text: "⚙"; Accessible.name: "Deadline settings"; onClicked: root.openSettings() }
            DeadlineButton { text: "+ Task"; selected: true; onClicked: root.edit(null) }
            DeadlineButton { text: "×"; Accessible.name: "Close Deadline Center"; onClicked: GlobalStates.sidebarLeftOpen = false }
        }
        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: DeadlineStore.updated ? "MyLS · " + DeadlineStore.updated : "MyLearningSpace"
                color: DeadlineTheme.muted
                font.pixelSize: 11
                wrapMode: Text.Wrap
            }
            DeadlineButton { text: "MyLS ↗"; Accessible.name: "Open MyLearningSpace"; onClicked: DeadlineStore.open("https://mylearningspace.wlu.ca/") }
            DeadlineButton { text: DeadlineStore.busy ? "Syncing…" : "Sync"; enabled: !DeadlineStore.busy; onClicked: DeadlineStore.sync() }
        }
        Text {
            Layout.fillWidth: true
            visible: DeadlineStore.message.length > 0 || DeadlineStore.editError.length > 0
            text: DeadlineStore.editError || DeadlineStore.message
            color: DeadlineTheme.warning
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            DeadlineButton { Layout.fillWidth: true; text: "Agenda"; selected: root.view === 0; onClicked: root.view = 0 }
            DeadlineButton { Layout.fillWidth: true; text: "Calendar"; selected: root.view === 1; onClicked: root.view = 1 }
            DeadlineButton { Layout.fillWidth: true; text: "Finished"; selected: root.view === 2; onClicked: root.view = 2 }
        }
        Flickable {
            id: scroll
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentWidth: width
            contentHeight: pages.implicitHeight + 10
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            ColumnLayout {
                id: pages
                width: scroll.width - 8
                spacing: 12
                ColumnLayout {
                    visible: root.view === 0
                    Layout.fillWidth: true
                    spacing: 16
                    Repeater {
                        model: root.groups
                        ColumnLayout {
                            id: section
                            required property string modelData
                            readonly property var rows: root.groupRows(modelData)
                            visible: modelData !== "Past Due!" || rows.length > 0
                            Layout.fillWidth: true
                            spacing: 8
                            RowLayout {
                                Layout.fillWidth: true
                                Text { text: section.modelData; color: section.modelData === "Past Due!" ? DeadlineTheme.warning : DeadlineTheme.text; font { family: DeadlineTheme.fontTitle; pixelSize: 15; bold: true } }
                                Item { Layout.fillWidth: true }
                                Text { text: section.rows.length; color: DeadlineTheme.muted; font.pixelSize: 12 }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: section.rows.length === 0
                                text: "Nothing due here."
                                color: DeadlineTheme.muted
                                font.pixelSize: 12
                                bottomPadding: 8
                            }
                            Repeater {
                                model: section.rows
                                DeadlineCard {
                                    required property var modelData
                                    Layout.fillWidth: true
                                    task: modelData
                                    expanded: !!root.expandedKeys[task.key]
                                    onToggleRequested: root.toggle(task.key)
                                    onEditRequested: task => root.edit(task)
                                }
                            }
                        }
                    }
                }
                ColumnLayout {
                    visible: root.view === 1
                    Layout.fillWidth: true
                    spacing: 12
                    DeadlineCalendar {
                        Layout.fillWidth: true
                        onDaySelected: day => root.selectedDay = day
                    }
                    Text {
                        Layout.fillWidth: true
                        text: root.selectedDay + " · " + root.dayRows().length + " deadlines"
                        color: DeadlineTheme.accent
                        font { family: DeadlineTheme.fontTitle; pixelSize: 15; bold: true }
                    }
                    Repeater {
                        model: root.dayRows()
                        DeadlineCard {
                            required property var modelData
                            Layout.fillWidth: true
                            task: modelData
                            expanded: !!root.expandedKeys[task.key]
                            onToggleRequested: root.toggle(task.key)
                            onEditRequested: task => root.edit(task)
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: root.dayRows().length === 0
                        text: "No tasks due on this date. Use + Task to add one."
                        color: DeadlineTheme.muted
                        font.pixelSize: 12
                        wrapMode: Text.Wrap
                    }
                }
                ColumnLayout {
                    visible: root.view === 2
                    Layout.fillWidth: true
                    spacing: 10
                    Text {
                        Layout.fillWidth: true
                        text: "Tasks you have marked done."
                        color: DeadlineTheme.muted
                        wrapMode: Text.Wrap
                        font.pixelSize: 12
                    }
                    Repeater {
                        model: DeadlineStore.finished
                        DeadlineCard {
                            required property var modelData
                            Layout.fillWidth: true
                            task: modelData
                            expanded: !!root.expandedKeys[task.key]
                            onToggleRequested: root.toggle(task.key)
                            onEditRequested: task => root.edit(task)
                        }
                    }
                    Text {
                        visible: DeadlineStore.finished.length === 0
                        text: "No completed tasks yet."
                        color: DeadlineTheme.muted
                        font.pixelSize: 12
                    }
                }
            }
        }
        Text {
            Layout.fillWidth: true
            text: "Ctrl+O resize · Ctrl+P pin · Ctrl+D detach"
            horizontalAlignment: Text.AlignHCenter
            color: DeadlineTheme.muted
            font.pixelSize: 10
        }
    }
    DeadlineSettings {
        id: settingsPage
        anchors { fill: parent; margins: root.sidebarPadding + 3 }
        visible: root.showingSettings
        onClosed: root.showingSettings = false
    }
    DeadlineEditor {
        id: editor
        anchors { fill: parent; margins: root.sidebarPadding + 3 }
        visible: root.editing
        onClosed: { root.editing = false; DeadlineStore.editError = ""; }
    }
}
