{
  description = "TizenTube for old Samsung TVs, loading its userscript from your own server";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      # The userscript to serve: the @foxreis/tizentube npm package, pinned.
      # To update, review the new dist/userScript.js against the old one, then
      # bump both values. Hash:
      #   nix store prefetch-file https://registry.npmjs.org/@foxreis/tizentube/-/tizentube-<version>.tgz
      userscriptVersion = "1.15.2";
      userscriptHash = "sha256-EoSo8C/N6X6iDrlnSvzMDHMSVPahMAdue+IGhfpaTfE=";
    in
    {
      # A directory with userScript.js and version, for any static web server.
      packages.${system}.userscript =
        pkgs.runCommand "tizentube-userscript-${userscriptVersion}"
          {
            src = pkgs.fetchurl {
              url = "https://registry.npmjs.org/@foxreis/tizentube/-/tizentube-${userscriptVersion}.tgz";
              hash = userscriptHash;
            };
          }
          ''
            mkdir -p $out
            tar -xzf $src --strip-components=2 -C $out package/dist/userScript.js
            echo -n ${userscriptVersion} > $out/version
          '';

      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.nodejs_22
          pkgs.zip
          pkgs.apps2samsung
        ];
      };

      formatter.${system} = pkgs.nixfmt;
    };
}
