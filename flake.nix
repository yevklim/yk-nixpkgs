{
  description = "YK's collection of packages";

  inputs = {
    nixpkgs.url = "github:yevklim/nixpkgs/2025-05-19";
  };

  outputs = inputs: import ./. { inherit inputs; };
}
