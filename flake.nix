{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  inputs.theme-module.url = path:./themes/minima;
  outputs = { self, nixpkgs, theme-module}:#, #theme-module}:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in{

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in rec {
          blog = pkgs.stdenv.mkDerivation {
          name = "dav009_blog"; # our package name, irrelevant in this case
          src = ./.;
            buildPhase = ''
              ${pkgs.hugo}/bin/hugo --minify
            '';
            installPhase = ''
              cp -r public $out
            '';
          };
          default = blog;
        });  
      
     devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ hugo ];
          };
      });
    };
}
