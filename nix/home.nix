{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = builtins.getEnv "USER";
  home.homeDirectory = builtins.getEnv "HOME";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Packages to install
  home.packages = with pkgs; [
    # Core utilities
    bat
    eza
    ripgrep
    fd
    fzf
    zoxide
    sd

    # Data tools
    jq
    yq-go

    # Development
    neovim
    tree-sitter
    tmux
    starship
    direnv
    mise
    just
    uv

    # Git tools
    delta
    lazygit
    git-absorb

    # HTTP
    xh

    # Utilities
    tldr
    atuin

    # System monitoring
    procs
    bottom
    du-dust
    duf

    # Performance
    hyperfine
    tokei
  ];

  # Git configuration
  programs.git = {
    enable = true;
    delta.enable = true;
    extraConfig = {
      core.editor = "nvim";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
    };
  };

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initExtra = ''
      # Load custom .zshrc if it exists
      if [ -f ~/.zshrc ]; then
        source ~/.zshrc
      fi
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  # Zoxide
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # Bat (cat replacement)
  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      style = "numbers,changes,header";
    };
  };

  # Fzf
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --strip-cwd-prefix --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 60%"
      "--layout=reverse"
      "--border=rounded"
      "--inline-info"
      "--preview 'bat --color=always --style=header,grid --line-range :300 {}'"
      "--preview-window=right:50%:wrap"
    ];
  };

  # Atuin
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      search_mode = "fuzzy";
    };
  };

  # Tmux
  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    prefix = "C-a";
    keyMode = "vi";
    mouse = true;
    baseIndex = 1;
    extraConfig = ''
      # Source custom tmux.conf if it exists
      if-shell "test -f ~/.tmux.conf" "source ~/.tmux.conf"
    '';
  };

  # Eza aliases
  home.shellAliases = {
    ls = "eza --icons --group-directories-first";
    ll = "eza -la --icons --group-directories-first";
    la = "eza -a --icons --group-directories-first";
    lt = "eza --tree --level=2 --icons";
    cat = "bat";
  };

  # Environment variables
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    PAGER = "less";
  };
}
