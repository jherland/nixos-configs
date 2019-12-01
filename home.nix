# See home-configuration.nix(5) for available options

{ config, pkgs, ... }:

let
  # Personal info
  name = "Johan Herland";
  email = "johan@herland.net";
  username = "jherland";
in
{
  programs = {
    # Have home-manager manage itself.
    home-manager = {
      enable = true;
      path = "~/code/home-manager";
    };

    git = {
      enable = true;
      userName = "${name}";
      userEmail = "${email}";
      aliases = {
        glog = "log --graph --decorate --color --oneline";
        olog = "log --graph --decorate --color --oneline origin..";
        staged = "diff --staged";
        find= "!git ls-files | grep";
        branches = "!git --no-pager log --branches --no-walk --date-order --reverse --format='%C(auto)%h%d %Cred%cr%Creset %s'";
      };
      extraConfig = {
        color = {
          ui = "auto";
          interactive = {
            prompt     = "green  bold";
            header     = "cyan   bold";
            help       = "yellow bold";
          };
          diff = {
            plain      = "normal";
            meta       = "yellow bold";
            frag       = "yellow bold";
            old        = "red    bold";
            new        = "green  bold";
            commit     = "cyan   bold";
            whitespace = "red    ul";
          };
          status = {
            header     = "normal";
            added      = "green  bold";
            changed    = "red    bold";
            untracked  = "yellow bold";
          };
          branch = {
            plain      = "normal";
            current    = "green  bold";
            local      = "red    bold";
            remote     = "yellow bold";
          };
        };
        merge.conflictstyle = "diff3";
        push.default = "tracking";
        rebase.autosquash = true;
#       rerere.enabled = true;
        sendemail = {
          signedoffbycc = true;
          confirm = "always";
          chainreplyto = false;
          smtpserver = "smtp.gmail.com";
          smtpserverport = 587;
          smtpencryption = "tls";
          smtpuser = "jherland@gmail.com";
        };
      };
    };
  };

#  # Allow fontconfig to discover fonts and configurations installed through home.packages and nix-env
#  fonts.fontconfig.enable = true;
#
#  # The set of packages to appear in the user environment
#  home.packages = [ ];
#
#  home.stateVersion = "19.09";
#
#  manual.html.enable = true;
#
#  programs.bash = {
#    enable = true;
#    enableAutoJump = true;
#    historyControl = "ignoredups";
}
