import QtQuick
import Quickshell
import Quickshell.Io

import "root:/config"
import "root:/launcher"
import "root:/services"
import "root:/startup"

ShellRoot {
    id: root

    Component.onCompleted: {
        Settings.pages = {
            "clock": false,
            "apps": false,
            "walls": true,
            "clips": false
        }
        Settings.pageOrder = ["walls"]
        Settings.wallpaperStyle = "carousel"
    }

    SettingsStore {}
    LaunchCountsStore {}

    LauncherWindow {
        id: launcher
    }

    XrayScaleProbe {}

    IpcHandler {
        target: "wallpaper"

        function toggle(): void {
            LauncherState.setPane("walls");

            if (launcher.shown && !LauncherState.exiting)
                launcher.exit();
            else
                launcher.open("walls");
        }

        function open(): void {
            LauncherState.setPane("walls");

            if (!launcher.shown || LauncherState.exiting)
                launcher.open("walls");
        }

        function close(): void {
            if (launcher.shown)
                launcher.exit();
        }
    }
}
