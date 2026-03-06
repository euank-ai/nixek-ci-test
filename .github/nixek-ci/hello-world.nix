{ nixpkgs, pkgs, nixekcid, mkMachine }:

{ info ? "" }: {
  machine = mkMachine {
    inherit nixpkgs pkgs nixekcid;
    extraModules = [{
      environment.systemPackages = with pkgs; [
        hello
        cowsay
        jq
      ];
    }];
  };

  steps = [
    {
      name = "Check hello";
      command = [ "${pkgs.hello}/bin/hello" ];
    }
    {
      name = "Check cowsay";
      command = [ "/bin/sh" "-c" "echo 'nixek-ci works!' | ${pkgs.cowsay}/bin/cowsay" ];
    }
    {
      name = "Check jq";
      command = [ "/bin/sh" "-c" ''echo '{"status":"ok"}' | ${pkgs.jq}/bin/jq .status'' ];
    }
  ];
}
