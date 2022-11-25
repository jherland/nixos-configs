{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  imports = [
    ./common.nix
    ./gui.nix
    ./gui_home.nix
#    ./gui_work.nix
    ./vim.nix
  ];

  programs = {
    ssh.enable = true;

#     autorandr = {
#       enable = true;
#       profiles = {
#         default = {
#           fingerprint = {
#             # ThinkVision 4K screen on DP
#             DisplayPort-0 = "00ffffffffffff0030aeda6101010101131d0104b53c22783e1c95a75549a2260f5054a10800d1c081c0810081809500a9c0b300d1004dd000a0f0703e803020350055502100001aa36600a0f0701f803020350055502100001a000000fd0017501ea03c010a202020202020000000fc004c454e20543237702d31300a2001a4020322f14d010203121113041490051f615f230907078301000067030c0010003878565e00a0a0a029503020350055502100001ae26800a0a0402e603020360055502100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000af";
#             # Webex Desk on USB-C
# 	    DisplayPort-1 = "00ffffffffffff000d330a01000000000e1f0104a5351e780eee91a3544c99260f5054210800d1c0a9c081c001010101010101010101023a801871382d40582c4500132b2100001e000000fd001e3c164411010a202020202020000000fc0043532d4445534b2d310a202020000000ff00464f43323531344e5553430a2001f7020318e1451022043e012309070783010000e2004ae20d8100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ee";
# 	    # BenQ on HDMI
# 	    HDMI-A-0 = "00ffffffffffff0009d12178455400000a13010380301b782ee615a655499927135054bfef967100714f81c0810081409500950fb300023a801871382d40582c4500de0d1100001e000000ff0033333930323435343032360a20000000fd00324c185315000a202020202020000000fc0042656e5120473232323048440a00b8";
#           };
#           config = {
#             DisplayPort-0 = {
#               primary = true;
#               mode = "3840x2160";
#               position = "0x0";
#             };
#             DisplayPort-1 = {
#               mode = "1920x1080";
#               position = "3840x0";
#             };
#             HDMI-A-0 = {
#               mode = "1920x1080";
#               position = "3840x0";
#             };
#           };
#         };
#       };
#     };
  };

  # Set up Barrier server as a systemd --user service
  systemd.user.services.barriers =
    let
      listen_ip = "100.72.20.98";
      server_config = pkgs.writeText "barriers.conf" ''
        section: screens
          epsilon:
          chi:
#          delta:
        end
        section: links
          epsilon:
            left = chi
#            right = delta
          chi:
            right = epsilon
#          delta:
#            left = epsilon
        end
      '';
    in
    {
      Unit = {
        Description = "Barrier Server daemon";
        After = [ "graphical-session-pre.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "graphical-session.target" ];
      Service.ExecStart = "${pkgs.barrier}/bin/barriers --disable-crypto --no-daemon --address ${listen_ip} --config ${server_config}";
    };
}
