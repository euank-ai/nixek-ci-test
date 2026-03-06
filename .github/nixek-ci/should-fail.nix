{ nixpkgs, pkgs, nixekcid, mkMachine }:

{ info ? "" }: {
  machine = mkMachine {
    inherit nixpkgs pkgs nixekcid;
    extraModules = [{
      environment.systemPackages = with pkgs; [ hello ];
    }];
  };

  steps = [
    {
      name = "This step passes";
      command = [ "${pkgs.hello}/bin/hello" ];
    }
    {
      name = "This step fails";
      command = [ "/bin/sh" "-c" "echo 'About to fail!' && exit 42" ];
    }
    {
      name = "This step should not run";
      command = [ "echo" "unreachable" ];
    }
  ];
}
