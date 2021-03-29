{ pkgs, ... }:

{
  home = {
    file = {
      ".SpaceVim.d".source = ./SpaceVim.d;
      ".SpaceVim.d".onChange = "rm -rf ~/.cache/SpaceVim/conf";
    };

    sessionVariables = {
      EDITOR = "vim";
    };
  };

  programs = {
    # Install just enough of neovim to support SpaceVim
    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; [
      ];
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
}
