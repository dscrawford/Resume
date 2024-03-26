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
          scheme-full
          latex-bin
          latexmk
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
              latexmk -interaction=nonstopmode -pdf -xelatex -f \
              resume_cv.tex
          '';
          installPhase = ''
            mkdir -p $out
            cp resume.pdf $out/
          '';
        };
      };
      defaultPackage = packages.document;
    });
}
