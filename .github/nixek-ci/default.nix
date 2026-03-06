{ nixpkgs, pkgs, nixekcid, mkMachine }:

{
  jobs = {
    hello-world = import ./hello-world.nix { inherit nixpkgs pkgs nixekcid mkMachine; };
    should-fail = import ./should-fail.nix { inherit nixpkgs pkgs nixekcid mkMachine; };
  };
}
