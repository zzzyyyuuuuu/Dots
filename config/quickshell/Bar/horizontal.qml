import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: barWindow
        anchors { top: true; left: true; right: true }
        implicitHeight: 50 + (zyuTheme.floating_feel ? 15 : 0)
        color: "transparent"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Exclusive
        
        visible: {
            const activeWs = Hyprland.focusedMonitor?.activeWorkspace;
            return activeWs ? activeWs.id > 0 : true;
        }

        Rectangle {
            id: barRect
            anchors {
                fill: parent
                margins: zyuTheme.floating_feel ? 10 : 0
                bottomMargin: zyuTheme.floating_feel ? 5 : 0
            }
            color: zyuTheme.bar_bg
            radius: zyuTheme.rounding

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 0

                Text {
                    id: clockText
                    Layout.alignment: Qt.AlignVCenter
                    color: zyuTheme.bar_fg
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14
                    font.bold: true
                    function updateTime() {
                        const now = new Date();
                        const h = now.getHours().toString().padStart(2, '0');
                        const m = now.getMinutes().toString().padStart(2, '0');
                        text = h + ":" + m;
                    }
                    Component.onCompleted: updateTime()
                    Timer { interval: 30000; running: true; repeat: true; onTriggered: clockText.updateTime() }
                }

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 15; Layout.rightMargin: 15
                    width: 1; height: 15; color: zyuTheme.bar_fg; opacity: 0.1
                }

                Row {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.fillWidth: true
                    spacing: 12

                    Repeater {
                        model: Hyprland.workspaces
                        delegate: Item {
                            width: 20; height: 20
                            anchors.verticalCenter: parent.verticalCenter
                            visible: modelData.id > 0
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

                Rectangle {
                    Layout.alignment: Qt.AlignVCenter
                    Layout.leftMargin: 15; Layout.rightMargin: 15
                    width: 1; height: 15; color: zyuTheme.bar_fg; opacity: 0.1
                }

                Text {
                    Layout.alignment: Qt.AlignVCenter
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
