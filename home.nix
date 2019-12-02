# See home-configuration.nix(5) for available options

{ config, pkgs, ... }:

let
  # Personal info
  name = "Johan Herland";
  email = "johan@herland.net";
  username = "jherland";
  hmdir = "~/code/home-manager";
in
{
  home.stateVersion = "19.09";

  home.packages = [
  ];

  manual.html.enable = true;

  programs = {
    home-manager = {
      enable = true;
      path = "${hmdir}";
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

    bash = {
      enable = true;
      enableAutojump = true;
      historyControl = ["ignoredups"];
      initExtra = ''
        source ${hmdir}/bash/acd_func.sh
        export PS1='\[\033[01;32m\]\u@\h\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]$(__git_ps1 " \[\033[01;33m\](%s)\[\033[00m\]") \$ '
      '';
      sessionVariables = {
        EDITOR = "vim";
        GIT_PS1_SHOWDIRTYSTATE = 1;
#       PS1 = "\\[\\033[01;32m\\]\\u@\\h\\[\\033[00m\\] \\[\\033[01;34m\\]\\w\\[\\033[00m\\]$(__git_ps1 \" \\[\\033[01;33m\\](%s)\\[\\033[00m\\]\") \\$ ";
      };
      shellAliases = {
          ls = "ls --color=auto";
          d = "ls -alF --color=auto";
          nano = "nano -w";
          top = "htop";
          diff = "git diff --no-index";
          dmesg = "dmesg --human";
          cat = "bat";
          vi = "vim";
      };
    };

    bat.enable = true;

    firefox.enable = true;

    htop = {
      enable = true;
      cpuCountFromZero = true;
      detailedCpuTime = true;
      headerMargin = false;
      highlightBaseName = true;
      shadowOtherUsers = true;
      showProgramPath = false;
      showThreadNames = true;
      meters = {
        left = [ "CPU" "Memory" "Swap" "Battery" "Blank" "Tasks" "LoadAverage" "Uptime" ];
        right = ["AllCPUs"];
      };
    };

    man.enable = true;

    ssh = {
      enable = true;
      matchBlocks = {
        phi = {
          # host = "phi";
          hostname = "phi.herland";
          user = "johan";
        };
      };
    };
  };

#  # Allow fontconfig to discover fonts and configurations installed through home.packages and nix-env
#  fonts.fontconfig.enable = true;
#
#  # The set of packages to appear in the user environment
#
}
