# TizenTube LAN (this fork)

The standalone TizenTube app for **older Samsung TVs (Tizen 3 to 5.5, models from 2017 to 2020)**, with one change: it loads TizenTube's script from **your own web server** instead of jsDelivr.

**Why:** upstream TizenTube downloads the newest script on every start and runs it inside your signed-in YouTube session, with no review and no pinning. Here only the version you deployed runs, and you update it on purpose. The fork also includes upstream PR #750, which fixes "Launch Service failed" on Tizen 5.

## Setup

You need a Linux PC with [Nix](https://nixos.org), and a web server your TV can reach over HTTPS.

1. **Serve the script.** `nix build .#userscript` creates `result/userScript.js` (pinned in `flake.nix`). Serve that directory with any web server, e.g. Caddy: `root * /path/to/result` plus `file_server`. A Let's Encrypt certificate works as it is. For other certificates, set `TT_CA_FILE` in step 2.
2. **Build the app.** Run `cp lan.env.example lan.env`, put your script's URL in `lan.env`, then run `nix develop -c scripts/build-lan.sh`. The result is `release/TizenTube-lanTizTub1-unsigned.wgt`.
3. **Enable developer mode on the TV.** Open Apps, enter `12345` on the remote, switch Developer mode on, and set Host PC IP to your PC's IP. Then hold the power button until the Samsung logo appears.
4. **Install.** Run `nix develop -c apps2samsung`, enter the TV's IP, choose *Custom WGT File*, and pick the file from step 2.
5. **Finish.** Set Host PC IP to `127.0.0.1` and restart the TV as in step 3. Start **TizenTube LAN** and sign in. Videos only play after this step. Sign in only after this step too: the setup in step 3 keeps a separate login.

## Updating

- **The script:** compare the new version's `dist/userScript.js` with the current one ([npm](https://www.npmjs.com/package/@foxreis/tizentube)). If you're happy with it, bump `userscriptVersion` and `userscriptHash` in `flake.nix` and redeploy your server. The TV loads it on its next start.
- **The app:** only needed when upstream changes the app itself. Set Host PC IP back to your PC, then repeat steps 2, 4 and 5.

If the TV shows "could not load the userscript", it can't reach the URL or doesn't trust the server's certificate. YouTube then still works, without ad blocking.

---

# ▶️ TizenTube
<p align="center">
    <img width="600px" src=".github/assets/TizenTube Standalone Banner.png">
    <br>
    <sub> TizenTube logo, banner and README by <a href="https://github.com/Zyborg777">@Zyborg777</a> </sub>
</p>

**TizenTube** is a TizenBrew module that enhances your favourite streaming websites viewing experience by removing ads and adding support for Sponsorblock. **Now works as a standalone app!**

** **
🤖 **Looking for an app for Android TVs?** Check out [TizenTube Cobalt](https://github.com/reisxd/TizenTubeCobalt). It offers everything TizenTube has for Android TVs.


<p align="left">
    <a href="https://github.com/reisxd/TizenTubeCobalt/releases/latest">
        <picture>
            <img width="250px"
                src=".github/assets/TizenTube_Cobalt_dl-button.png" />
        </picture>
    </a>
</p>

## ❓ How to install

Follow the guide in the [Installation Guide](./docs/README.md).

## ✨ Features
- 📺 **Picture-in-Picture Mode**
- 🛑 **Ad Blocker**: Enjoy your favourite streaming website without interruptions from ads.
- ❗ **SponsorBlock Support**: Automatically skip sponsored segments in videos.
- ⏭️ **Video Speed Control**: Adjust playback speed to your preference.
- 🔺 **[DeArrow](https://dearrow.ajay.app/) Support**: Remove clickbait and misleading video titles.
- ➕ **More to come!** Request features via [issues](https://github.com/reisxd/TizenTube/issues/new).

## 🌐 Community and Support 
| Links |
| ------------- |
| [r/TizenTube Subreddit](https://www.reddit.com/r/TizenTube/)  |
| [Discord Server](https://discord.gg/m2P7v8Y2qR)  | 
| [Telegram](https://t.me/tizentubeofficial)  |
| [Matrix Space](https://matrix.to/#/!BLE5ubNYktI30e8K0j:matrix.6513006.xyz)  |
| [Report Issues / Request Features](https://github.com/reisxd/TizenTube/issues)  |
