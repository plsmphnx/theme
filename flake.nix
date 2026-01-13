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
        src = ./.;
        nativeBuildInputs = [ accurse librsvg xorg.xcursorgen ];
        buildPhase = ''
          accurse vimix/metadata.toml || true
        '';
        installPhase = ''
          mkdir -p "$out/share/icons"
          mv AC-vimix "$out/share/icons/vimix-cursors"
        '';
      };

      gtk = (fluent-gtk-theme.overrideAttrs (_: {
        preInstall = ''
          sed -i "/primary/s/white/rgba(white, 0.9)/g" ./src/_sass/_colors.scss
          sed -i "/\$background:/s/#333333/#000000/gi" ./src/_sass/_colors.scss
          sed -i "/\$surface:/s/#3C3C3C/#000000/gi" ./src/_sass/_colors.scss
          sed -i "/\$blur_opacity:/s/0\.5/0.4/g" ./src/_sass/_colors.scss
          sed -i "/\$window-radius:/s/.px/0px/g" ./src/_sass/_variables.scss    
        '';
      })).override {
        colorVariants = [ "dark" ];
        sizeVariants = [ "compact" ];
        themeVariants = [ "grey" ];
        tweaks = [ "blur" "noborder" "round" ];
      };

      icon = vimix-icon-theme;
    });
  };
}
