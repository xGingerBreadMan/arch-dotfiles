pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    property var upcoming: []
    property var finished: []
    property var overdue: []
    property var all: []
    property var classes: []
    property var settings: ({theme: "system", feedUrl: "", feedPending: false})
    property string today: ""
    property string timezone: "America/Toronto"
    property string updated: ""
    property string message: "Loading deadlines…"
    property string editError: ""
    property bool loaded: false
    property bool refreshPending: false
    readonly property bool saving: writer.running
    readonly property bool busy: reader.running || syncProcess.running
    readonly property var nextDeadline: upcoming.length ? upcoming[0] : null
    readonly property string home: Quickshell.env("HOME")
    signal saved(string key)
    signal settingsSaved(string action)

    function refresh() {
        if (reader.running) refreshPending = true;
        else { refreshPending = false; reader.running = true; }
    }
    function sync(restart = false) {
        if (!syncProcess.running) {
            syncProcess.command = ["systemctl", "--user", restart ? "restart" : "start", "myls-calendar-sync.service"];
            syncProcess.running = true;
        }
    }
    function open(target) { if (target) Quickshell.execDetached(["xdg-open", target]); }
    function save(payload) {
        if (writer.running) return;
        editError = "";
        writer.command = [home + "/.local/bin/myls-deadline-view", "mutate", JSON.stringify(payload)];
        writer.running = true;
    }
    Component.onCompleted: refresh()
    Timer { interval: 30000; running: true; repeat: true; onTriggered: root.refresh() }
    Process {
        id: reader
        command: [root.home + "/.local/bin/myls-deadline-view"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    root.message = result.message || "";
                    if (result.ok) {
                        root.upcoming = result.upcoming;
                        root.finished = result.finished;
                        root.overdue = result.overdue || [];
                        root.all = result.all;
                        root.classes = result.classes || [];
                        root.settings = result.settings || root.settings;
                        root.today = result.today;
                        root.timezone = result.timezone;
                        root.updated = result.updated;
                        root.loaded = true;
                    }
                } catch (error) { root.message = "Could not read deadlines. Check myls-deadline-view."; }
            }
        }
        onExited: (code, status) => {
            if (code !== 0) root.message = "Deadline helper failed. Check myls-deadline-view.";
            if (root.refreshPending) Qt.callLater(root.refresh);
        }
    }
    Process {
        id: writer
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const result = JSON.parse(text);
                    if (result.ok) {
                        root.refresh();
                        root.saved(result.key || "");
                        if (result.action === "saveTheme" || result.action === "saveClassColor" || result.action === "saveFeed") root.settingsSaved(result.action);
                        if (result.needsSync) root.sync(true);
                    } else root.editError = result.message || "Could not save this task.";
                } catch (error) { root.editError = "Could not save this task. Check the deadline helper."; }
            }
        }
        onExited: (code, status) => {
            if (code !== 0) root.editError = "Could not save this task. Check the deadline helper.";
        }
    }

    Process {
        id: syncProcess
        command: ["systemctl", "--user", "start", "myls-calendar-sync.service"]
        onExited: (code, status) => {
            if (code === 0) root.refresh();
            else root.message = "Sync failed. Saved deadlines are still available. Try myls-calendar-sync.";
        }
    }
}
