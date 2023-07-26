{
  description = "Shell with dependencies to build OTP";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs"; # also valid: "nixpkgs"
  };

  # Flake outputs
  outputs = { self, nixpkgs }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });

    in
    {
      # Development environment output
      devShells = forAllSystems ({ pkgs }: {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            glib
            libGL
            libGLU
            ncurses
            openssl
            systemd
            (wxGTK32.override { withWebKit = true; })
            xorg.libX11
          ];

          configurePhase = with pkgs; ''
            ./configure \
              --with-ssl=${lib.getOutput "out" openssl} \
              --with-ssl-incl=${lib.getDev openssl} \
              --enable-threads \
              --enable-smp-support \
              --enable-kernel-poll \
              --enable-wx \
              --enable-systemd \
              --without-javac \
              --without-odbc
          '';
        };
      });
    };
}
