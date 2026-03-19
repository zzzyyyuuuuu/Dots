import QtQuick 
import QtQuick.Controls 
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: dockWindow

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "Zen-Dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        bottom: true
    }

    margins.bottom: Math.round(Screen.height * 0.008)
    implicitWidth: dockContent.width + Math.round(Screen.width * 0.02)
    implicitHeight: Math.round(Screen.height * 0.055)
    color: "transparent"
    exclusiveZone: Math.round(Screen.height * 0.065)

    Rectangle {
        id: mainDockBody
        anchors.centerIn: parent
        width: dockContent.width + Math.round(Screen.width * 0.02)
        height: Math.round(Screen.height * 0.051)
        radius: 16
        color: "#000000"
        border.width: 0

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: parent.height / 2
            radius: parent.radius
            color: "#0cffffff"
        }

        Row {
            id: dockContent
            anchors.centerIn: parent
            spacing: Math.round(Screen.width * 0.008)

            Component.onCompleted: {
                var apps = [
                    "󰈹:firefox",
                    "󰆍:foot",
                    "󰉋:thunar",
                    "󰓓:steam",
                    "󰙯:discord"
                ]
                for (var i = 0; i < apps.length; i++) {
                    var parts = apps[i].split(":")
                    dockIconComp.createObject(dockContent, {
                        icon: parts[0],
                        exec: parts[1]
                    })
                }
            }
        }
    }

    Component {
        id: dockIconComp
        Item {
            property string icon: ""
            property string exec: ""
            width: Math.round(Screen.height * 0.038)
            height: Math.round(Screen.height * 0.038)

            Text {
                anchors.centerIn: parent
                text: icon
                font.pixelSize: Math.round(Screen.height * 0.026)
                color: "#ffffff"
                font.family: "Symbols Nerd Font"
                opacity: mouse.containsMouse ? 1.0 : 0.75

                Behavior on opacity {
                    NumberAnimation { duration: 150 }
                }
            }

            MouseArea {
                id: mouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: Quickshell.execDetached(["bash", "-c", exec])
            }

            scale: mouse.containsMouse ? 1.3 : 1.0
            Behavior on scale {
                NumberAnimation {
                    duration: 200
                    easing.type: Easing.OutBack
                }
            }
        }
    }
}
