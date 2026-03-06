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
    ci = {
      jobs = {
        # A passing job — installs packages and verifies they work
        hello-world = { info ? "" }: {
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
        };

        # A failing job — second step deliberately fails
        should-fail = { info ? "" }: {
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
        };
      };
    };
  };
}
