{
  
  description = "A very basic flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
    zen-browser = {
    	url = "github:0xc000022070/zen-browser-flake";
	inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs = { self, nixpkgs, ghostty, zen-browser }@inputs: 

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

