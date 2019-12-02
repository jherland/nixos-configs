# Pull in starship from unstable
self: super:
let
  unstable = import <unstable> { overlays = []; };
in {
  inherit (unstable) starship;
}
