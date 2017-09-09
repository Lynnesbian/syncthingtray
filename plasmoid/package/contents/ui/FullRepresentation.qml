import QtQuick 2.3
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQml 2.2
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import martchus.syncthingplasmoid 0.6 as SyncthingPlasmoid

ColumnLayout {
    id: root
    Layout.minimumWidth: units.gridUnit * 26
    Layout.minimumHeight: units.gridUnit * 34

    Keys.onPressed: {
        // FIXME: currently only works after clicking the tab buttons
        // TODO: add more shortcuts
        switch(event.key) {
        case Qt.Key_Up:
            mainTabGroup.currentTab.item.view.decrementCurrentIndex();
            event.accepted = true;
            break;
        case Qt.Key_Down:
            mainTabGroup.currentTab.item.view.incrementCurrentIndex();
            event.accepted = true;
            break;
        case Qt.Key_Enter:
        case Qt.Key_Return:
            var currentItem = mainTabGroup.currentTab.item.view.currentItem;
            if (currentItem) {
                currentItem.expanded = !currentItem.expanded
            }
            break;
        case Qt.Key_Escape:
            break;
        case Qt.Key_1:
            mainTabGroup.currentTab = dirsPage;
            break;
        case Qt.Key_2:
            mainTabGroup.currentTab = devicesPage;
            break;
        case Qt.Key_3:
            mainTabGroup.currentTab = downloadsPage;
            break;
        default:
            break;
        }
    }

    // heading and right-corner buttons
    RowLayout {
        id: toolBar
        Layout.fillWidth: true

        PlasmaComponents.ToolButton {
            id: connectButton
            states: [
                State {
                    name: "disconnected"
                    PropertyChanges {
                        target: connectButton
                        text: qsTr("Connect")
                        iconSource: "view-refresh"
                    }
                },
                State {
                    name: "paused"
                    PropertyChanges {
                        target: connectButton
                        text: qsTr("Resume")
                        iconSource: "media-playback-start"
                    }
                },
                State {
                    name: "idle"
                    PropertyChanges {
                        target: connectButton
                        text: qsTr("Pause")
                        iconSource: "media-playback-pause"
                    }
                }
            ]
            state: {
                switch(plasmoid.nativeInterface.connection.status) {
                case SyncthingPlasmoid.Data.Disconnected:
                case SyncthingPlasmoid.Data.Reconnecting:
                    return "disconnected";
                case SyncthingPlasmoid.Data.Paused:
                    return "paused";
                default:
                    return "idle";
                }
            }
            tooltip: text
            onClicked: {
                switch(plasmoid.nativeInterface.connection.status) {
                case SyncthingPlasmoid.Data.Disconnected:
                case SyncthingPlasmoid.Data.Reconnecting:
                    plasmoid.nativeInterface.connection.connect();
                    break;
                case SyncthingPlasmoid.Data.Paused:
                    plasmoid.nativeInterface.connection.resumeAllDevs();
                    break;
                default:
                    plasmoid.nativeInterface.connection.pauseAllDevs();
                    break;
                }
            }
        }
        PlasmaComponents.ToolButton {
            id: startStopButton

            states: [
                State {
                    name: "running"
                    PropertyChanges {
                        target: startStopButton
                        visible: true
                        text: qsTr("Stop")
                        tooltip: "systemctl --user stop " + plasmoid.nativeInterface.service.unitName
                        iconSource: "process-stop"
                    }
                },
                State {
                    name: "stopped"
                    PropertyChanges {
                        target: startStopButton
                        visible: true
                        text: qsTr("Start")
                        tooltip: "systemctl --user start " + plasmoid.nativeInterface.service.unitName
                        iconSource: "system-run"
                    }
                },
                State {
                    name: "irrelevant"
                    PropertyChanges {
                        target: startStopButton
                        visible: false
                    }
                }
            ]
            state: {
                // the systemd unit status is only relevant when connected to the local instance
                if(!plasmoid.nativeInterface.local) {
                    return "irrelevant";
                }

                // show start/stop button only when the configured unit is available
                var service = plasmoid.nativeInterface.service;
                if(!service || !service.unitAvailable) {
                    return "irrelevant";
                }

                return service.running ? "running" : "stopped";
            }

            onClicked: plasmoid.nativeInterface.service.toggleRunning()
        }
        Item {
            Layout.fillWidth: true
        }
        PlasmaComponents.ToolButton {
            tooltip: qsTr("Show own device ID")
            iconSource: "view-barcode"
            onClicked: {
                plasmoid.nativeInterface.showOwnDeviceId()
                plasmoid.expanded = false
            }
        }
        PlasmaComponents.ToolButton {
            tooltip: qsTr("Show Syncthing log")
            iconSource: "text-x-generic"
            onClicked: {
                plasmoid.nativeInterface.showLog()
                plasmoid.expanded = false
            }
        }
        PlasmaComponents.ToolButton {
            tooltip: qsTr("Rescan all directories")
            iconSource: "view-refresh"
            onClicked: plasmoid.nativeInterface.connection.rescanAllDirs()
        }
        PlasmaComponents.ToolButton {
            tooltip: qsTr("Settings")
            iconSource: "preferences-other"
            onClicked: {
                plasmoid.nativeInterface.showSettingsDlg()
                plasmoid.expanded = false
            }
        }
        PlasmaComponents.ToolButton {
            tooltip: qsTr("Web UI")
            iconSource: "internet-web-browser"
            onClicked: {
                plasmoid.nativeInterface.showWebUI();
                plasmoid.expanded = false
            }
        }
    }

    PlasmaCore.SvgItem {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 2
        elementId: "horizontal-line"
        svg: PlasmaCore.Svg {
            imagePath: "widgets/line"
        }
    }

    // traffic and connection selection
    RowLayout {
        Layout.fillWidth: true
        Layout.fillHeight: false

        PlasmaCore.IconItem {
            source: "network-card"
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
        }
        ColumnLayout {
            Layout.fillHeight: true
            spacing: 1

            PlasmaComponents.Label {
                text: qsTr("In")
            }
            PlasmaComponents.Label {
                text: qsTr("Out")
            }
        }
        ColumnLayout {
            Layout.fillHeight: true
            spacing: 1

            PlasmaComponents.Label {
                text: plasmoid.nativeInterface.incomingTraffic;
            }
            PlasmaComponents.Label {
                text: plasmoid.nativeInterface.outgoingTraffic;
            }
        }
        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
        ToolButton {
            text: plasmoid.nativeInterface.currentConnectionConfigName
            // FIXME: iconSource doesn't work
            iconSource: "network-connect"
            // FIXME: figure out why menu doesn't work in plasmoidviewer using NVIDIA driver
            // (works with plasmawindowed or Intel graphics)
            menu: Menu {
                id: connectionConfigsMenu

                ExclusiveGroup {
                    id: connectionConfigsExclusiveGroup
                }

                Instantiator {
                    model: plasmoid.nativeInterface.connectionConfigNames

                    MenuItem {
                        text: model.modelData
                        checkable: true
                        checked: plasmoid.nativeInterface.currentConnectionConfigIndex === index
                        exclusiveGroup: connectionConfigsExclusiveGroup
                        onTriggered: {
                            plasmoid.nativeInterface.currentConnectionConfigIndex = index;
                        }
                    }
                    onObjectAdded: connectionConfigsMenu.insertItem(index, object)
                    onObjectRemoved: connectionConfigsMenu.removeItem(object)
                }
            }
        }
    }

    PlasmaCore.SvgItem {
        Layout.preferredWidth: parent.width
        Layout.preferredHeight: 2
        elementId: "horizontal-line"
        svg: PlasmaCore.Svg {
            imagePath: "widgets/line"
        }
    }

    // tab "widget"
    RowLayout {
        spacing: 0

        PlasmaComponents.TabBar {
            id: tabBar
            tabPosition: Qt.LeftEdge
            anchors.top: parent.top

            PlasmaComponents.TabButton {
                //text: qsTr("Directories")
                iconSource: "folder-symbolic"
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                tab: dirsPage
            }
            PlasmaComponents.TabButton {
                //text: qsTr("Devices")
                iconSource: "network-server-symbolic"
                tab: devicesPage
            }
            PlasmaComponents.TabButton {
                //text: qsTr("Downloads")
                iconSource: "folder-download-symbolic"
                tab: downloadsPage
            }
        }
        PlasmaCore.SvgItem {
            Layout.preferredWidth: 2
            Layout.fillHeight: true
            elementId: "vertical-line"
            svg: PlasmaCore.Svg {
                imagePath: "widgets/line"
            }
        }
        PlasmaComponents.TabGroup {
            id: mainTabGroup
            currentTab: dirsPage
            Layout.fillWidth: true
            Layout.fillHeight: true

            PlasmaExtras.ConditionalLoader {
                id: dirsPage
                when: mainTabGroup.currentTab == dirsPage
                source: Qt.resolvedUrl("DirectoriesPage.qml")
            }
            PlasmaExtras.ConditionalLoader {
                id: devicesPage
                when: mainTabGroup.currentTab == devicesPage
                source: Qt.resolvedUrl("DevicesPage.qml")
            }
            PlasmaExtras.ConditionalLoader {
                id: downloadsPage
                when: mainTabGroup.currentTab == downloadsPage
                source: Qt.resolvedUrl("DownloadsPage.qml")
            }
        }
    }
}