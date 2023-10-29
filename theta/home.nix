# See home-configuration.nix(5) for available options

{ config, pkgs, ... }:

let
  # Personal info
  name = "Turid Herland";
  email = "turid.herland@gmail.com";
  username = "turid";
  hmdir = "~/code/nixos-configs";
in
{
  programs.home-manager.enable = true;

  nixpkgs.config.allowUnfree = true;

  home = {
    homeDirectory = "/home/${username}";
    language.base = "C.UTF-8";
    packages = with pkgs; [
      bash-completion
      curl
      file
      jq
      man-pages
      posix_man_pages
      (python3.withPackages (ps: with ps; [ black flake8 pytest ]))
      unzip

      # IDEs
      kate  # kwrite
      vscode

      # Media consumption
      gwenview
      vlc

      # Misc.
      ark
      libreoffice-qt
      okular
      spectacle
      yubikey-manager-qt

      # Fonts
      font-awesome
      powerline-fonts

      # Turid's stuff
      sage
      # LaTeX:
      (pkgs.texlive.combine {
        inherit (pkgs.texlive) scheme-small
          enumitem
          environ
          fontawesome5
          ifmtarg
          minted
          smartdiagram
          sourcesanspro
          tcolorbox
          xifthen
          xstring
        ;
      })
    ];
    stateVersion = "22.05";
    username = "${username}";
  };

  programs = {
    bash = {
      enable = true;
      # enableAutojump = true;
      historyControl = ["ignoredups"];
      initExtra = ''
        source ${hmdir}/dotfiles/bin/acd_func.sh
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
      enable = false;
      nix-direnv.enable = true;
    };

    gh = {
        enable = false;
        settings.git_protocol = "ssh";
    };

    git = {
      enable = true;
      lfs.enable = true;
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
        init.defaultBranch = "main";
        merge.conflictstyle = "diff3";
        pull.rebase = true;
        push.default = "tracking";
        rebase.autosquash = true;
        rebase.autostash = true;
        rebase.updateRefs = true;
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
      settings = {
        cpu_count_from_zero = true;
        detailed_cpu_time = true;
        header_margin = false;
        hide_userland_threads = true;
        highlight_base_name = true;
        shadow_other_users = true;
        show_program_path = false;
        show_thread_names = true;
        left_meters = [ "CPU" "Memory" "Swap" "Battery" "Blank" "Tasks" "LoadAverage" "Uptime" ];
        right_meters = ["AllCPUs2"];
      };
    };

    man.enable = true;

    nix-index.enable = true;

    starship = {
      enable = true;
      settings = {
        # See https://starship.rs/config for available config directives
        add_newline = false;
        username = {
          show_always = true;
          style_user = "bold green";
        };
        hostname = {
          ssh_only = false;
          style = "bold green";
        };
        directory = {
          truncation_length = 10;
          style = "bold blue";
        };
        git_branch = {
          symbol = " ";
          style = "bold yellow";
        };
        git_state.style = "bold yellow";
        git_status = {
          style = "bold yellow";
        };
        python = {
          symbol = "🐍";
          style = "cyan";
        };
        nix_shell = {
          format = "[$symbol$state( \($name\))]($style)";
          impure_msg = "✖";
          pure_msg = "✔";
          style = "cyan";
          symbol = "❄️";
        };
        cmd_duration = {
          format = " [🕙$duration]($style)";
          style = "bold black";
        };
        memory_usage = {
          disabled = false;
          format = "[$symbol $ram( \| $swap)]($style) ";
          style = "bold red";
          symbol = "🐏";
          threshold = 75;
        };
        character.error_symbol = "[✘](bold red)";
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

  # Allow fontconfig to discover fonts and configurations installed through
  # home.packages and nix-env
  fonts.fontconfig.enable = true;

  manual.html.enable = true;

  programs = {
    chromium = {
      enable = true;
      package = (pkgs.vivaldi.override {
        # Enable DRM media playback
        proprietaryCodecs = true;
        enableWidevine = true;
        # Make WebGL work when upgrading from v5.2 to v5.4
        commandLineArgs = "--use-gl=desktop";
      });
    };
    firefox.enable = true;
  };
}
