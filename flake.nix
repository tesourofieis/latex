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

        # Custom LaTeX packages with all required dependencies
        texlive = pkgs.texlive.combine {
          inherit (pkgs.texlive)
            scheme-medium # Base TeX Live scheme
            # KOMA-Script packages
            koma-script
            # Required packages from your document
            background gregoriotex adjmulticol adforn hyperref tikz
            # Add any other packages you need
            latexmk # For build automation
            latexindent # For formatting
          ;
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [
            texlive
            # Tools for development
            pkgs.tectonic # Alternative TeX engine
            pkgs.biber # Bibliography processor
            pkgs.texlab # LSP server for TeX
          ];

          # Set up environment variables
          shellHook = ''
            echo "LaTeX development environment loaded"
            echo "Use 'latexmk -pdf main.tex' to build your document"
          '';
        };

        # Add a package definition to build the document
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          name = "missal-tradicional";
          src = ./.;

          buildInputs = [ texlive ];

          buildPhase = ''
            # Run latexmk to build the PDF
            latexmk -pdf main.tex
          '';

          installPhase = ''
            mkdir -p $out
            cp main.pdf $out/
          '';
        };
      });
}
