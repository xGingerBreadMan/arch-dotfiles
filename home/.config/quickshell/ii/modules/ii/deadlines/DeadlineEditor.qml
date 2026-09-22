import QtQuick
import QtQuick.Dialogs
import QtQuick.Controls
import QtQuick.Layouts

ColumnLayout {
    id: root
    property var task: null
    readonly property bool custom: !task || task.custom
    property bool confirmDelete: false
    property string selectedPdf: ""
    signal closed()
    function load(item, day) {
        task = item;
        confirmDelete = false;
        selectedPdf = "";
        titleField.text = item ? item.title : "";
        courseField.text = item && item.course !== "Unassigned" ? item.course : "";
        courseNameField.text = item && item.courseName !== item.course ? item.courseName : "";
        dateField.text = item ? item.editDate : day || DeadlineStore.today;
        timeField.text = item ? item.editTime : "23:59";
        descriptionField.text = item ? item.description : "";
        notesField.text = item ? item.notes : "";
        urlField.text = item ? item.url : "";
        dropboxField.text = item ? item.dropbox : "";
        fileField.text = item ? item.file : "";
        DeadlineStore.editError = "";
        titleField.forceActiveFocus();
    }
    function submit() {
        if (custom && (!/^\d{4}-\d{2}-\d{2}$/.test(dateField.text.trim()) || !/^\d{2}:\d{2}$/.test(timeField.text.trim()))) {
            DeadlineStore.editError = "Use YYYY-MM-DD for the date and HH:MM (24-hour) for the time.";
            return;
        }
        DeadlineStore.save({
            action: custom ? "saveCustom" : "saveDetails", key: task ? task.key : "",
            title: titleField.text, due: dateField.text.trim() + "T" + timeField.text.trim(),
            course: courseField.text, courseName: courseNameField.text, attachPdf: selectedPdf, description: descriptionField.text, notes: notesField.text,
            url: urlField.text, dropbox: dropboxField.text, file: fileField.text
        });
    }
    FileDialog {
        id: pdfPicker
        title: "Attach assignment PDF"
        nameFilters: ["PDF documents (*.pdf)"]
        fileMode: FileDialog.OpenFile
        onAccepted: {
            root.selectedPdf = selectedFile.toString();
            fileField.text = decodeURIComponent(selectedFile.toString().replace(/^file:\/\//, ""));
        }
    }
    Connections {
        target: DeadlineStore
        function onSaved(key) { if (root.visible) root.closed(); }
    }
    spacing: 10
    component Field: TextField {
        color: DeadlineTheme.text
        placeholderTextColor: DeadlineTheme.muted
        selectByMouse: true
        font { family: DeadlineTheme.fontMain; pixelSize: 13 }
        implicitHeight: 40
        leftPadding: 10
        rightPadding: 10
        background: Rectangle {
            radius: DeadlineTheme.radiusSmall
            color: DeadlineTheme.field
            border.width: parent.activeFocus ? 1 : 0
            border.color: DeadlineTheme.accent
        }
    }
    component Caption: Text {
        color: DeadlineTheme.muted
        font { family: DeadlineTheme.fontMain; pixelSize: 12 }
        wrapMode: Text.Wrap
    }
    RowLayout {
        Layout.fillWidth: true
        DeadlineButton { text: "‹ Back"; enabled: !DeadlineStore.saving; onClicked: root.closed() }
        Text {
            Layout.fillWidth: true
            text: !root.task ? "New task" : "Edit details"
            color: DeadlineTheme.text
            font { family: DeadlineTheme.fontTitle; pixelSize: 20; bold: true }
        }
    }
    Flickable {
        id: scroll
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true
        contentWidth: width
        contentHeight: fields.implicitHeight + 12
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar {}
        ColumnLayout {
            id: fields
            width: scroll.width - 10
            spacing: 8
            Caption { text: "Task title" }
            Field { id: titleField; Layout.fillWidth: true; readOnly: !root.custom; placeholderText: "What needs doing?" }
            Caption { text: "Course code" }
            Field { id: courseField; Layout.fillWidth: true; placeholderText: "e.g. PS-102" }
            Caption { text: "Full course name" }
            Field { id: courseNameField; Layout.fillWidth: true; placeholderText: "e.g. Introduction to Psychology II" }
            Caption { Layout.fillWidth: true; text: "Due date and time · " + DeadlineStore.timezone }
            RowLayout {
                Layout.fillWidth: true
                Field { id: dateField; Layout.fillWidth: true; Layout.preferredWidth: 2; readOnly: !root.custom; placeholderText: "YYYY-MM-DD" }
                Field { id: timeField; Layout.fillWidth: true; Layout.preferredWidth: 1; readOnly: !root.custom; placeholderText: "HH:MM" }
            }
            Caption {
                visible: !root.custom
                Layout.fillWidth: true
                text: "MyLS controls this title and date. Your class label, links and notes are saved locally."
            }
            Caption { text: "Description" }
            TextArea {
                id: descriptionField
                Layout.fillWidth: true
                Layout.minimumHeight: 80
                readOnly: !root.custom
                color: DeadlineTheme.text
                placeholderTextColor: DeadlineTheme.muted
                placeholderText: "Task details"
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                background: Rectangle { radius: DeadlineTheme.radiusSmall; color: DeadlineTheme.field; border.width: parent.activeFocus ? 1 : 0; border.color: DeadlineTheme.accent }
            }
            Caption { text: "Your notes" }
            TextArea {
                id: notesField
                Layout.fillWidth: true
                Layout.minimumHeight: 70
                color: DeadlineTheme.text
                placeholderTextColor: DeadlineTheme.muted
                placeholderText: "Plan, requirements, reminders…"
                textFormat: TextEdit.PlainText
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                background: Rectangle { radius: DeadlineTheme.radiusSmall; color: DeadlineTheme.field; border.width: parent.activeFocus ? 1 : 0; border.color: DeadlineTheme.accent }
            }
            Caption { text: "Dropbox / submission link" }
            Field { id: dropboxField; Layout.fillWidth: true; placeholderText: "https://…" }
            Field { id: urlField; visible: false }
            Caption { text: "Assignment PDF" }
            RowLayout {
                DeadlineButton { text: "Choose PDF…"; onClicked: pdfPicker.open() }
                DeadlineButton { text: "Remove"; visible: fileField.text.length > 0; onClicked: { fileField.text = ""; root.selectedPdf = ""; } }
            }
            Field { id: fileField; Layout.fillWidth: true; placeholderText: "No PDF attached"; readOnly: true }
            Caption {
                Layout.fillWidth: true
                visible: !root.task
                text: "Custom tasks are stored on this computer. They are not submitted to MyLS."
            }
            DeadlineButton {
                visible: root.task !== null && root.custom
                text: root.confirmDelete ? "Confirm delete task" : "Delete custom task"
                enabled: !DeadlineStore.saving
                onClicked: {
                    if (root.confirmDelete) DeadlineStore.save({action: "deleteCustom", key: root.task.key});
                    else root.confirmDelete = true;
                }
            }
        }
    }
    Text {
        Layout.fillWidth: true
        visible: DeadlineStore.editError.length > 0
        text: DeadlineStore.editError
        color: DeadlineTheme.warning
        font { family: DeadlineTheme.fontMain; pixelSize: 12 }
        wrapMode: Text.Wrap
    }
    DeadlineButton {
        Layout.fillWidth: true
        selected: true
        text: DeadlineStore.saving ? "Saving…" : "Save task"
        enabled: !DeadlineStore.saving
        onClicked: root.submit()
    }
}
