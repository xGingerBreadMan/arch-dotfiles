import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    objectName: "deadlineSettings"
    property bool feedLocked: true
    property string status: ""
    property string colorCourse: ""
    property int red: 130
    property int green: 180
    property int blue: 255
    readonly property color draftColor: Qt.rgba(red / 255, green / 255, blue / 255, 1)
    signal closed()
    function setDraft(value) {
        const hex = value.replace(/^#/, "");
        if (!/^[0-9a-fA-F]{6}$/.test(hex)) return;
        red = parseInt(hex.slice(0, 2), 16);
        green = parseInt(hex.slice(2, 4), 16);
        blue = parseInt(hex.slice(4, 6), 16);
        hexInput.text = "#" + hex.toLowerCase();
    }
    function openColor(course, color) {
        colorCourse = course;
        setDraft(color);
        status = "";
        DeadlineStore.editError = "";
        Qt.callLater(() => {
            const y = inlinePicker.mapToItem(settingsContent, 0, 0).y;
            scroll.contentY = Math.max(0, Math.min(y, scroll.contentHeight - scroll.height));
        });
    }
    function applyColor() {
        if (DeadlineStore.saving || !/^#[0-9a-fA-F]{6}$/.test(hexInput.text)) return;
        DeadlineStore.save({action: "saveClassColor", course: colorCourse, color: hexInput.text.toLowerCase()});
    }
    function openPage() {
        feedLocked = true;
        colorCourse = "";
        feedInput.text = DeadlineStore.settings.feedUrl || "";
        status = "";
        DeadlineStore.editError = "";
    }
    onVisibleChanged: {
        if (!visible) { feedLocked = true; colorCourse = ""; }
    }
    Connections {
        target: DeadlineStore
        function onSettingsChanged() {
            if (root.feedLocked) feedInput.text = DeadlineStore.settings.feedUrl || "";
            if (!DeadlineStore.settings.feedPending && root.status === "Calendar link saved. Syncing…") root.status = "Calendar updated.";
        }
        function onSettingsSaved(action) {
            root.status = action === "saveFeed" ? "Calendar link saved. Syncing…" : "Saved.";
            if (action === "saveFeed") root.feedLocked = true;
            if (action === "saveClassColor") root.colorCourse = "";
        }
    }
    spacing: 12
    RowLayout {
        Layout.fillWidth: true
        DeadlineButton { text: "‹ Back"; enabled: !DeadlineStore.saving; onClicked: root.closed() }
        Text { Layout.fillWidth: true; text: "Settings"; color: DeadlineTheme.text; font { family: DeadlineTheme.fontTitle; pixelSize: 22; bold: true } }
    }
    Flickable {
        id: scroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: settingsContent.implicitHeight + 12
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        ScrollBar.vertical: ScrollBar {}
        ColumnLayout {
            id: settingsContent
            width: scroll.width - 8
            spacing: 18
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: calendarControls.implicitHeight + 28
                color: DeadlineTheme.card
                radius: DeadlineTheme.radiusLarge
                border.width: 0
                border.color: "transparent"
                ColumnLayout {
                    id: calendarControls
                    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                    spacing: 10
                    Text { text: "MyLS calendar"; color: DeadlineTheme.text; font { family: DeadlineTheme.fontTitle; pixelSize: 17; bold: true } }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { Layout.fillWidth: true; text: root.feedLocked ? "Share link · locked" : "Share link · editing"; color: DeadlineTheme.muted; font.pixelSize: 12 }
                        Button {
                            id: lockButton
                            implicitWidth: 28
                            implicitHeight: 26
                            enabled: !DeadlineStore.saving && !DeadlineStore.busy
                            Accessible.name: root.feedLocked ? "Unlock calendar link" : "Lock calendar link and discard edits"
                            ToolTip.visible: hovered
                            ToolTip.text: Accessible.name
                            onClicked: {
                                if (root.feedLocked) { root.feedLocked = false; feedInput.forceActiveFocus(); }
                                else { root.feedLocked = true; feedInput.text = DeadlineStore.settings.feedUrl || ""; }
                                root.status = "";
                            }
                            background: Rectangle { radius: DeadlineTheme.radiusFull; color: lockButton.hovered ? DeadlineTheme.cardHover : "transparent" }
                            contentItem: Item {
                                Rectangle {
                                    x: 7; y: root.feedLocked ? 1 : -1; width: 10; height: 11; radius: 5
                                    border.width: 2; border.color: DeadlineTheme.muted; color: "transparent"
                                    rotation: root.feedLocked ? 0 : -25
                                }
                                Rectangle { x: 4; y: 9; width: 16; height: 12; radius: 3; color: DeadlineTheme.muted }
                                Rectangle { x: 11; y: 12; width: 2; height: 5; radius: 1; color: DeadlineTheme.card }
                            }
                        }
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 104
                        radius: DeadlineTheme.radiusSmall
                        color: root.feedLocked ? DeadlineTheme.cardHover : DeadlineTheme.field
                        border.color: DeadlineTheme.accent
                        border.width: root.feedLocked ? 0 : 1
                        Behavior on color { ColorAnimation { duration: 150 } }
                        ScrollView {
                            anchors { fill: parent; margins: 7 }
                            contentWidth: availableWidth
                            TextArea {
                                id: feedInput
                                objectName: "calendarShareLink"
                                readOnly: root.feedLocked || DeadlineStore.saving
                                selectByMouse: true
                                textFormat: TextEdit.PlainText
                                wrapMode: TextEdit.WrapAnywhere
                                color: root.feedLocked ? DeadlineTheme.muted : DeadlineTheme.text
                                placeholderText: "Paste your MyLS calendar share link"
                                placeholderTextColor: DeadlineTheme.muted
                                font.pixelSize: 12
                                background: null
                            }
                        }
                    }
                    RowLayout {
                        visible: !root.feedLocked
                        Layout.fillWidth: true
                        DeadlineButton {
                            Layout.fillWidth: true
                            text: DeadlineStore.saving ? "Saving…" : "Save & sync"
                            selected: true
                            enabled: !DeadlineStore.saving && !DeadlineStore.busy && feedInput.text.trim().length > 0
                            onClicked: DeadlineStore.save({action: "saveFeed", url: feedInput.text})
                        }
                        DeadlineButton {
                            text: "Cancel"
                            enabled: !DeadlineStore.saving
                            onClicked: { root.feedLocked = true; feedInput.text = DeadlineStore.settings.feedUrl || ""; }
                        }
                    }
                    Text {
                        Layout.fillWidth: true
                        text: "Unlock to change calendars. Your custom tasks and class colours are kept."
                        color: DeadlineTheme.muted
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                Text { text: "Appearance"; color: DeadlineTheme.text; font { family: DeadlineTheme.fontTitle; pixelSize: 17; bold: true } }
                Text {
                    Layout.fillWidth: true
                    text: "Illogical Impulse follows the shell theme, transparency, and the primary colour generated from your wallpaper."
                    color: DeadlineTheme.muted
                    font { family: DeadlineTheme.fontMain; pixelSize: 11 }
                    wrapMode: Text.Wrap
                }
                RowLayout {
                    Layout.fillWidth: true
                    Repeater {
                        model: [{key: "system", name: "Illogical Impulse"}, {key: "light", name: "Light"}, {key: "dark", name: "Dark"}]
                        DeadlineButton {
                            required property var modelData
                            Layout.fillWidth: true
                            text: modelData.name
                            selected: DeadlineStore.settings.theme === modelData.key
                            enabled: !DeadlineStore.saving
                            onClicked: DeadlineStore.save({action: "saveTheme", theme: modelData.key})
                        }
                    }
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10
                Text { text: "Class colours"; color: DeadlineTheme.text; font { family: DeadlineTheme.fontTitle; pixelSize: 17; bold: true } }
                Text {
                    Layout.fillWidth: true
                    text: "Click a colour to customize it. Auto chooses a distinct colour; your other choices stay unchanged."
                    color: DeadlineTheme.muted
                    font.pixelSize: 11
                    wrapMode: Text.Wrap
                }
                Rectangle {
                    id: inlinePicker
                    objectName: "inlineColourPicker"
                    Layout.fillWidth: true
                    visible: root.colorCourse.length > 0
                    implicitHeight: pickerContent.implicitHeight + 28
                    radius: DeadlineTheme.radius
                    color: DeadlineTheme.field
                    border.width: 0
                    border.color: "transparent"
                    ColumnLayout {
                        id: pickerContent
                        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                        spacing: 10
                        Text {
                            Layout.fillWidth: true
                            text: "Colour for " + root.colorCourse
                            color: DeadlineTheme.text
                            font { pixelSize: 15; bold: true }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            Rectangle {
                                implicitWidth: 46; implicitHeight: 40; radius: 8
                                color: root.draftColor
                                border.color: DeadlineTheme.border
                            }
                            TextField {
                                id: hexInput
                                objectName: "colourHexInput"
                                Layout.fillWidth: true
                                enabled: !DeadlineStore.saving
                                color: DeadlineTheme.text
                                selectByMouse: true
                                maximumLength: 7
                                placeholderText: "#82b4ff"
                                Accessible.name: "Hex colour"
                                onTextEdited: {
                                    if (/^#[0-9a-fA-F]{6}$/.test(text)) root.setDraft(text);
                                }
                                onAccepted: root.applyColor()
                                background: Rectangle {
                                    radius: DeadlineTheme.radiusSmall
                                    color: DeadlineTheme.field
                                    border.width: /^#[0-9a-fA-F]{6}$/.test(hexInput.text) ? (hexInput.activeFocus ? 1 : 0) : 1
                                    border.color: /^#[0-9a-fA-F]{6}$/.test(hexInput.text) ? DeadlineTheme.accent : DeadlineTheme.warning
                                }
                            }
                        }
                        Flow {
                            Layout.fillWidth: true
                            spacing: 7
                            Repeater {
                                model: ["#82b4ff", "#ffb347", "#64dda5", "#e593ef", "#f3e26f", "#ff8697", "#69dce9", "#ffffff"]
                                Button {
                                    required property string modelData
                                    implicitWidth: 29; implicitHeight: 29
                                    enabled: !DeadlineStore.saving
                                    Accessible.name: "Use colour " + modelData
                                    background: Rectangle {
                                        radius: DeadlineTheme.radiusFull
                                        color: parent.modelData
                                        border.width: parent.activeFocus ? 2 : 0
                                        border.color: DeadlineTheme.accent
                                    }
                                    onClicked: root.setDraft(modelData)
                                }
                            }
                        }
                        Repeater {
                            model: [{key: "red", name: "Red"}, {key: "green", name: "Green"}, {key: "blue", name: "Blue"}]
                            RowLayout {
                                required property var modelData
                                Layout.fillWidth: true
                                Text { Layout.preferredWidth: 44; text: modelData.name; color: DeadlineTheme.muted; font.pixelSize: 12 }
                                Slider {
                                    Layout.fillWidth: true
                                    from: 0; to: 255; stepSize: 1
                                    enabled: !DeadlineStore.saving
                                    value: root[modelData.key]
                                    Accessible.name: modelData.name + " channel"
                                    onMoved: {
                                        root[modelData.key] = Math.round(value);
                                        hexInput.text = root.draftColor.toString();
                                    }
                                }
                                Text { Layout.preferredWidth: 26; text: root[modelData.key]; color: DeadlineTheme.muted; font.pixelSize: 11 }
                            }
                        }
                        RowLayout {
                            Layout.fillWidth: true
                            DeadlineButton {
                                objectName: "applyColourButton"
                                Layout.fillWidth: true
                                text: DeadlineStore.saving ? "Saving…" : "Apply colour"
                                selected: true
                                enabled: !DeadlineStore.saving && /^#[0-9a-fA-F]{6}$/.test(hexInput.text)
                                onClicked: root.applyColor()
                            }
                            DeadlineButton {
                                objectName: "cancelColourButton"
                                text: "Cancel"
                                enabled: !DeadlineStore.saving
                                onClicked: root.colorCourse = ""
                            }
                        }
                    }
                }
                Repeater {
                    model: DeadlineStore.classes
                    Rectangle {
                        id: classRow
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: Math.max(72, courseInfo.implicitHeight + 24)
                        radius: DeadlineTheme.radius
                        color: DeadlineTheme.card
                        border.width: 0
                        border.color: "transparent"
                        RowLayout {
                            anchors { fill: parent; margins: 12 }
                            spacing: 10
                            ColumnLayout {
                                id: courseInfo
                                Layout.fillWidth: true
                                spacing: 3
                                Text { text: classRow.modelData.code; color: DeadlineTheme.text; font { pixelSize: 14; bold: true } }
                                Text { Layout.fillWidth: true; text: classRow.modelData.name; color: DeadlineTheme.muted; textFormat: Text.PlainText; font.pixelSize: 11; wrapMode: Text.Wrap }
                            }
                            Button {
                                implicitWidth: 38; implicitHeight: 38
                                enabled: !DeadlineStore.saving
                                Accessible.name: "Choose colour for " + classRow.modelData.code
                                ToolTip.visible: hovered
                                ToolTip.text: classRow.modelData.color
                                background: Rectangle { radius: DeadlineTheme.radiusFull; color: classRow.modelData.color; border.width: parent.activeFocus ? 2 : 0; border.color: DeadlineTheme.accent }
                                onClicked: {
                                    root.openColor(classRow.modelData.code, classRow.modelData.color);
                                }
                            }
                            DeadlineButton {
                                text: "Auto"
                                enabled: !DeadlineStore.saving
                                onClicked: DeadlineStore.save({action: "saveClassColor", course: classRow.modelData.code, color: null})
                            }
                        }
                    }
                }
                Text {
                    visible: DeadlineStore.classes.length === 0
                    Layout.fillWidth: true
                    text: "Classes will appear after your calendar syncs."
                    color: DeadlineTheme.muted
                    font.pixelSize: 12
                    wrapMode: Text.Wrap
                }
            }
        }
    }
    Text {
        Layout.fillWidth: true
        visible: (DeadlineStore.editError || root.status || DeadlineStore.message).length > 0
        text: DeadlineStore.editError || (DeadlineStore.settings.feedPending ? DeadlineStore.message : root.status || DeadlineStore.message)
        color: DeadlineStore.editError ? DeadlineTheme.warning : DeadlineTheme.muted
        font.pixelSize: 12
        wrapMode: Text.Wrap
    }
}
