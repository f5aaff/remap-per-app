{
  description = "Per-app key remap bash utility with automatic systemd service installer";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      packages.${system}.remap-per-app = pkgs.stdenv.mkDerivation {
        pname = "remap-per-app";
        version = "1.0.0";

        src = self;

        installPhase = ''
          mkdir -p $out/bin
          cp bin/remap-per-app-daemon $out/bin/remap-per-app-daemon
          cp bin/install-service.sh $out/bin/install-service

          mkdir -p $out/etc/systemd/user
          cp systemd/remap-per-app.service $out/etc/systemd/user/remap-per-app.service
        '';

        meta = with pkgs.lib; {
          description = "Per-application remap bash utility with automatic systemd service installer";
          license = licenses.mit;
          maintainers = [ maintainers.f5aaff ];
        };
      };

      defaultPackage.${system} = self.packages.${system}.remap-per-app;

      defaultApp.${system} = {
        type = "app";
        program = "${self.packages.${system}.remap-per-app}/bin/remap-per-app-daemon";
      };

      apps.${system}.install-service = {
        type = "app";
        program = "${self.packages.${system}.remap-per-app}/bin/install-service";
      };
    };
}

