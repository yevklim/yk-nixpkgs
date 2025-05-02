{
  description = "YK's collection of packages";

  inputs = {
    nixpkgs.url = "github:yevklim/nixpkgs/master";
  };

  outputs = inputs: import ./. { inherit inputs; };
}
