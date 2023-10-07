{
  
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    st.url = "github:siduck/st";

  };
  outputs = { self, nixpkgs, st }@inputs: 

    let
      system = "x86-64-linux";
      pkgs = import nixpkgs {
      	  overlays = [st.overlay];
          inherit system;
          config={
              allowUnfree = true;
          };
      };
    in 
{
    nixosConfigurations.asusg14 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs.inputs = inputs;
      modules = [ ./configuration.nix ];
    };
  };
}

