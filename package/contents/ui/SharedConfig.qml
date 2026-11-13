import QtQuick
import Qt.labs.settings as Storage
import QtCore as Core

// One user-wide settings file; local KConfig remains the editor interface.
QtObject {
    id: root
    required property var localConfig
    property bool applying: false
    property bool ready: false
    readonly property var keys: ["stationId", "stationName", "stationId2", "stationName2", "stationId3", "stationName3", "favoriteStation"]
    property Storage.Settings store: Storage.Settings {
        fileName: Core.StandardPaths.writableLocation(Core.StandardPaths.ConfigLocation) + "/packstation-widget.ini"
        category: "Packstation"
    }
    function localValues() {
        const values = {}
        for (const key of keys) values[key] = localConfig[key]
        return values
    }
    function applyShared() {
        const serialized = store.value("stationsJson", "")
        if (!serialized) return
        try {
            const values = JSON.parse(serialized)
            applying = true
            for (const key of keys) {
                if (values[key] !== undefined && localConfig[key] !== values[key]) localConfig[key] = values[key]
            }
            applying = false
        } catch (e) { applying = false; console.warn("Packstation: gemeinsame Einstellungen ungültig", e) }
    }
    function publish() {
        if (!ready || applying) return
        store.setValue("stationsJson", JSON.stringify(localValues()))
        store.sync()
    }
    property Connections changes: Connections {
        target: root.localConfig
        function onValueChanged(key, value) {
            if (root.keys.indexOf(key) !== -1) root.publish()
        }
    }
    property Timer poll: Timer {
        interval: 1000
        running: root.ready
        repeat: true
        onTriggered: { root.store.sync(); root.applyShared() }
    }
    Component.onCompleted: {
        store.sync()
        const existing = store.value("stationsJson", "")
        if (existing) applyShared()
        ready = true
        if (!existing) publish()
    }
}
