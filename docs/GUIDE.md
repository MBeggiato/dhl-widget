# Weitere Hinweise

## Daten und Datenschutz

- Angezeigt werden freie Fächer, keine prozentuale Auslastung. Null bedeutet keine freien Fächer; ein Strich bedeutet fehlende Daten.
- Der DHL-Datenstand ist der Quellzeitpunkt, nicht der lokale Abrufzeitpunkt. Nach 15 Minuten, bei unbekanntem Zeitstempel oder bei Abruffehlern werden Werte als veraltet markiert.
- Letzte bekannte Werte bleiben während der laufenden Instanz erhalten. Beim Stationswechsel werden sie verworfen. Es gibt keinen persistenten Verfügbarkeitscache.
- Pro Station wird beim Start und alle fünf Minuten direkt bei DHL abgefragt. Nach 20 Sekunden wird eine Anfrage abgebrochen. Mehrere Widget-Instanzen fragen unabhängig ab.
- DHL erhält die konfigurierten Standort-IDs und übliche Verbindungsdaten. Keine zusätzliche Telemetrie.
- Der öffentlich erreichbare DHL-Endpunkt ist keine zugesichert stabile Entwickler-API. Erreichbarkeit und Schema können sich ändern. Fachzahlen sind keine Reservierung.

## Gemeinsame Einstellungen

IDs, Kurznamen und Favorit werden benutzerweit in `packstation-widget.ini` im Qt-Konfigurationsverzeichnis gespeichert, normalerweise unter `~/.config/`. Instanzen gleichen die Werte etwa sekündlich ab. Filter und Detailnavigation bleiben unabhängig.

Beim ersten Start liefert die zuerst gestartete Instanz die Ausgangswerte. Wird eine ältere Liste übernommen, einmal die gewünschten Stationen in einer Instanz speichern. Nicht mehrere Einstellungsdialoge gleichzeitig bearbeiten; die zuletzt gespeicherte Änderung gewinnt.

## Update und Entfernen

`./update-widget.sh` installiert den aktuellen lokalen Projektstand und startet anschließend `plasma-plasmashell.service` neu. Anwendungen bleiben geöffnet; Desktop und Panel verschwinden kurz. Das Skript lädt keine Git-Änderungen herunter und bricht bei Installationsfehlern vor dem Neustart ab.

Ohne Shell-Neustart:

```sh
kpackagetool6 --type Plasma/Applet --upgrade ./package
```

Entfernen:

```sh
kpackagetool6 --type Plasma/Applet --remove de.local.packstation
```

## Entwicklung

Node.js wird nur für Tests benötigt; keine npm-Abhängigkeiten.

```sh
node --test tests/api.test.cjs
/usr/lib/qt6/bin/qmllint package/contents/ui/*.qml package/contents/config/config.qml
```

Die dynamischen KConfig-Schlüssel können Lint-Hinweise auslösen. Auf Arch/CachyOS explizit Qt-6-Werkzeuge verwenden, da unqualifiziertes `qml` noch Qt 5 starten kann.

Manuelle Abnahme: Desktop, Panel, Systemabschnitt, Tastaturbedienung, schmale Größen, helle/dunkle Themes, Stationswechsel, Offlinezustand und veraltete Daten. Ein isolierter QML-Test ersetzt keine Plasma-Abnahme.

## Demo-Screenshots

Die Screenshot-Fixture verwendet die tatsächlichen Vergleichs- und Detailkomponenten mit erfundenen Standorten, festen Fachzahlen und einem festen Zeitstempel. Keine Netzwerkabfragen oder Änderungen an Benutzereinstellungen.

```sh
mkdir -p docs/screenshots
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
  /usr/lib/qt6/bin/qml -f tests/screenshots.qml
```

Die PNGs werden relativ zum Fixture in `docs/screenshots/` gespeichert. Für einen isolierten Sitzungsbus kann der Aufruf mit `dbus-run-session --` gestartet werden.

Paket bauen:

```sh
mkdir -p dist
(cd package && zip -r ../dist/packstation.plasmoid metadata.json contents)
```
