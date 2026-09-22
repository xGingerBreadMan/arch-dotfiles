import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    property string documentHtml: ""
    property string pdfFile: ""
    property bool showPdf: documentHtml.length === 0 && pdfFile.length > 0
    implicitHeight: 310
    radius: 8
    color: "#fffdf7"
    border.color: "#c8c1b4"
    border.width: 1
    clip: true
    ColumnLayout {
        anchors { fill: parent; margins: 1 }
        spacing: 0
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 35
            color: "#eee9df"
            RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 10 }
                spacing: 8
                Text { text: root.showPdf ? "ATTACHED PDF" : "ASSIGNMENT"; color: "#605849"; font { pixelSize: 10; bold: true } Layout.fillWidth: true }
                Button {
                    visible: !!root.documentHtml && !!root.pdfFile
                    text: root.showPdf ? "Assignment text" : "View PDF"
                    flat: true
                    font.pixelSize: 10
                    palette.buttonText: DeadlineTheme.accent
                    onClicked: root.showPdf = !root.showPdf
                }
            }
        }
        Flickable {
            id: paperScroll
            visible: !root.showPdf
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: width
            contentHeight: paperText.implicitHeight + 32
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            Text {
                id: paperText
                x: 16; y: 16
                width: paperScroll.width - 38
                text: '<style>p { margin-top: 0px; margin-bottom: 12px; } h1,h2,h3,h4 { margin-top: 8px; margin-bottom: 8px; }</style>' + root.documentHtml
                textFormat: Text.RichText
                color: "#292824"
                font { family: "sans-serif"; pixelSize: 14 }
                lineHeight: 1.25
                wrapMode: Text.Wrap
            }
        }
        Loader {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.showPdf
            active: root.visible && root.showPdf && !!root.pdfFile
            source: active ? "DeadlinePdf.qml" : ""
            onLoaded: item.file = Qt.binding(() => root.pdfFile)
        }
    }
}
