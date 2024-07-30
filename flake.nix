{
  description = "YK's collection of packages";

  inputs = {
    nixpkgs.url = "github:yevklim/nixpkgs/nixos-unstable";
  };

  outputs = inputs: import ./. { inherit inputs; };
}
