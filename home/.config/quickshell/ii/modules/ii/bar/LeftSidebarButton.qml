import QtQuick
import QtQuick.Layouts
import qs
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.ii.deadlines

RippleButton {
    id: root
    visible: true
    implicitWidth: content.implicitWidth + 16
    implicitHeight: content.implicitHeight + 10
    buttonRadius: Appearance.rounding.full
    colBackgroundHover: Appearance.colors.colLayer1Hover
    colRipple: Appearance.colors.colLayer1Active
    colBackgroundToggled: Appearance.colors.colSecondaryContainer
    colBackgroundToggledHover: Appearance.colors.colSecondaryContainerHover
    colRippleToggled: Appearance.colors.colSecondaryContainerActive
    toggled: GlobalStates.sidebarLeftOpen
    onPressed: GlobalStates.sidebarLeftOpen = !GlobalStates.sidebarLeftOpen
    RowLayout {
        id: content
        anchors.centerIn: parent
        spacing: 5
        MaterialSymbol {
            text: "description"
            iconSize: 20
            color: Appearance.colors.colOnLayer0
        }
        StyledText {
            text: DeadlineStore.nextDeadline ? DeadlineStore.nextDeadline.short : DeadlineStore.loaded ? "Clear" : "…"
            color: Appearance.colors.colOnLayer0
        }
        StyledText {
            visible: DeadlineStore.nextDeadline?.urgent ?? false
            text: "!"
            font.bold: true
            color: Appearance.colors.colTertiary
        }
    }
}
