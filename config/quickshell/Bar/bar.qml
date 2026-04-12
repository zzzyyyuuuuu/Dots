import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow
        anchors { top: true; left: true; bottom: true }
        implicitWidth: 50 + (zyuTheme.floating_feel ? 15 : 0)
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Exclusive

        Rectangle {
            id: barRect
            anchors {
                fill: parent
                margins: zyuTheme.floating_feel ? 10 : 0
                rightMargin: zyuTheme.floating_feel ? 5 : 0
            }
            color: zyuTheme.bar_bg
            radius: zyuTheme.rounding

            ColumnLayout {
                anchors.fill: parent
                anchors.topMargin: 20
                anchors.bottomMargin: 20
                spacing: 0

                Column {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 2
                    
                    Text {
                        id: hourText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: zyuTheme.bar_fg
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14; font.bold: true
                        function updateTime() { text = new Date().getHours().toString().padStart(2, '0'); }
                        Component.onCompleted: updateTime()
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 3; height: 3; radius: 1.5
                        color: zyuTheme.accent; opacity: 0.5
                    }

                    Text {
                        id: minText
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: zyuTheme.accent
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 14; font.bold: true
                        function updateTime() { text = new Date().getMinutes().toString().padStart(2, '0'); }
                        Component.onCompleted: updateTime()
                    }

                    Timer { interval: 30000; running: true; repeat: true; 
                            onTriggered: { hourText.updateTime(); minText.updateTime(); } }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 15; Layout.bottomMargin: 15
                    width: 15; height: 1; color: zyuTheme.bar_fg; opacity: 0.1
                }

                Column {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.fillHeight: true
                    spacing: 12

                    Repeater {
                        model: Hyprland.workspaces
                        delegate: Item {
                            width: 20; height: 20
                            anchors.horizontalCenter: parent.horizontalCenter
                            property bool isActive: modelData.id === Hyprland.focusedMonitor?.activeWorkspace?.id

                            Rectangle {
                                id: shape
                                anchors.centerIn: parent
                                width: isActive ? 12 : 8
                                height: width
                                radius: isActive ? 1 : width / 2 
                                color: isActive ? zyuTheme.accent : zyuTheme.bar_fg
                                opacity: isActive ? 1.0 : 0.3
                                rotation: isActive ? 45 : 0 

                                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.InOutBack } }
                                Behavior on rotation { NumberAnimation { duration: 300; easing.type: Easing.InOutBack } }
                                Behavior on color { ColorAnimation { duration: 200 } }
                                Behavior on radius { NumberAnimation { duration: 300 } }
                            }

                            MouseArea {
                                anchors.fill: parent
                                onClicked: Hyprland.dispatch("workspace " + modelData.id)
                            }
                        }
                    }
                }

                Column {
                    Layout.alignment: Qt.AlignHCenter
                    
                    Text {
                        text: "󰕮"
                        font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 18
                        color: zyuTheme.bar_fg; opacity: 0.5
                        
                        MouseArea { 
                            anchors.fill: parent
                            onClicked: if (typeof dashboardState !== 'undefined') dashboardState.show = !dashboardState.show 
                        }
                    }
                }
            }
        }
    }
}
