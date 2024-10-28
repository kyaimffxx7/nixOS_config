{
  description = "Hisoka's NixOS flake";
  
  # Extra substituters setup
  nixConfig = {
    # will be appended to the system-level substituters
    extra-substituters = [
      # nix community's cache server
      "https://nix-community.cachix.org"
    ];

    # will be appended to the system-level trusted-public-keys
    extra-trusted-public-keys = [
      # nix community's cache server public key
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };



  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home-manager Setting
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };



  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
    let
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
  
    in {
      nixosConfigurations = {
        "nixlab" = nixpkgs.lib.nixosSystem {
          inherit system;
	  modules = [
	    ./hardware-configuration.nix
            ./configuration.nix

	    # home-manager modules
	    home-manager.nixosModules.home-manager
	    {
              home-manager.useGlobalPkgs = true;
	      home-manager.useUserPackages = true;
	      home-manager.users.hisoka = import ./home.nix;
	    }

            # Substituters setup
	    {
              # given the users in this list the right to specify additional substituters via:
            #    1. `nixConfig.substituers` in `flake.nix`
              nix.settings.trusted-users = [ "hisoka" ];

            # the system-level substituers & trusted-public-keys
              nix.settings = {
                substituters = [
                  # cache mirror located in China
                  # status: https://mirror.sjtu.edu.cn/
                  # "https://mirror.sjtu.edu.cn/nix-channels/store"
                  # status: https://mirrors.ustc.edu.cn/status/
          
                  "https://cache.nixos.org"
                  "https://mirrors.ustc.edu.cn/nix-channels/store"
                ];
          
                trusted-public-keys = [
                  # the default public key of cache.nixos.org, it's built-in, no need to add it here
                  "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
                ];
	      };
	    }


	  ];
        };
      };
    };
    
}
