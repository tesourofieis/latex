{
  description = "LaTeX document environment with GregorioTeX support";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive)
          # Base scheme that includes many common packages
            scheme-full
            # Only include packages not in scheme-medium
            collection-fontsextra # Extra fonts including many needed for classical texts
            collection-latexextra # For advanced LaTeX features
            # Specific packages you need that aren't in the collections above
            returntogrid gregoriotex luacode tikz-cd latexindent ebgaramond
            lettrine paracol polyglossia fancyhdr fontspec;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            texlive
            # Tools for development
            pkgs.tectonic
            pkgs.biber
            pkgs.texlab
          ];
          shellHook = ''
            echo "LaTeX development environment loaded"
            echo "Use 'latexmk -pdf main.tex' to build your document"
          '';
        };
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "missal-tradicional";
          src = ./.;
          buildInputs = [ texlive ];
          buildPhase = ''
            latexmk -pdflatex=lualatex -pdf --shell-escape -f -quiet Missal.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp *.pdf $out/
          '';
        };
      });
}
