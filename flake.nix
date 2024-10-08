{
  description = "Daniel Crawford Resume";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-21.05;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      tex = pkgs.texlive.combine {
        inherit (pkgs.texlive)
          scheme-small
          latex-bin
          latexmk
          enumitem
          xifthen
          ifmtarg
          sourcesanspro
          tcolorbox
          environ
          lualatex-math
        ;
      };
    in rec {
      packages = {
        document = pkgs.stdenvNoCC.mkDerivation rec {
          name = "daniel-crawford-resume";
          src = self;
          buildInputs = [ pkgs.coreutils tex ];
          phases = ["unpackPhase" "buildPhase" "installPhase"];
          buildPhase = ''
            export PATH="${pkgs.lib.makeBinPath buildInputs}";
            mkdir -p .cache/texmf-var
            env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
              latexmk -interaction=nonstopmode -pdf -lualatex -f \
              resume_cv.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp resume_cv.pdf $out/DanielCrawford_MLEngineer_Resume.pdf
            cp resume_cv.pdf $out/DanielCrawford_DataScientist_Resume.pdf
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
