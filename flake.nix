{
  description = "ccg — Claude Code Git";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in {
      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = pkgs.stdenvNoCC.mkDerivation {
            pname = "ccg";
            version = "0.1.0";
            src = ./.;

            dontBuild = true;

            installPhase = ''
              mkdir -p $out/bin
              install -m 755 bin/ccg $out/bin/ccg
            '';

            meta = {
              description = "Keep Claude Code process files out of your product repo";
              license = pkgs.lib.licenses.mit;
              platforms = pkgs.lib.platforms.unix;
            };
          };
        });
    };
}
