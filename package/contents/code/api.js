// Pure JavaScript shared by QML and the dependency-free Node tests.
function validStationId(value) {
    return typeof value === "string" && /^1-[0-9]{1,20}$/.test(value.trim());
}

function endpoint(value) {
    if (!validStationId(value)) throw new Error("Ungültige Packstations-ID. Beispiel: 1-72555132");
    return "https://www.dhl.de/int-postfinder/webservice/rest/v1/locationByPrimaryKeyPF/" + encodeURIComponent(value.trim());
}

function parseTimestamp(value) {
    if (typeof value !== "string") return null;
    // DHL uses +0100; normalize to ISO-8601 for Qt's JavaScript engine.
    var normalized = value.replace(/([+-][0-9]{2})([0-9]{2})$/, "$1:$2");
    if (!/^\d{4}-\d{2}-\d{2}T.*(?:Z|[+-]\d{2}:\d{2})$/.test(normalized)) return null;
    var date = new Date(normalized);
    return isNaN(date.getTime()) ? null : date;
}

function parseResponse(payload) {
    if (!payload || typeof payload !== "object" || Array.isArray(payload))
        throw new Error("DHL hat keine gültigen Standortdaten geliefert.");
    var live = payload.liveStatus;
    if (!live || typeof live !== "object")
        throw new Error("Für diese Packstation sind keine Live-Daten verfügbar.");
    var keys = ["freeCompartmentsS", "freeCompartmentsM", "freeCompartmentsL", "freeCompartmentsXl"];
    var counts = keys.map(function(key) {
        var value = live[key];
        if (typeof value !== "number" || !isFinite(value) || value < 0 || Math.floor(value) !== value)
            throw new Error("DHL liefert unvollständige oder ungültige Fachzahlen.");
        return value;
    });
    var street = [payload.street, payload.houseNo].filter(Boolean).join(" ");
    var city = [payload.zipCode, payload.city].filter(Boolean).join(" ");
    return {
        name: [payload.keyWord || "DHL Packstation", payload.primaryKeyZipRegion || ""].filter(Boolean).join(" "),
        location: payload.locationName || "",
        address: [street, city].filter(Boolean).join(", "),
        counts: counts,
        total: counts.reduce(function(sum, count) { return sum + count; }, 0),
        sourceTimestamp: parseTimestamp(live.sourceTimestamp)
    };
}
