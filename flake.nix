{
  description = "YK's collection of packages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ./. { inherit inputs; };
}
