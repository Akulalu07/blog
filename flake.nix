{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        haskellPackages = pkgs.haskellPackages.override {
          overrides = self: super: { };
        };

        blog = haskellPackages.callCabal2nix "blog" ./. { };

        siteApp = flake-utils.lib.mkApp {
          drv = blog;
          exePath = "/bin/site";
        };

      in {
        packages.default = blog;
        packages.site = blog;

        apps.default = siteApp;
        apps.site = siteApp;

        devShells.default = haskellPackages.shellFor {
          packages = p: [ blog ];
          buildInputs = [
            haskellPackages.cabal-install
            haskellPackages.hlint
            haskellPackages.fourmolu
            pkgs.pandoc
          ];
          withHoogle = true;
        };

        formatter = pkgs.nixpkgs-fmt;
      });
}