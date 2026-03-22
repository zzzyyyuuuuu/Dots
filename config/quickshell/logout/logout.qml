import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

PanelWindow {
    id: logoutWin
    anchors { top: true; bottom: true; left: true; right: true }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    visible: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    readonly property string fontFam: "JetBrainsMono Nerd Font"

    Connections {
        target: logoutState
        function onShowChanged() {
            logoutWin.visible = logoutState.show
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.6)

        MouseArea {
            anchors.fill: parent
            onClicked: logoutState.show = false
        }

        Row {
            anchors.centerIn: parent
            spacing: 16

            Repeater {
                model: [
                    { icon: "󰌾", label: "Lock",      cmd: "hyprlock" },
                    { icon: "󰍃", label: "Logout",    cmd: "hyprctl dispatch exit" },
                    { icon: "󰒲", label: "Suspend",   cmd: "systemctl suspend" },
                    { icon: "󰐦", label: "Shutdown",  cmd: "systemctl poweroff" },
                    { icon: "󰜺", label: "Hibernate", cmd: "systemctl hibernate" },
                    { icon: "󰑓", label: "Reboot",    cmd: "systemctl reboot" }
                ]

                Rectangle {
                    width: 150; height: 200
                    radius: 20
                    color: cardMa.containsMouse ? Qt.rgba(1,1,1,0.2) : Qt.rgba(1,1,1,0.08)
                    border.width: cardMa.containsMouse ? 1 : 0
                    border.color: Qt.rgba(1,1,1,0.3)
                    scale: cardMa.containsMouse ? 1.08 : 1.0

                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                    Column {
                        anchors.centerIn: parent
                        spacing: 20

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.icon
                            font.pixelSize: 48
                            font.family: logoutWin.fontFam
                            color: "#ffffff"
                        }
                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: modelData.label
                            font.pixelSize: 14
                            font.family: logoutWin.fontFam
                            color: "#ffffff"
                        }
                    }

                    MouseArea {
                        id: cardMa
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            logoutState.show = false
                            runProc.command = ["bash", "-c", modelData.cmd]
                            runProc.running = true
                        }
                    }
                }
            }
        }

        focus: logoutWin.visible
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                logoutState.show = false
                event.accepted = true
            }
        }
    }

    Process { id: runProc }
}
