#!/usr/bin/env bash
# Builds the standalone TizenTube app (Old Tizen build, Tizen 3 to 5.5) that
# loads its userscript from your own server instead of jsDelivr.
#
# Configuration: environment variables, or lan.env in the repo root (see
# lan.env.example). Output: release/TizenTube-<package id>-unsigned.wgt, to be
# signed and installed with Apps2Samsung (see README).
set -euo pipefail

root=$(cd "$(dirname "$0")/.." && pwd)
die() { echo "build-lan: $*" >&2; exit 1; }

if [ -f "$root/lan.env" ]; then
    # shellcheck disable=SC1091
    . "$root/lan.env"
fi

: "${TT_USERSCRIPT_URL:?not set; copy lan.env.example to lan.env and edit it}"
TT_CA_FILE=${TT_CA_FILE-$root/lan/isrg-roots.pem}
TT_PACKAGE_ID=${TT_PACKAGE_ID:-lanTizTub1}
TT_APP_NAME=${TT_APP_NAME:-TizenTube LAN}

[[ $TT_PACKAGE_ID =~ ^[0-9A-Za-z]{10}$ ]] || die "TT_PACKAGE_ID must be 10 letters or digits"
[[ $TT_APP_NAME =~ ^[0-9A-Za-z\ ._()-]+$ ]] || die "TT_APP_NAME: letters, digits, spaces and ._()- only"
[[ $TT_USERSCRIPT_URL =~ ^https?:// ]] || die "TT_USERSCRIPT_URL must be an http(s) URL"
if [ -n "$TT_CA_FILE" ]; then
    [ -f "$TT_CA_FILE" ] || die "TT_CA_FILE not found: $TT_CA_FILE"
fi

build=$(mktemp -d)
trap 'rm -rf "$build"' EXIT

# Work on a copy: the build rewrites config.xml.
tar -C "$root" --exclude=node_modules --exclude=dist -cf - service standalone | tar -C "$build" -xf -

echo "==> DIAL (casting) service"
(cd "$build/service" && npm ci --no-audit --no-fund --ignore-scripts && npx rollup -c rollup.config.js)

echo "==> App service"
cd "$build/standalone/service"
npm ci --no-audit --no-fund --ignore-scripts
TT_USERSCRIPT_URL=$TT_USERSCRIPT_URL TT_CA_FILE=$TT_CA_FILE node -e '
    const fs = require("fs");
    const caFile = process.env.TT_CA_FILE;
    const caCertificates = caFile
        ? fs.readFileSync(caFile, "utf8").match(/-----BEGIN CERTIFICATE-----[\s\S]+?-----END CERTIFICATE-----/g) || []
        : [];
    if (caFile && !caCertificates.length) throw new Error("no certificates in " + caFile);
    fs.writeFileSync("utils/lanConfig.json", JSON.stringify({
        userScriptUrl: process.env.TT_USERSCRIPT_URL,
        caCertificates: caCertificates
    }, null, 2));
'
npm run build
node build-service.js remove-cobalt-flags

echo "==> Package"
cd "$build/standalone"
# The default package keeps the widget id of the first builds, so updates of an
# installed app go through; other package ids get their own.
widget_id=https://tizentube.app/lan
[ "$TT_PACKAGE_ID" = lanTizTub1 ] || widget_id=https://tizentube.app/lan/$TT_PACKAGE_ID
sed -i \
    -e "s|id=\"https://tizentube.app\"|id=\"$widget_id\"|" \
    -e "s|xvvl3S1TT1|$TT_PACKAGE_ID|g" \
    -e "s|<name>TizenTube</name>|<name>$TT_APP_NAME</name>|" \
    config.xml
grep -q "package=\"$TT_PACKAGE_ID\"" config.xml || die "could not set the package id in config.xml"
grep -q 'cdn.jsdelivr.net/npm' service/dist/app.js && die "a jsDelivr script URL is still in the build"

mkdir -p "$root/release"
out="$root/release/TizenTube-$TT_PACKAGE_ID-unsigned.wgt"
rm -f "$out"
zip -X -q -r "$out" config.xml icon.png icon_16b9.png index.html service/package.json service/dist
echo "==> $out"
