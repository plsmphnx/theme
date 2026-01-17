{
  outputs = { self, nixpkgs }: let
    systems = fn: nixpkgs.lib.mapAttrs (_: fn) nixpkgs.legacyPackages;
  in {
    packages = systems (pkgs: with pkgs; {
      cursor = let
        accurse = with python3Packages; buildPythonApplication rec {
          pname = "accurse";
          version = "0.1.0";
          pyproject = true;

          src = fetchPypi {
            inherit pname version;
            sha256 = "sha256-ozkNbTrfdCfSk4EY1b4gJSKHlhcSlv2Kb1zTkDq6M0s=";
          };

          build-system = [ hatchling ];
          dependencies = [ lxml ];
        };
      in stdenvNoCC.mkDerivation {
        name = "vimix-cursors";
        src = ./cursor;
        nativeBuildInputs = [ accurse librsvg xorg.xcursorgen ];
        buildPhase = ''
          accurse vimix/metadata.toml || true
        '';
        installPhase = ''
          mkdir -p "$out/share/icons"
          mv AC-vimix "$out/share/icons/vimix-cursors"
        '';
      };

      gtk = let
        repo = "orianin-gtk-theme";
        rev = "5cfdf21c72200bf4c2f0adb2ac0f002d23590313";
        hash = "sha256-KBJM5aOUre7ZvaVePSUzXuD74GMGsgcYeo4iGyhlLm0=";
      in stdenvNoCC.mkDerivation {
        pname = repo;
        version = builtins.substring 0 8 rev;

        src = fetchFromGitHub {
          owner = "vinceliuice";
          inherit repo rev hash;
        };

        nativeBuildInputs = [ jdupes sassc ];

        patches = [ ./gtk/alpha.patch ];

        postPatch = ''
          patchShebangs install.sh
        '';

        installPhase = ''
          runHook preInstall

          ./install.sh --theme grey --color dark --size compact --icon nixos \
            --round 8px --tweaks black primary --dest $out/share/themes

          jdupes --quiet --link-soft --recurse $out/share

          runHook postInstall
        '';
      };

      icon = (papirus-icon-theme.overrideAttrs { dontFixup = true; })
        .override { color = "grey"; };
    });
  };
}
