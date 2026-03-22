import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    id: root

    QtObject {
        id: zyuTheme
        property bool floating_feel: true
        property color bar_bg:    "#000000"
        property color bar_fg:    "#ffffff"
        property color accent:    "#ffffff"
        property color widget_bg: "#1a1a1a"
        property int bar_height: 50
        property int rounding:   15
        property font mainFont: Qt.font({family: "JetBrainsMono Nerd Font", pixelSize: 14, bold: true})
    }

    QtObject {
        id: dashboardState
        property bool show: false
    }

    QtObject {
        id: logoutState
        property bool show: false
    }

    Process {
        id: colorProc
        command: ["bash", "-c", "cat " + Quickshell.env("HOME") + "/.config/quickshell/Colors/colors.json"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    var c = JSON.parse(data)
                    if (c.background)        zyuTheme.bar_bg    = c.background
                    if (c.on_surface)        zyuTheme.bar_fg    = c.on_surface
                    if (c.primary)           zyuTheme.accent    = c.primary
                    if (c.surface_container) zyuTheme.widget_bg = c.surface_container
                } catch(e) {}
            }
        }
        Component.onCompleted: running = true
    }

    Loader { source: Quickshell.env("HOME") + "/.config/quickshell/Dashboard/Dashboard.qml" }
    Loader { source: "Bar/bar.qml" }
    Loader { source: "logout/logout.qml" }
}
