# nix build '.?submodules=1'
# nix run '.?submodules=1'
{
  inputs.nixpkgs.url = "nixpkgs/nixos-21.11";
  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });
    in{

      packages = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in rec {
          blog = pkgs.stdenv.mkDerivation {
          name = "dav009_blog";
          src = ./.;
            buildPhase = ''
              ${pkgs.hugo}/bin/hugo --minify
            '';
            installPhase = ''
              cp -r public $out
            '';
          };
          script = pkgs.writeShellScript "run" ''
              ${pkgs.hugo}/bin/hugo serve
          '';
          default = blog;
        });  

      apps = forAllSystems (system: 
        let pkgs = nixpkgsFor.${system};
        in rec { 
        app = {
          type = "app";
          program = "${self.packages.${system}.script}";
        };
        default = app;
        });

     defaultApp = forAllSystems (system: self.apps.${system}.default); 
      
     devShells = forAllSystems (system:
        let pkgs = nixpkgsFor.${system};
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ hugo ];
          };
      });
    };
}
