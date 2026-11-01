{
    description= "Zig sdl3 build";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
        flake-utils.url = "github:numtide/flake-utils";
    };


    outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: 
    let 
        pkgs = nixpkgs.legacyPackages.${system}; 
        RUNTIME_LIBS = with pkgs; [
          sdl3
          libGL
          vulkan-loader
        ];
    in 
    {   
        devShells.default = pkgs.mkShell {
            nativeBuildInputs = with pkgs; [
                pkg-config
            ];

            packages = with pkgs; [
                zig
                sdl3
            ];

            buildInputs = RUNTIME_LIBS;
            shellHook = ''
                export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath RUNTIME_LIBS}:$LD_LIBRARY_PATH"
            '';
        };
    });
}
