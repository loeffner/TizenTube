"use strict";

// Where the userscript comes from.
//
// Upstream downloads the latest userscript from jsDelivr on every start and
// runs it unchecked inside the signed-in YouTube page. This fork loads it from
// a server you control instead, which serves a version you pinned and reviewed.
//
// Both start modes get it through this module: the debugger path injects the
// text, the proxy path serves it to the page at /tizentube/userScript.js.
//
// The URL and the trusted CA certificates are set at build time
// (scripts/build-lan.sh writes lanConfig.json). With CA certificates given,
// the request trusts exactly those and nothing else; older TVs need this
// anyway, as their Node.js (v4 on Tizen 5) lacks today's root certificates.

const https = require('https');
const fetch = require('node-fetch');
const config = require('./lanConfig.json');

const USERSCRIPT_URL = config.userScriptUrl;

const agent = config.caCertificates && config.caCertificates.length
    ? new https.Agent({ ca: config.caCertificates })
    : undefined;

function downloadUserScript() {
    return fetch(USERSCRIPT_URL, { agent: agent, timeout: 15000 }).then(res => {
        if (!res.ok) throw new Error(`HTTP ${res.status} from ${USERSCRIPT_URL}`);
        return res.text();
    });
}

module.exports = { USERSCRIPT_URL, downloadUserScript };
