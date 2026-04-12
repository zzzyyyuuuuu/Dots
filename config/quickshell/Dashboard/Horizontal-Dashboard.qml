import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

PanelWindow {
    id: dashboard
    visible: true
    exclusionMode: ExclusionMode.Ignore
    anchors { top: true; bottom: true; right: true }

    property bool showDashboard: false

    margins {
        top: 70
        bottom: 10
        right: showDashboard ? 6 : -300
    }
    implicitWidth: 300
    color: "transparent"
    focusable: true
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: showDashboard ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    Behavior on margins.right { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

    NotificationServer {
        id: notifServer
        keepOnReload: true
    }

    property color bg:      "#151218"
    property color fg:      "#e7e0e8"
    property color accent:  "#d5bbfc"
    property color col1:    "#cc8f6f"
    property color col2:    "#7aab8a"
    property color col3:    "#7f9fbd"
    property color muted:   "#6b6760"
    property color surface: "#211e24"

    readonly property string fontFam:    "JetBrainsMono Nerd Font"
    readonly property string configPath: Quickshell.env("HOME") + "/.config/quickshell"
    readonly property string ppDir:      configPath + "/user/pp/"

    property int batVal:    100
    property int volVal:    50
    property int brightVal: 100
    property int cpuVal:    0
    property int ramVal:    0
    property int diskVal:   0
    property string netName: "..."
    property bool netUp:     false
    property string btName:  "..."
    property bool btOn:      false
    property var ppFiles:    []
    property bool ppPickerOpen: false
    property string ppActualPath: ""

    Process {
        id: colorProc
        command: ["bash", "-c", "cat " + dashboard.configPath + "/Colors/colors.json"]
        stdout: SplitParser {
            splitMarker: ""
            onRead: data => {
                try {
                    var c = JSON.parse(data)
                    if (c.background)         dashboard.bg      = c.background
                    if (c.on_surface)         dashboard.fg      = c.on_surface
                    if (c.primary)            dashboard.accent  = c.primary
                    if (c.tertiary)           dashboard.col1    = c.tertiary
                    if (c.secondary)          dashboard.col2    = c.secondary
                    if (c.primary_fixed_dim)  dashboard.col3    = c.primary_fixed_dim
                    if (c.on_surface_variant) dashboard.muted   = c.on_surface_variant
                    if (c.surface_container)  dashboard.surface = c.surface_container
                } catch(e) {}
            }
        }
        Component.onCompleted: running = true
    }

    Connections {
        target: dashboardState
        function onShowChanged() {
            dashboard.showDashboard = dashboardState.show
            if (dashboardState.show) focusTimer.start()
        }
    }

    Component.onCompleted: {
        ppFindProc.running = true
        batProc.running = true
        batStatusProc.running = true
        volProc.running = true
        brightProc.running = true
        netProc.running = true
        btProc.running = true
    }

    Process {
        id: ppFindProc
        command: ["bash", "-c", "ls -t " + dashboard.ppDir + "*.jpg " + dashboard.ppDir + "*.png " + dashboard.ppDir + "*.gif 2>/dev/null | head -1"]
        stdout: SplitParser {
            onRead: data => {
                var f = data.trim()
                if (f.length > 0) dashboard.ppActualPath = f
            }
        }
    }

    Timer {
        id: focusTimer
        interval: 50; repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.Exclusive
            focusItem.forceActiveFocus()
            releaseTimer.start()
        }
    }

    Timer {
        id: releaseTimer
        interval: 100; repeat: false
        onTriggered: {
            dashboard.WlrLayershell.keyboardFocus = WlrKeyboardFocus.OnDemand
        }
    }

    Item {
        id: focusItem
        anchors.fill: parent
        focus: showDashboard
        onFocusChanged: if (focus) forceActiveFocus()

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape) {
                if (dashboard.ppPickerOpen) dashboard.ppPickerOpen = false
                else {
                    dashboardState.show = false
                    dashboard.showDashboard = false
                }
                event.accepted = true
            } else if (event.key === Qt.Key_M) {
                dashboard.ppPickerOpen = !dashboard.ppPickerOpen
                if (dashboard.ppPickerOpen) {
                    dashboard.ppFiles = []
                    ppListProc.running = true
                }
                event.accepted = true
            }
        }

        Rectangle {
            anchors.fill: parent
            color: dashboard.bg
            radius: 16
            Behavior on color { ColorAnimation { duration: 300 } }

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: dashboard.ppPickerOpen ? 180 : 70
                    color: dashboard.surface
                    radius: 12
                    Behavior on color { ColorAnimation { duration: 300 } }
                    Behavior on Layout.preferredHeight { NumberAnimation { duration: 200 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Item {
                                width: 48; height: 48

                                Image {
                                    id: pfpImage
                                    anchors.centerIn: parent
                                    width: 48; height: 48
                                    source: dashboard.ppActualPath !== "" ? "file://" + dashboard.ppActualPath : ""
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    cache: false
                                    sourceSize.width: 128; sourceSize.height: 128
                                    visible: false
                                }
                                Rectangle {
                                    id: pfpMask
                                    anchors.centerIn: parent
                                    width: 48; height: 48
                                    radius: 24
                                    visible: false
                                }
                                OpacityMask {
                                    anchors.centerIn: parent
                                    width: 48; height: 48
                                    source: pfpImage
                                    maskSource: pfpMask
                                    visible: pfpImage.status === Image.Ready
                                }
                                Rectangle {
                                    anchors.fill: parent; radius: 24
                                    color: "transparent"
                                    border.width: 2; border.color: dashboard.accent
                                    z: 1
                                    Behavior on border.color { ColorAnimation { duration: 300 } }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: Quickshell.env("USER").charAt(0).toUpperCase()
                                    color: dashboard.accent
                                    font.pixelSize: 20; font.bold: true
                                    font.family: dashboard.fontFam
                                    visible: pfpImage.status !== Image.Ready
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        dashboard.ppPickerOpen = !dashboard.ppPickerOpen
                                        if (dashboard.ppPickerOpen) {
                                            dashboard.ppFiles = []
                                            ppListProc.running = true
                                        }
                                    }
                                }
                            }

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2
                                Text {
                                    text: Quickshell.env("USER")
                                    color: dashboard.accent
                                    font.pixelSize: 16; font.bold: true
                                    font.family: dashboard.fontFam
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                                Text {
                                    id: uptimeText
                                    text: "up ..."
                                    color: dashboard.muted
                                    font.pixelSize: 10
                                    font.family: dashboard.fontFam
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 100
                            color: Qt.rgba(0, 0, 0, 0.2)
                            radius: 8
                            visible: dashboard.ppPickerOpen
                            clip: true

                            Flickable {
                                anchors.fill: parent
                                anchors.margins: 5
                                contentWidth: width
                                contentHeight: ppGrid.height
                                clip: true

                                GridLayout {
                                    id: ppGrid
                                    width: parent.width
                                    columns: 5
                                    rowSpacing: 5; columnSpacing: 5

                                    Repeater {
                                        model: dashboard.ppFiles
                                        Item {
                                            width: 40; height: 40

                                            Image {
                                                id: thumbImg
                                                anchors.centerIn: parent
                                                width: 40; height: 40
                                                source: "file://" + modelData
                                                fillMode: Image.PreserveAspectCrop
                                                smooth: true
                                                cache: false
                                                sourceSize.width: 80; sourceSize.height: 80
                                                visible: false
                                            }
                                            Rectangle {
                                                id: thumbMask
                                                anchors.centerIn: parent
                                                width: 40; height: 40
                                                radius: 20
                                                visible: false
                                            }
                                            OpacityMask {
                                                anchors.centerIn: parent
                                                width: 40; height: 40
                                                source: thumbImg
                                                maskSource: thumbMask
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: {
                                                    dashboard.ppActualPath = modelData
                                                    dashboard.ppPickerOpen = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            Process {
                                id: ppListProc
                                command: ["bash", "-c", "find " + dashboard.ppDir + " -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.gif' \\) | sort"]
                                stdout: SplitParser {
                                    onRead: data => {
                                        var f = data.trim()
                                        if (f.length > 0) {
                                            var arr = dashboard.ppFiles.slice()
                                            arr.push(f)
                                            dashboard.ppFiles = arr
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60
                    color: dashboard.surface
                    radius: 12
                    Behavior on color { ColorAnimation { duration: 300 } }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        Text {
                            id: batIcon
                            text: "󰁹"
                            color: dashboard.col2
                            font.pixelSize: 24
                            font.family: dashboard.fontFam
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2
                            Text {
                                text: dashboard.batVal + "%"
                                color: dashboard.fg
                                font.pixelSize: 14
                                font.family: dashboard.fontFam
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            Text {
                                id: batStatus
                                text: "Checking..."
                                color: dashboard.muted
                                font.pixelSize: 9
                                font.family: dashboard.fontFam
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    Rectangle {
                        id: wifiCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: wifiOpen ? 200 : 56
                        color: dashboard.surface
                        radius: 12
                        clip: true
                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 300 } }

                        property bool wifiOpen: false
                        property var wifiNetworks: []

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: dashboard.netUp ? "󰤨" : "󰤭"
                                    color: dashboard.netUp ? dashboard.col2 : dashboard.muted
                                    font.pixelSize: 18
                                    font.family: dashboard.fontFam
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: dashboard.netUp ? dashboard.netName : "Offline"
                                        color: dashboard.fg
                                        font.pixelSize: 11; font.bold: true
                                        font.family: dashboard.fontFam
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                    Text {
                                        text: "Network"
                                        color: dashboard.muted
                                        font.pixelSize: 9
                                        font.family: dashboard.fontFam
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wifiCard.wifiOpen = !wifiCard.wifiOpen
                                        if (wifiCard.wifiOpen) {
                                            wifiCard.wifiNetworks = []
                                            wifiScanProc.running = true
                                        }
                                    }
                                }
                            }

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: wifiCol.implicitHeight
                                clip: true
                                visible: wifiCard.wifiOpen

                                Column {
                                    id: wifiCol
                                    width: parent.width
                                    spacing: 4

                                    Text {
                                        text: "Available Networks"
                                        color: dashboard.accent
                                        font.pixelSize: 10; font.bold: true
                                        font.family: dashboard.fontFam
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }

                                    Repeater {
                                        model: wifiCard.wifiNetworks
                                        Rectangle {
                                            width: wifiCol.width
                                            height: 38
                                            radius: 8
                                            color: wifiMa.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 4
                                                anchors.rightMargin: 4
                                                spacing: 8

                                                Text {
                                                    text: "󰤨"
                                                    color: modelData.connected ? dashboard.accent : dashboard.muted
                                                    font.pixelSize: 14
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                                ColumnLayout {
                                                    Layout.fillWidth: true
                                                    spacing: 1
                                                    Text {
                                                        text: modelData.ssid
                                                        color: modelData.connected ? dashboard.accent : dashboard.fg
                                                        font.pixelSize: 11
                                                        font.bold: modelData.connected
                                                        font.family: dashboard.fontFam
                                                        elide: Text.ElideRight
                                                        Layout.fillWidth: true
                                                        Behavior on color { ColorAnimation { duration: 300 } }
                                                    }
                                                    Text {
                                                        text: modelData.security
                                                        color: dashboard.muted
                                                        font.pixelSize: 9
                                                        font.family: dashboard.fontFam
                                                    }
                                                }
                                                Text {
                                                    visible: modelData.connected
                                                    text: "Connected"
                                                    color: dashboard.accent
                                                    font.pixelSize: 9
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                            }

                                            MouseArea {
                                                id: wifiMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    wifiConnectProc.command = ["bash", "-c", "nmcli dev wifi connect '" + modelData.ssid + "'"]
                                                    wifiConnectProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Process {
                            id: wifiScanProc
                            command: ["bash", "-c", "nmcli -t -f active,ssid,security dev wifi list 2>/dev/null"]
                            stdout: SplitParser {
                                onRead: data => {
                                    var line = data.trim()
                                    if (line.length === 0) return
                                    var parts = line.split(":")
                                    if (parts.length < 2) return
                                    var connected = parts[0] === "yes"
                                    var ssid = parts[1]
                                    var security = parts[2] || "Open"
                                    if (ssid.length === 0) return
                                    var arr = wifiCard.wifiNetworks.slice()
                                    arr.push({ ssid: ssid, connected: connected, security: security })
                                    wifiCard.wifiNetworks = arr
                                }
                            }
                        }
                        Process { id: wifiConnectProc; onExited: netProc.running = true }
                    }

                    Rectangle {
                        id: btCard
                        Layout.fillWidth: true
                        Layout.preferredHeight: btOpen ? 200 : 56
                        color: dashboard.surface
                        radius: 12
                        clip: true
                        Behavior on Layout.preferredHeight { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                        Behavior on color { ColorAnimation { duration: 300 } }

                        property bool btOpen: false
                        property var btDevices: []

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 6

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Text {
                                    text: dashboard.btOn ? "󰂯" : "󰂲"
                                    color: dashboard.btOn ? dashboard.col3 : dashboard.muted
                                    font.pixelSize: 18
                                    font.family: dashboard.fontFam
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Text {
                                        text: dashboard.btOn ? dashboard.btName : "Off"
                                        color: dashboard.fg
                                        font.pixelSize: 11; font.bold: true
                                        font.family: dashboard.fontFam
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                    Text {
                                        text: "Bluetooth"
                                        color: dashboard.muted
                                        font.pixelSize: 9
                                        font.family: dashboard.fontFam
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        btCard.btOpen = !btCard.btOpen
                                        if (btCard.btOpen) {
                                            btCard.btDevices = []
                                            btScanProc.running = true
                                        }
                                        if (!dashboard.btOn) {
                                            btToggleProc.running = true
                                        }
                                    }
                                }
                            }

                            Flickable {
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                contentWidth: width
                                contentHeight: btCol.implicitHeight
                                clip: true
                                visible: btCard.btOpen

                                Column {
                                    id: btCol
                                    width: parent.width
                                    spacing: 4

                                    Text {
                                        text: "Devices"
                                        color: dashboard.accent
                                        font.pixelSize: 10; font.bold: true
                                        font.family: dashboard.fontFam
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }

                                    Repeater {
                                        model: btCard.btDevices
                                        Rectangle {
                                            width: btCol.width
                                            height: 38
                                            radius: 8
                                            color: btDevMa.containsMouse ? Qt.rgba(1,1,1,0.06) : "transparent"

                                            RowLayout {
                                                anchors.fill: parent
                                                anchors.leftMargin: 4
                                                anchors.rightMargin: 4
                                                spacing: 8

                                                Text {
                                                    text: "󰂯"
                                                    color: modelData.connected ? dashboard.col3 : dashboard.muted
                                                    font.pixelSize: 14
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                                Text {
                                                    text: modelData.name
                                                    color: modelData.connected ? dashboard.col3 : dashboard.fg
                                                    font.pixelSize: 11
                                                    font.bold: modelData.connected
                                                    font.family: dashboard.fontFam
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                                Text {
                                                    visible: modelData.connected
                                                    text: "Connected"
                                                    color: dashboard.col3
                                                    font.pixelSize: 9
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                            }

                                            MouseArea {
                                                id: btDevMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    var cmd = modelData.connected
                                                        ? "bluetoothctl disconnect " + modelData.mac
                                                        : "bluetoothctl connect " + modelData.mac
                                                    btConnectProc.command = ["bash", "-c", cmd]
                                                    btConnectProc.running = true
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Process {
                            id: btScanProc
                            command: ["bash", "-c", "bluetoothctl devices | while read _ mac name; do connected=$(bluetoothctl info $mac | grep 'Connected: yes'); echo \"$mac|$name|$([ -n \\\"$connected\\\" ] && echo yes || echo no)\"; done"]
                            stdout: SplitParser {
                                onRead: data => {
                                    var line = data.trim()
                                    if (line.length === 0) return
                                    var parts = line.split("|")
                                    if (parts.length < 3) return
                                    var arr = btCard.btDevices.slice()
                                    arr.push({ mac: parts[0], name: parts[1], connected: parts[2] === "yes" })
                                    btCard.btDevices = arr
                                }
                            }
                        }
                        Process { id: btConnectProc; onExited: btProc.running = true }
                        Process {
                            id: btToggleProc
                            command: ["bash", "-c", dashboard.btOn ? "bluetoothctl power off" : "bluetoothctl power on"]
                            onExited: btProc.running = true
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    color: dashboard.surface
                    radius: 12
                    Behavior on color { ColorAnimation { duration: 300 } }

                    Rectangle {
                        anchors.centerIn: parent
                        width: 40; height: 34; radius: 8
                        color: powerMa.containsMouse
                            ? Qt.rgba(dashboard.col1.r, dashboard.col1.g, dashboard.col1.b, 0.2)
                            : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: "⏻"
                            color: dashboard.col1
                            font.pixelSize: 20
                            font.family: dashboard.fontFam
                            Behavior on color { ColorAnimation { duration: 300 } }
                        }
                        MouseArea {
                            id: powerMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: wlogoutProc.running = true
                        }
                        Process { id: wlogoutProc; command: ["bash", "-c", "wlogout -b 5"] }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 110
                    color: dashboard.surface
                    radius: 12
                    Behavior on color { ColorAnimation { duration: 300 } }

                    Row {
                        anchors.centerIn: parent
                        spacing: 8

                        Repeater {
                            model: [
                                { label: "CPU",  icon: "", value: dashboard.cpuVal,  color: dashboard.col1 },
                                { label: "RAM",  icon: "", value: dashboard.ramVal,  color: dashboard.accent },
                                { label: "DISK", icon: "", value: dashboard.diskVal, color: dashboard.col3 }
                            ]
                            Item {
                                width: 68; height: 95

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 6

                                    Item {
                                        width: 56; height: 56
                                        anchors.horizontalCenter: parent.horizontalCenter

                                        Canvas {
                                            anchors.fill: parent
                                            property int val: modelData.value
                                            property color col: modelData.color
                                            onValChanged: requestPaint()
                                            onColChanged: requestPaint()
                                            onPaint: {
                                                var ctx = getContext("2d")
                                                ctx.clearRect(0, 0, width, height)
                                                ctx.lineWidth = 4; ctx.lineCap = "round"
                                                ctx.strokeStyle = Qt.rgba(1, 1, 1, 0.08)
                                                ctx.beginPath(); ctx.arc(28, 28, 24, 0, 2 * Math.PI); ctx.stroke()
                                                ctx.strokeStyle = col
                                                ctx.beginPath()
                                                ctx.arc(28, 28, 24, -Math.PI/2, -Math.PI/2 + (val/100) * 2 * Math.PI)
                                                ctx.stroke()
                                            }
                                        }

                                        Column {
                                            anchors.centerIn: parent
                                            spacing: 1
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: modelData.icon
                                                color: modelData.color
                                                font.pixelSize: 11
                                                font.family: dashboard.fontFam
                                                Behavior on color { ColorAnimation { duration: 300 } }
                                            }
                                            Text {
                                                anchors.horizontalCenter: parent.horizontalCenter
                                                text: modelData.value + "%"
                                                color: dashboard.fg
                                                font.pixelSize: 10
                                                font.family: dashboard.fontFam
                                                Behavior on color { ColorAnimation { duration: 300 } }
                                            }
                                        }
                                    }

                                    Text {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        text: modelData.label
                                        color: dashboard.muted
                                        font.pixelSize: 9
                                        font.family: dashboard.fontFam
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 90
                    color: dashboard.surface
                    radius: 12
                    Behavior on color { ColorAnimation { duration: 300 } }

                    Column {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        Row {
                            width: parent.width; spacing: 8
                            Text {
                                width: 20; height: 20
                                text: dashboard.volVal == 0 ? "󰝟" : dashboard.volVal < 50 ? "󰖀" : "󰕾"
                                color: dashboard.col3; font.pixelSize: 15; font.family: dashboard.fontFam
                                verticalAlignment: Text.AlignVCenter
                                Behavior on color { ColorAnimation { duration: 300 } }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: volMuteProc.running = true
                                }
                                Process {
                                    id: volMuteProc
                                    command: ["bash", "-c", "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"]
                                    onExited: volProc.running = true
                                }
                            }
                            Rectangle {
                                width: parent.width - 52; height: 6
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3; color: Qt.rgba(1,1,1,0.1)
                                Rectangle {
                                    width: parent.width * dashboard.volVal / 100
                                    height: parent.height; radius: 3; color: dashboard.col3
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        var p = Math.max(0, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                        dashboard.volVal = p
                                        volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (p/100).toFixed(2)]
                                        volSetProc.running = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var p = Math.max(0, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                            dashboard.volVal = p
                                            volSetProc.command = ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ " + (p/100).toFixed(2)]
                                            volSetProc.running = true
                                        }
                                    }
                                }
                                Process { id: volSetProc }
                            }
                            Text {
                                width: 24; height: 20; text: dashboard.volVal + "%"
                                color: dashboard.muted; font.pixelSize: 9; font.family: dashboard.fontFam
                                horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }

                        Row {
                            width: parent.width; spacing: 8
                            Text {
                                width: 20; height: 20
                                text: dashboard.brightVal < 30 ? "󰃞" : dashboard.brightVal < 70 ? "󰃟" : "󰃠"
                                color: dashboard.col1; font.pixelSize: 15; font.family: dashboard.fontFam
                                verticalAlignment: Text.AlignVCenter
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            Rectangle {
                                width: parent.width - 52; height: 6
                                anchors.verticalCenter: parent.verticalCenter
                                radius: 3; color: Qt.rgba(1,1,1,0.1)
                                Rectangle {
                                    width: parent.width * dashboard.brightVal / 100
                                    height: parent.height; radius: 3; color: dashboard.col1
                                    Behavior on width { NumberAnimation { duration: 100 } }
                                    Behavior on color { ColorAnimation { duration: 300 } }
                                }
                                MouseArea {
                                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                    onClicked: function(mouse) {
                                        var p = Math.max(1, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                        dashboard.brightVal = p
                                        brightSetProc.command = ["bash", "-c", "brightnessctl set " + p + "%"]
                                        brightSetProc.running = true
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (pressed) {
                                            var p = Math.max(1, Math.min(100, Math.round((mouse.x / parent.width) * 100)))
                                            dashboard.brightVal = p
                                            brightSetProc.command = ["bash", "-c", "brightnessctl set " + p + "%"]
                                            brightSetProc.running = true
                                        }
                                    }
                                }
                                Process { id: brightSetProc }
                            }
                            Text {
                                width: 24; height: 20; text: dashboard.brightVal + "%"
                                color: dashboard.muted; font.pixelSize: 9; font.family: dashboard.fontFam
                                horizontalAlignment: Text.AlignRight; verticalAlignment: Text.AlignVCenter
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: dashboard.surface
                    radius: 12
                    Behavior on color { ColorAnimation { duration: 300 } }

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 6

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                text: "󰂚  Notifications"
                                color: dashboard.accent
                                font.pixelSize: 11; font.bold: true
                                font.family: dashboard.fontFam
                                Behavior on color { ColorAnimation { duration: 300 } }
                            }
                            Item { Layout.fillWidth: true }
                            Rectangle {
                                width: 24; height: 24; radius: 6
                                visible: notifServer.notifications.length > 0
                                color: clearMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                Text {
                                    anchors.centerIn: parent
                                    text: "󰆴"
                                    color: dashboard.muted
                                    font.pixelSize: 12
                                    font.family: dashboard.fontFam
                                }
                                MouseArea {
                                    id: clearMa
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onClicked: {
                                        var list = notifServer.notifications.slice()
                                        for (var i = 0; i < list.length; i++) list[i].dismiss()
                                    }
                                }
                            }
                        }

                        Flickable {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            contentWidth: width
                            contentHeight: notifCol.implicitHeight
                            clip: true

                            Column {
                                id: notifCol
                                width: parent.width
                                spacing: 4

                                Repeater {
                                    model: notifServer.notifications
                                    Rectangle {
                                        width: notifCol.width
                                        height: notifRow.implicitHeight + 12
                                        radius: 8
                                        color: Qt.rgba(1, 1, 1, 0.04)

                                        RowLayout {
                                            id: notifRow
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 8

                                            Rectangle {
                                                width: 28; height: 28; radius: 6
                                                color: dashboard.surface
                                                Behavior on color { ColorAnimation { duration: 300 } }
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: (modelData.appName || "?").charAt(0).toUpperCase()
                                                    color: dashboard.accent
                                                    font.pixelSize: 12; font.bold: true
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                            }

                                            ColumnLayout {
                                                Layout.fillWidth: true
                                                spacing: 2
                                                Text {
                                                    text: modelData.summary || modelData.appName || "Notification"
                                                    color: dashboard.fg
                                                    font.pixelSize: 10; font.bold: true
                                                    elide: Text.ElideRight
                                                    Layout.fillWidth: true
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                                Text {
                                                    text: modelData.body || ""
                                                    color: dashboard.muted
                                                    font.pixelSize: 9
                                                    wrapMode: Text.WordWrap
                                                    Layout.fillWidth: true
                                                    visible: (modelData.body || "") !== ""
                                                    font.family: dashboard.fontFam
                                                    Behavior on color { ColorAnimation { duration: 300 } }
                                                }
                                            }

                                            Rectangle {
                                                width: 18; height: 18; radius: 4
                                                color: closeMa.containsMouse ? Qt.rgba(1,1,1,0.1) : "transparent"
                                                Text {
                                                    anchors.centerIn: parent
                                                    text: "✕"
                                                    color: dashboard.muted
                                                    font.pixelSize: 9
                                                    font.family: dashboard.fontFam
                                                }
                                                MouseArea {
                                                    id: closeMa
                                                    anchors.fill: parent
                                                    onClicked: modelData.dismiss()
                                                }
                                            }
                                        }
                                    }
                                }

                                Item {
                                    width: notifCol.width
                                    height: 40
                                    visible: notifServer.notifications.length === 0
                                    Text {
                                        anchors.centerIn: parent
                                        text: "No notifications 󰂛"
                                        color: dashboard.muted
                                        font.pixelSize: 10
                                        font.family: dashboard.fontFam
                                        Behavior on color { ColorAnimation { duration: 300 } }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Timer {
        interval: 2000; running: showDashboard; repeat: true
        onTriggered: {
            if (!batProc.running)       batProc.running = true
            if (!batStatusProc.running) batStatusProc.running = true
            if (!volProc.running)       volProc.running = true
            if (!brightProc.running)    brightProc.running = true
            if (!uptimeProc.running)    uptimeProc.running = true
            if (!cpuProc.running)       cpuProc.running = true
            if (!ramProc.running)       ramProc.running = true
            if (!diskProc.running)      diskProc.running = true
            if (!netProc.running)       netProc.running = true
            if (!btProc.running)        btProc.running = true
        }
    }

    Process {
        id: netProc
        command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 || nmcli -t -f active,connection dev | grep '^yes' | cut -d: -f2 | head -1"]
        stdout: SplitParser {
            onRead: data => {
                var n = data.trim()
                if (n.length > 0) { dashboard.netName = n; dashboard.netUp = true }
                else { dashboard.netName = "Offline"; dashboard.netUp = false }
            }
        }
    }
    Process {
        id: btProc
        command: ["bash", "-c", "bluetoothctl show | grep 'Powered:' | awk '{print $2}'"]
        stdout: SplitParser {
            onRead: data => {
                var s = data.trim()
                dashboard.btOn = (s === "yes")
                if (dashboard.btOn) btNameProc.running = true
                else dashboard.btName = "Off"
            }
        }
    }
    Process {
        id: btNameProc
        command: ["bash", "-c", "bluetoothctl devices Connected | head -1 | cut -d' ' -f3-"]
        stdout: SplitParser {
            onRead: data => {
                var n = data.trim()
                dashboard.btName = n.length > 0 ? n : "On"
            }
        }
    }
    Process {
        id: cpuProc
        command: ["bash", "-c", "top -bn1 | grep 'Cpu(s)' | awk '{print int($2 + $4)}'"]
        stdout: SplitParser { onRead: data => dashboard.cpuVal = parseInt(data) || 0 }
    }
    Process {
        id: ramProc
        command: ["bash", "-c", "free | awk '/Mem:/ {printf \"%.0f\", $3/$2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.ramVal = parseInt(data) || 0 }
    }
    Process {
        id: diskProc
        command: ["bash", "-c", "df / | awk 'NR==2 {gsub(/%/,\"\"); print $5}'"]
        stdout: SplitParser { onRead: data => dashboard.diskVal = parseInt(data) || 0 }
    }
    Process {
        id: batProc
        command: ["bash", "-c", "if [ -f /sys/class/power_supply/BAT0/capacity ]; then cat /sys/class/power_supply/BAT0/capacity; elif [ -f /sys/class/power_supply/BAT1/capacity ]; then cat /sys/class/power_supply/BAT1/capacity; else echo 100; fi"]
        stdout: SplitParser {
            onRead: data => {
                dashboard.batVal = parseInt(data) || 100
                var cap = dashboard.batVal
                if      (cap >= 90) batIcon.text = "󰁹"
                else if (cap >= 70) batIcon.text = "󰂁"
                else if (cap >= 50) batIcon.text = "󰁿"
                else if (cap >= 30) batIcon.text = "󰁽"
                else                batIcon.text = "󰁺"
            }
        }
    }
    Process {
        id: batStatusProc
        command: ["bash", "-c", "if [ -f /sys/class/power_supply/BAT0/status ]; then cat /sys/class/power_supply/BAT0/status; elif [ -f /sys/class/power_supply/BAT1/status ]; then cat /sys/class/power_supply/BAT1/status; else echo Unknown; fi"]
        stdout: SplitParser {
            onRead: data => {
                var s = data.trim()
                if      (s === "Charging")    { batStatus.text = "Charging..."; batIcon.text = "󰂄" }
                else if (s === "Full")           batStatus.text = "Fully charged"
                else if (s === "Discharging")    batStatus.text = "On battery"
                else                             batStatus.text = "Unknown"
            }
        }
    }
    Process {
        id: volProc
        command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f\", $2*100}'"]
        stdout: SplitParser { onRead: data => dashboard.volVal = parseInt(data) || 0 }
    }
    Process {
        id: brightProc
        command: ["bash", "-c", "brightnessctl -m | awk -F, '{gsub(/%/,\"\"); print $4}'"]
        stdout: SplitParser { onRead: data => dashboard.brightVal = parseInt(data) || 100 }
    }
    Process {
        id: uptimeProc
        command: ["bash", "-c", "uptime -p | sed 's/up //'"]
        stdout: SplitParser { onRead: data => uptimeText.text = data.trim() }
    }
}
