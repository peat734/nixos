{
  
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

  };
  outputs = { self, nixpkgs }@inputs: 

    let
      system = "x86-64-linux";
      pkgs = import nixpkgs {
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

