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
  programs.home-manager = {
    enable = true;
    path = "${hmdir}";
  };

  nixpkgs.config.allowUnfree = true;

  home = {
    file = {
      ".pypirc".source = ./pypirc;
    };

    language.base = "C.UTF-8";

    packages = with pkgs; [
      bash-completion
      curl
      file
      man-pages
      nix-index
      posix_man_pages
      pwgen
      (python3.withPackages (ps: with ps; [ black flake8 pytest ]))
      shellcheck
      sshfs-fuse
    ];

    stateVersion = "19.09";
  };

  programs = {
    bash = {
      enable = true;
      # enableAutojump = true;
      historyControl = ["ignoredups"];
      initExtra = ''
        source ${hmdir}/bash/acd_func.sh
      '';
      shellAliases = {
          ls = "ls --color=auto";
          d = "ls -alF --color=auto";
          nano = "nano -w";
          top = "htop";
          diff = "git diff --no-index";
          dmesg = "dmesg --human";
          cat = "bat";
      };
    };

    bat.enable = true;

    direnv = {
      enable = true;
      enableNixDirenvIntegration = true;
    };

    gh = {
        enable = true;
        gitProtocol = "ssh";
    };

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "${name}";
      userEmail = "${email}";
      aliases = {
        glog = "log --graph --decorate --color --oneline";
        loga = "log --graph --decorate --color --oneline --all";
        logu = "log --graph --decorate --color --oneline --boundary HEAD@{u}..";
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
        diff.colorMoved = "zebra";
        merge.conflictstyle = "diff3";
        pull.rebase = true;
        push.default = "tracking";
        rebase.autosquash = true;
        rebase.autostash = true;
        repack.writeBitmaps = true;
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
      # delta.enable = true;
      ignores = [ "/.vscode/" ];
    };

    htop = {
      enable = true;
      cpuCountFromZero = true;
      detailedCpuTime = true;
      headerMargin = false;
      hideUserlandThreads = true;
      highlightBaseName = true;
      shadowOtherUsers = true;
      showProgramPath = false;
      showThreadNames = true;
      meters = {
        left = [ "CPU" "Memory" "Swap" "Battery" "Blank" "Tasks" "LoadAverage" "Uptime" ];
        right = ["AllCPUs2"];
      };
    };

    man.enable = true;

    starship = {
      enable = true;
      settings = {
        # See https://starship.rs/config for available config directives
        add_newline = false;
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

    tmux = {
      enable = true;
      aggressiveResize = true;
      clock24 = true;
      historyLimit = 10000;
      shortcut = "a";
      # terminal = "screen-256color";
    };
  };
}
