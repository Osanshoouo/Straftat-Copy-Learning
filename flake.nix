{
  description = "Rust Test Shell";

  inputs = { nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable"; };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
      {

        devShells.${system}.default = pkgs.mkShell {
          packages = [ pkgs.rustc pkgs.cargo pkgs.rust-analyzer ];
          nativeBuildInputs = with pkgs; [ pkg-config ];
          buildInputs = with pkgs; [
            
            clang
            llvmPackages_latest.bintools
            udev
            alsa-lib
            vulkan-loader
            xorg.libX11
            xorg.libXcursor
            xorg.libXi
            xorg.libXrandr
            libxkbcommon
            wayland
            glibc.dev
            glib.dev
          ];

          shellHook = ''
            export PATH=$PATH:''${CARGO_HOME:-~/.cargo}/bin
            export LD_LIBRARY_PATH=${
              pkgs.lib.makeLibraryPath [
                pkgs.vulkan-loader
                pkgs.libxkbcommon
                pkgs.wayland
                pkgs.alsa-lib
                pkgs.udev
              ]
            }:$LD_LIBRARY_PATH
            export LIBCLANG_PATH="${pkgs.llvmPackages_latest.libclang.lib}/lib"
            export BINDGEN_EXTRA_CLANG_ARGS="-I${pkgs.glibc.dev}/include -I${pkgs.llvmPackages_latest.libclang.lib}/lib/clang/${pkgs.llvmPackages_latest.libclang.version}/include -I${pkgs.glib.dev}/include/glib-2.0 -I${pkgs.glib.out}/lib/glib-2.0/include/"
            export RUSTFLAGS="-C link-arg=-fuse-ld=lld"
            echo "Bevy development environment loaded!"
          '';
        };
      };
}
