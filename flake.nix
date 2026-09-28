{
  description = "Nixos config flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: 
    let 
      vars = import ./variables.nix;
      pkgs = nixpkgs.legacyPackages.${ vars.system };
    in {
      system = vars.system;
      specialArgs = { inherit vars; };
    # use "nixos", or your hostname as the name of the configuration
    # it's a better practice than "default" shown in the video
      nixosConfigurations.${ vars.hostname } = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
  };  
}
