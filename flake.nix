{
  description = "Zig sdl3 build";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    zig.url = "github:mitchellh/zig-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, zig } @ inputs:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ] (system:
      let
        pkgs = import nixpkgs {
            inherit system;
            overlays = [ zig.overlays.default ];
        };

        RUNTIME_LIBS = with pkgs; [
            libGL
            vulkan-loader
            xorg.libX11
        ];
      in
      {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            pkg-config
            zigpkgs."0.17.0"
          ];

          buildInputs = RUNTIME_LIBS;

          shellHook = ''
            export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath RUNTIME_LIBS}:$LD_LIBRARY_PATH"
          '';
        };
      });
}
