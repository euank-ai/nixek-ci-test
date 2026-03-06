{
  description = "nixek-ci test repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixek-ci.url = "github:euank-ai/nixek-ci";
  };

  outputs = { self, nixpkgs, nixek-ci }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
    nixekcid = nixek-ci.packages.${system}.nixekcid;
    mkMachine = nixek-ci.lib.mkMachine;
  in
  {
    ci = import ./.github/nixek-ci { inherit nixpkgs pkgs nixekcid mkMachine; };
  };
}
