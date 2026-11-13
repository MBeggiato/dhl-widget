import QtQuick
import "../code/api.js" as Api

QtObject {
    id: root
    property string stationId: ""
    property string nickname: ""
    readonly property bool configured: stationId.trim() !== ""
    property var snapshot: null
    property bool loading: false
    property string error: ""
    property date fetchedAt: new Date(0)
    property date now: new Date()
    readonly property bool stale: snapshot !== null && (error !== "" || !snapshot.sourceTimestamp || now.getTime() - snapshot.sourceTimestamp.getTime() > 15 * 60 * 1000)
    property var request: null
    property int generation: 0
    property bool ready: false

    property Timer refreshTimer: Timer {
        interval: 5 * 60 * 1000
        running: root.ready
        repeat: true
        onTriggered: root.refresh()
    }
    property Timer clock: Timer {
        interval: 30000
        running: root.ready
        repeat: true
        onTriggered: root.now = new Date()
    }
    property Timer deadline: Timer {
        interval: 20000
        onTriggered: {
            root.generation++
            if (root.request) root.request.abort()
            root.request = null
            root.loading = false
            root.error = "Zeitüberschreitung. Verbindung prüfen und erneut aktualisieren."
        }
    }

    function cancel() {
        generation++
        deadline.stop()
        if (request) request.abort()
        request = null
        loading = false
    }

    function refresh() {
        if (loading || !configured) return
        var url
        try { url = Api.endpoint(stationId) }
        catch (e) { error = e.message; return }
        loading = true
        var token = ++generation
        var xhr = new XMLHttpRequest()
        request = xhr
        xhr.onreadystatechange = function() {
            if (token !== root.generation || xhr.readyState !== XMLHttpRequest.DONE) return
            root.deadline.stop()
            root.request = null
            root.loading = false
            if (xhr.status !== 200) {
                root.error = xhr.status === 0
                    ? "DHL nicht erreichbar. Internetverbindung prüfen."
                    : "DHL-Anfrage fehlgeschlagen (HTTP " + xhr.status + "). Später erneut versuchen."
                return
            }
            try {
                const result = Api.parseResponse(JSON.parse(xhr.responseText))
                root.snapshot = result
                root.fetchedAt = new Date()
                root.now = new Date()
                root.error = ""
            } catch (e) { root.error = e.message }
        }
        try {
            xhr.open("GET", url)
            deadline.start()
            xhr.send()
        } catch (e) {
            cancel()
            error = "DHL-Anfrage konnte nicht gestartet werden. Verbindung prüfen."
        }
    }

    onStationIdChanged: {
        if (!ready) return
        cancel()
        snapshot = null
        fetchedAt = new Date(0)
        error = ""
        refreshTimer.restart()
        refresh()
    }
    Component.onCompleted: { ready = true; refresh() }
    Component.onDestruction: cancel()
}
