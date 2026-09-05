{
  outputs = { self, nixpkgs }: {
    packages = nixpkgs.lib.mapAttrs (_: pkgs: with pkgs; {

      cursor = let
        repo = "vimix-cursors";
        rev = "dcb3082f382a9adf68efbd6a59c3f985eec73012";
        hash = "sha256-xMi0CN1xxVbPPp3Myv38lJdYcZVxaVdZCYrpG9snaRI=";

        accurse = with python3Packages; buildPythonApplication (finalAttrs: {
          pname = "accurse";
          version = "0.1.0";
          pyproject = true;

          src = fetchPypi {
            inherit (finalAttrs) pname version;
            sha256 = "sha256-ozkNbTrfdCfSk4EY1b4gJSKHlhcSlv2Kb1zTkDq6M0s=";
          };

          build-system = [ hatchling ];
          dependencies = [ lxml ];
        });
      in stdenvNoCC.mkDerivation {
        pname = repo;
        version = builtins.substring 0 8 rev;

        src = fetchFromGitHub {
          owner = "vinceliuice";
          inherit repo rev hash;
          rootDir = "src/svg-white";
        };

        nativeBuildInputs = [ accurse librsvg xcursorgen ];

        buildPhase = ''
          mkdir vimix
          mv *.svg vimix
          cp ${./cursor/metadata.toml} vimix/metadata.toml
          accurse vimix/metadata.toml || true
        '';

        installPhase = ''
          mkdir -p "$out/share/icons"
          mv AC-vimix "$out/share/icons/vimix-cursors"
        '';

        dontFixup = true;
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

        postPatch = ''
          patchShebangs install.sh
        '';

        installPhase = ''
          runHook preInstall

          find -name '*.scss' -exec sed -i -f ${./gtk/edit.sed} {} +

          ./install.sh --theme grey --color dark --size compact --icon nixos \
            --round 8px --tweaks black primary --dest $out/share/themes

          jdupes --quiet --link-soft --recurse $out/share

          runHook postInstall
        '';

        dontFixup = true;
      };

      icon = (papirus-icon-theme.overrideAttrs { dontFixup = true; })
        .override { color = "grey"; };

    }) nixpkgs.legacyPackages;
  };
}
