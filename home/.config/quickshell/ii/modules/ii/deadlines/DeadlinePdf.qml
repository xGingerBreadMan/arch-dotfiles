import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

ColumnLayout {
    id: root
    property string file: ""
    property int page: 1
    property int pages: 1
    property string imageUrl: ""
    property string error: ""
    property bool pending: false
    spacing: 0
    function render() {
        if (!file) return;
        if (process.running) { pending = true; return; }
        pending = false;
        error = "";
        imageUrl = "";
        process.requestedFile = file;
        process.command = [DeadlineStore.home + "/.local/bin/myls-deadline-view", "preview", file, String(page)];
        process.running = true;
    }
    onFileChanged: { page = 1; render(); }
    Process {
        id: process
        property string requestedFile: ""
        stdout: StdioCollector {
            onStreamFinished: {
                if (process.requestedFile !== root.file) return;
                try {
                    const result = JSON.parse(text);
                    if (result.ok) {
                        root.imageUrl = result.image;
                        root.page = result.page;
                        root.pages = result.pages;
                        pdfScroll.contentY = 0;
                    } else root.error = result.message || "Could not preview PDF.";
                } catch (error) { root.error = "Could not preview PDF."; }
            }
        }
        onExited: (code, status) => {
            if (code !== 0) root.error = "PDF preview failed.";
            if (root.pending) Qt.callLater(root.render);
        }
    }
    Item {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Flickable {
            id: pdfScroll
            anchors.fill: parent
            clip: true
            contentWidth: width
            contentHeight: pageImage.height
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar {}
            Image {
                id: pageImage
                width: pdfScroll.width - 10
                height: sourceSize.width > 0 ? width * sourceSize.height / sourceSize.width : 0
                source: root.imageUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                cache: true
            }
        }
        Text {
            anchors { centerIn: parent }
            width: parent.width - 30
            visible: process.running || root.error.length > 0
            text: root.error || "Loading PDF…"
            color: "#534c41"
            font.pixelSize: 12
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }
    }
    RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 8
        Layout.rightMargin: 8
        Button { text: "‹"; flat: true; enabled: root.page > 1 && !process.running; palette.buttonText: DeadlineTheme.accent; onClicked: { root.page--; root.render(); } }
        Text { Layout.fillWidth: true; text: root.page + " / " + root.pages; horizontalAlignment: Text.AlignHCenter; color: "#534c41"; font.pixelSize: 11 }
        Button { text: "Open ↗"; flat: true; palette.buttonText: DeadlineTheme.accent; onClicked: DeadlineStore.open(root.file) }
        Button { text: "›"; flat: true; enabled: root.page < root.pages && !process.running; palette.buttonText: DeadlineTheme.accent; onClicked: { root.page++; root.render(); } }
    }
}
