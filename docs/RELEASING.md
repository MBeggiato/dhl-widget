# Veröffentlichen

## Einmalig: GitHub-Repository anlegen

Auf GitHub ein leeres Repository erstellen, ohne zusätzliche README oder Lizenz. Im Projektordner ausführen; `DEIN-NAME/DEIN-REPO` ersetzen:

```sh
git init -b main
git add .
git commit -m "Initial release preparation"
git remote add origin https://github.com/DEIN-NAME/DEIN-REPO.git
git push -u origin main
```

Die Workflows laufen auf GitHub-gehosteten Runnern. Kein eigener Worker, Server oder zusätzliches Secret nötig. Actions müssen im Repository erlaubt sein. Nur der Release-Veröffentlichungsjob erhält Schreibrechte auf Releases; die Prüfjobs haben ausschließlich Leserechte.

## Vor dem ersten Release

- Autor in `package/metadata.json` und Lizenzzuordnung prüfen; aktuell ist eine generische Contributor-Angabe eingetragen.
- Die Plugin-ID `de.local.packstation` absichtlich beibehalten, um vorhandene Installationen nicht zu duplizieren. Eine spätere Umbenennung braucht einen Migrationsplan.
- Installation, Upgrade, Systemabschnitt, gemeinsame Einstellungen, helle/dunkle Themes und Netzwerkfehler in einer echten Plasma-6-Sitzung prüfen.
- README-Screenshot auf private Informationen und Nutzungsrechte prüfen.
- Der automatisierte Workflow testet Parser und Paketbau, nicht die Plasma-Laufzeit. Qt-/Plasma-QML-Lint lokal ausführen.

## Version veröffentlichen

1. `KPlugin.Version` in `package/metadata.json` auf die gewünschte Version setzen, beispielsweise `0.1.0`.
2. Änderungen committen und pushen.
3. Tag mit exakt passender Version erstellen und pushen:

```sh
node --test tests/api.test.cjs
python3 tests/build.test.py
python3 scripts/build.py --tag v0.1.0
git add .
git commit -m "Prepare v0.1.0"
git push
git tag -a v0.1.0 -m "Packstation v0.1.0"
git push origin v0.1.0
```

Wenn bereits alles committed ist, entfällt der zusätzliche Commit. Für spätere Releases beide Versionsangaben ersetzen. Tags wie `v0.2.0-beta.1` werden als GitHub-Prerelease veröffentlicht.

Der Release-Workflow prüft Tests und Tag/Metadaten-Übereinstimmung, baut das Archiv und veröffentlicht ein GitHub Release mit:

- `packstation.plasmoid`
- `packstation.plasmoid.sha256`
- automatisch generierten Release-Notizen

Release-Notizen danach um wichtige Änderungen und bekannte Einschränkungen ergänzen. Bestehende Release-Tags nicht nachträglich verschieben. Bei einem fehlgeschlagenen Upload zuerst den Workflow-Fehler prüfen; ein schon erzeugtes Release nicht blind nochmals veröffentlichen.

## KDE Store

1. Konto auf https://store.kde.org/ anlegen.
2. Einen Eintrag in der passenden Plasma-6-Widgets-Kategorie erstellen.
3. Beschreibung, Screenshot, MIT-Lizenz, GitHub-Projektlink und Versionsnummer hinterlegen.
4. Die fertige `.plasmoid` aus dem GitHub Release als Download hochladen und nach Vorgaben des Stores für Plasma-Miniprogramme kennzeichnen.
5. Installation über „Neue Miniprogramme herunterladen“ praktisch überprüfen.

Store-Uploads erfolgen zunächst manuell. Es werden keine Store-Zugangsdaten im Repository gespeichert.

## Lokaler Paketbau

```sh
python3 scripts/build.py
(cd dist && sha256sum -c packstation.plasmoid.sha256)
```

Der Builder verwendet nur Python-Standardbibliothek und paketiert ausschließlich Metadaten, Laufzeitdateien und Lizenz. Feste Zeitstempel und Dateirechte sorgen innerhalb derselben Python-/zlib-Toolchain für reproduzierbare Archive. `dist/` und lokale Testinstallationen werden nicht eingecheckt.
