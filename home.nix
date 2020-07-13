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
  # Allow fontconfig to discover fonts and configurations installed through home.packages and nix-env
  fonts.fontconfig.enable = true;

  home = {
    # Dotfiles for the home root, ~/
    file = {
      ".SpaceVim.d".source = ./SpaceVim.d;
      ".SpaceVim.d".onChange = "rm -rf ~/.cache/SpaceVim/conf";
    };

    language.base = "C.UTF-8";

    packages = with pkgs; [
      # fonts
      powerline-fonts

      (vivaldi.override {
        proprietaryCodecs = true;
        enableWidevine = true;
      })
      vivaldi-ffmpeg-codecs
      vivaldi-widevine

      vscode
    ];

    sessionVariables = {
      EDITOR = "vim";
    };

    stateVersion = "19.09";
  };

  manual.html.enable = true;

  programs = {
    autorandr = {
      enable = true;
      profiles = {
        home = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0006af3d3100000000001a0104a51f1178028d15a156529d280a505400000001010101010101010101010101010101143780b87038244010103e0035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414e30332e31200a003b";
            DP-1-1 = "00ffffffffffff000d3306a30000000028e00103801f11780eee91a3544c99260f505421080001010101010101010101010101010101023a801871382d40582c4500fe221100001e000000fd00313d1e460f000a202020202020000000fc00445837300a202020202020202000000010000000000000000000000000000001aa020318f146901f2204030123090707e200ea65030c001000011d007251d01e206e285500fe221100001e662156aa51001e30468f3300fe221100001e662150b051001b3040703600fe221100001e8c0ad08a20e02d10103e9600fe221100001e00000000000000000000000000000000000000000000000000000000000000eb";
            DP-1-2 = "00ffffffffffff0030aeda6101010101131d0104b53c22783e1c95a75549a2260f5054a10800d1c081c0810081809500a9c0b300d1004dd000a0f0703e803020350055502100001aa36600a0f0701f803020350055502100001a000000fd0017501ea03c010a202020202020000000fc004c454e20543237702d31300a2001a4020322f14d010203121113041490051f615f230907078301000067030c0010003878565e00a0a0a029503020350055502100001ae26800a0a0402e603020360055502100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000af";
          };
          config = {
            eDP-1 = {
              primary = true;
              mode = "1920x1080";
              position = "1920x1080";
            };
            DP-1-1 = {
              mode = "1920x1080";
              position = "0x1080";
            };
            DP-1-2 = {
              mode = "3840x2160";
              position = "3840x0";
            };
          };
        };
        mobile = {
          fingerprint = {
            eDP-1 = "00ffffffffffff0006af3d3100000000001a0104a51f1178028d15a156529d280a505400000001010101010101010101010101010101143780b87038244010103e0035ae100000180000000f0000000000000000000000000020000000fe0041554f0a202020202020202020000000fe004231343048414e30332e31200a003b";
          };
          config = {
            eDP-1 = {
              primary = true;
              mode = "1920x1080";
              position = "0x0";
            };
          };
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

    direnv.enable = true;

    firefox.enable = true;

    git = {
      enable = true;
      package = pkgs.gitAndTools.gitFull;
      userName = "${name}";
      userEmail = "${email}";
      aliases = {
        glog = "log --graph --decorate --color --oneline";
        ulog = "log --graph --decorate --color --oneline --boundary HEAD@{u}..";
        olog = "log --graph --decorate --color --oneline --boundary origin/master..";
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
        rebase.autostash = true;
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
      ignores = [ "/.vscode/" ];
    };

    home-manager = {
      enable = true;
      path = "${hmdir}";
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
        right = ["AllCPUs"];
      };
    };

    man.enable = true;

    # Install just enough of neovim to support SpaceVim
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
      ];
    };

    ssh = {
      enable = true;
      matchBlocks = {
        jherland = {
          hostname = "jherland.rd.cisco.com";
          forwardAgent = true;
          serverAliveInterval = 60;
        };
        rdbuild = {
          hostname = "rdbuild25.rd.cisco.com";
          forwardAgent = true;
          serverAliveInterval = 60;
        };
        phi = {
          hostname = "phi.herland";
          user = "johan";
        };
      };
    };

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

    # Nix, Y U NO HAZ SpaceVim!
    vim = {
      enable = false;
      plugins = with pkgs.vimPlugins; [
        syntastic
        gruvbox-community
      ];
      extraConfig = ''
        " Use vim settings, rather then vi settings (much better!)
        " This must be first, because it changes other options as a side effect.
        set nocompatible

        set t_Co=256            " terminal supports 256 color mode.
        set ai                  " auto indenting
        set history=100         " keep 100 lines of history
        set ruler               " show the cursor position
        syntax on               " syntax highlighting
        filetype plugin on      " use the file type plugins

        set showmode                    " always show what mode we're currently editing in

        set tabstop=4                   " a tab is four spaces
        set softtabstop=4               " when hitting <BS>, pretend like a tab is removed, even if spaces
        set expandtab                   " expand tabs to spaces by default
        set shiftwidth=4                " number of spaces to use for autoindenting
        set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
        set backspace=indent,eol,start  " allow backspacing over everything in insert mode
        set autoindent                  " always set autoindenting on
        set copyindent                  " copy the previous indentation on autoindenting

        set showmatch                   " set show matching parenthesis
        set smarttab                    " insert tabs on the start of a line according to
                                        "    shiftwidth, not tabstop
        set scrolloff=4                 " keep 4 lines off the edges of the screen when scrolling

        set hlsearch                    " highlight search terms
        set incsearch                   " show search matches as you type

        set mouse=a                     " enable using the mouse if terminal emulator supports it
        " Consider turning it off if it kills copy/paste

        " Editor layout {{{
        set termencoding=utf-8
        set encoding=utf-8
        set lazyredraw                  " don't update the display while executing macros
        set laststatus=2                " tell VIM to always put a status line in, even
                                        "    if there is only one window
        set cmdheight=1                 " use a status bar that is 1 rows high

        " Vim behaviour {{{
        set history=1000                " remember more commands and search history
        set undolevels=1000             " use many muchos levels of undo
        set undofile                    " keep a persistent backup file
        set undodir=~/.vim/.undo,~/tmp,/tmp
        set nobackup                    " do not keep backup files, it's 70's style cluttering
        set noswapfile                  " do not write annoying intermediate swap files,
                                        "    who did ever restore from swap files anyway?
        set directory=~/.vim/.tmp,~/tmp,/tmp
                                        " store swap files in one of these directories
                                        "    (in case swapfile is ever turned on)
        set viminfo='20,\"80            " read/write a .viminfo file, don't store more
                                        "    than 80 lines of registers
        set wildmenu                    " make tab completion for files/buffers act like bash
        set wildmode=list:full          " show a list when pressing tab and complete
                                        "    first full match
        set wildignore=*.swp,*.bak,*.pyc,*.class
        set title                       " change the terminal's title
        set visualbell                  " don't beep
        set noerrorbells                " don't beep
        set showcmd                     " show (partial) command in the last line of the screen
                                        "    this also shows visual selection info
        set nomodeline                  " disable mode lines (security measure)

        set hidden

        " Colors {{{
        set background=dark
        colorscheme gruvbox
        let g:gruvbox_contrast_dark = 'hard'

        " Syntastic {{{
        " set statusline+=%#warningmsg#
        " set statusline+=%{SyntasticStatuslineFlag()}
        " set statusline+=%*

        let g:syntastic_always_populate_loc_list = 1
        let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 1
        let g:syntastic_check_on_wq = 0
      '';
    };
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
  };

  # services.network-manager-applet.enable = true;

  # xsession = {
      # enable = true;
      # numlock.enable = true;
  # };
}
