pragma Singleton
import QtQuick
import qs.modules.common

QtObject {
    // "system" means: follow illogical-impulse completely, including the
    // Material You palette regenerated from the current wallpaper.
    readonly property bool followsII: DeadlineStore.settings.theme === "system"
    readonly property bool dark: DeadlineStore.settings.theme === "dark"
        || (DeadlineStore.settings.theme !== "light" && Appearance.m3colors.darkmode)

    // Main surfaces. In II mode these are the same layered surfaces used by
    // the bar, settings app and sidebars, so transparency/tint stays in sync.
    readonly property color background: followsII ? Qt.lighter(Appearance.colors.colLayer0, 1.18) : (dark ? "#141313" : "#fbf8f8")
    readonly property color card: followsII ? Qt.lighter(Appearance.colors.colLayer1, 1.16) : (dark ? "#1c1b1c" : "#f5f0f0")
    readonly property color cardHover: followsII ? Qt.lighter(Appearance.colors.colLayer1Hover, 1.18) : (dark ? "#292728" : "#ebe5e5")
    readonly property color field: followsII ? Qt.lighter(Appearance.colors.colLayer2, 1.12) : (dark ? "#201f20" : "#eee8e8")
    readonly property color fieldHover: followsII ? Qt.lighter(Appearance.colors.colLayer2Hover, 1.14) : (dark ? "#302e2f" : "#e4dddd")

    // Text and separators.
    readonly property color text: followsII ? Appearance.colors.colOnLayer0 : (dark ? "#e6e1e1" : "#201a1a")
    readonly property color cardText: followsII ? Appearance.colors.colOnLayer1 : text
    readonly property color muted: followsII ? Appearance.colors.colSubtext : (dark ? "#cbc5ca" : "#6f666a")
    readonly property color border: followsII ? Appearance.colors.colOutlineVariant : (dark ? "#49464a" : "#d8d0d3")

    // Dynamic accent. In II mode this is automatically derived from the
    // wallpaper by illogical-impulse's Material theme loader.
    readonly property color accent: followsII ? Appearance.colors.colPrimary : (dark ? "#d4c2d4" : "#665466")
    readonly property color accentHover: followsII ? Appearance.colors.colPrimaryHover : accent
    readonly property color accentContainer: followsII ? Appearance.colors.colPrimaryContainer : (dark ? "#4d3f4d" : "#eaddea")
    readonly property color accentContainerHover: followsII ? Appearance.colors.colPrimaryContainerHover : accentContainer
    readonly property color onAccent: followsII ? Appearance.colors.colOnPrimary : (dark ? "#352f35" : "#ffffff")
    readonly property color onAccentContainer: cardText

    readonly property color warning: followsII ? Appearance.colors.colError : (dark ? "#ffb4ab" : "#ba1a1a")
    readonly property color warningContainer: followsII ? Appearance.colors.colErrorContainer : (dark ? "#93000a" : "#ffdad6")
    readonly property color onWarningContainer: followsII ? Appearance.colors.colOnErrorContainer : (dark ? "#ffdad6" : "#410002")

    // Keep component geometry/font choices aligned with II where possible.
    readonly property int radiusSmall: followsII ? Appearance.rounding.verysmall : 8
    readonly property int radius: followsII ? Appearance.rounding.small : 12
    readonly property int radiusLarge: followsII ? Appearance.rounding.normal : 17
    readonly property int radiusFull: followsII ? Appearance.rounding.full : 9999
    readonly property string fontMain: followsII ? Appearance.font.family.main : "sans-serif"
    readonly property string fontTitle: followsII ? Appearance.font.family.title : fontMain
}
