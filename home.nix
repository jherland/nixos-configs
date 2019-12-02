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
        # rerere.enabled = true;
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
      '';
      sessionVariables = {
        EDITOR = "vim";
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

    starship = {
      enable = true;
      settings = {
        # See https://starship.rs/config for available config directives
        add_newline = false;
        prompt_order = [
          "username"
          "hostname"
          "kubernetes"
          "directory"
          "git_branch"
          "git_state"
          "git_status"
          "package"
          "dotnet"
          "golang"
          "java"
          "nodejs"
          "python"
          "ruby"
          "rust"
          "nix_shell"
          "conda"
          "aws"
          "env_var"
          "cmd_duration"
          "time"
          "line_break"
          "jobs"
          "battery"
          "memory_usage"
          "character"
        ];
        username.show_always = true;
        username.style_user = "bold green";
        hostname.ssh_only = false;
        hostname.style = "bold green";
        directory.truncation_length = 10;
        directory.style = "bold blue";
        git_branch.symbol = " ";
        git_branch.style = "bold yellow";
        git_state.style = "bold yellow";
        git_status.style = "bold yellow";
        git_status.prefix = "";
        git_status.suffix = " ";
        python.symbol = "🐍";
        python.style = "cyan";
        nix_shell.use_name = true;
        nix_shell.impure_msg = "✖";
        nix_shell.pure_msg = "✔";
        nix_shell.style = "cyan";
        cmd_duration.prefix = "🕙";
        cmd_duration.style = "bold black";
        memory_usage.disabled = false;
        memory_usage.show_swap = false;
        memory_usage.threshold = 75;
        memory_usage.symbol = "🐏";
        memory_usage.style = "bold red";
        character.use_symbol_for_status = true;
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
          hostname = "phi.herland";
          user = "johan";
        };
      };
    };
  };

#  # Allow fontconfig to discover fonts and configurations installed through home.packages and nix-env
#  fonts.fontconfig.enable = true;
}
