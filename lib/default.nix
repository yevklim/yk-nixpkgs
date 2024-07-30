{ callPackage
, ...
}:
{
  maintainers.yevklim = {
    name = "yevklim";
    email = "64846678+yevklim@users.noreply.github.com";
    github = "yevklim";
    githubId = 64846678;
  };

  mkAutostartEntries = callPackage ./mk-autostart-entries.nix { };
}
