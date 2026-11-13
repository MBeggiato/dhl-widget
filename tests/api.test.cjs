const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const api = vm.createContext({});
vm.runInContext(fs.readFileSync(`${__dirname}/../package/contents/code/api.js`, 'utf8'), api);
function fixture() {
    return { keyWord: 'DHL Packstation', primaryKeyZipRegion: '132', locationName: 'ALDI Markt', street: 'Gutenbergstr.', houseNo: '46', zipCode: '72555', city: 'Metzingen', liveStatus: { freeCompartmentsS: 3, freeCompartmentsM: 10, freeCompartmentsL: 5, freeCompartmentsXl: 0, sourceTimestamp: '2026-11-13T09:28:03+0100' } };
}
test('validates IDs and prevents URL injection', () => {
    for (const id of ['', '132', '1-abc', '1-123/../../', 'https://example.com', null]) assert.equal(api.validStationId(id), false);
    assert.equal(api.validStationId(' 1-72555132 '), true);
    assert.ok(api.endpoint(' 1-72555132 ').endsWith('/1-72555132'));
    assert.throws(() => api.endpoint('bad'));
});
test('parses DHL fixture, sum, name, address and timezone', () => {
    const result = api.parseResponse(fixture());
    assert.equal(result.total, 18);
    assert.equal(result.name, 'DHL Packstation 132');
    assert.equal(result.address, 'Gutenbergstr. 46, 72555 Metzingen');
    assert.equal(result.sourceTimestamp.toISOString(), '2026-11-13T08:28:03.000Z');
});
test('zero is valid availability, not missing data', () => {
    const data = fixture();
    for (const key of Object.keys(data.liveStatus)) if (key !== 'sourceTimestamp') data.liveStatus[key] = 0;
    assert.equal(api.parseResponse(data).total, 0);
});
test('rejects missing live status, malformed responses and partial counts', () => {
    for (const value of [null, [], {}, { liveStatus: {} }]) assert.throws(() => api.parseResponse(value));
    for (const value of [null, undefined, '3', -1, 1.5, NaN, Infinity]) {
        const data = fixture(); data.liveStatus.freeCompartmentsS = value;
        assert.throws(() => api.parseResponse(data));
    }
});
test('missing or malformed timestamp remains unknown instead of current', () => {
    for (const value of [undefined, null, '', 'invalid', '2026-11-13T09:28:03']) {
        const data = fixture(); data.liveStatus.sourceTimestamp = value;
        assert.equal(api.parseResponse(data).sourceTimestamp, null);
    }
});
test('supports UTC and colon-separated timezone', () => {
    assert.equal(api.parseTimestamp('2026-11-13T08:28:03Z').toISOString(), '2026-11-13T08:28:03.000Z');
    assert.equal(api.parseTimestamp('2026-11-13T09:28:03+01:00').toISOString(), '2026-11-13T08:28:03.000Z');
});
