{
  description = "YK's collection of packages";

  inputs = {
    nixpkgs.url = "github:yevklim/nixpkgs/2025-08-29";
  };

  outputs = inputs: import ./. { inherit inputs; };
}
