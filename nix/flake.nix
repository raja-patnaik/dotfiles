{
  description = "Cross-platform development environment with modern CLI tools";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, home-manager, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        # Common development tools across all platforms
        devTools = with pkgs; [
          # Core utilities
          git
          git-lfs
          gh
          curl
          wget

          # Modern CLI replacements
          bat           # cat with syntax highlighting
          eza           # modern ls
          ripgrep       # fast grep
          fd            # fast find
          fzf           # fuzzy finder
          zoxide        # smart cd
          sd            # modern sed

          # Data tools
          jq            # JSON processor
          yq-go         # YAML processor

          # Development tools
          neovim
          tree-sitter   # parser generator tool
          tmux
          starship      # prompt
          direnv        # per-directory env vars
          mise          # runtime version manager
          just          # command runner
          uv            # fast Python package installer

          # Git tools
          delta         # beautiful diffs
          lazygit       # git TUI
          git-absorb    # automatic fixup commits

          # HTTP and networking
          xh            # user-friendly curl

          # Additional utilities
          tldr          # simplified man pages
          atuin         # shell history sync

          # System monitoring
          procs         # modern ps
          bottom        # system monitor
          du-dust       # disk usage
          duf           # disk free

          # Performance tools
          hyperfine     # benchmarking
          tokei         # code statistics

          # Shell enhancements
          zsh
          shellcheck    # shell script linting
          shfmt         # shell script formatting
        ];

      in
      {
        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs = devTools;

          shellHook = ''
            echo "🚀 Development environment loaded!"
            echo "Available tools: bat, eza, ripgrep, fd, fzf, and more..."

            # Initialize starship if available
            if command -v starship &>/dev/null; then
              eval "$(starship init bash)"
            fi

            # Initialize zoxide if available
            if command -v zoxide &>/dev/null; then
              eval "$(zoxide init bash)"
            fi

            # Initialize direnv if available
            if command -v direnv &>/dev/null; then
              eval "$(direnv hook bash)"
            fi

            # Initialize mise if available
            if command -v mise &>/dev/null; then
              eval "$(mise activate bash)"
            fi
          '';
        };

        # Package output for direct installation
        packages = {
          default = pkgs.buildEnv {
            name = "dotfiles-env";
            paths = devTools;
          };
        };

        # Home Manager configuration (optional)
        homeConfigurations = {
          # Replace 'username' with your actual username
          # Usage: home-manager switch --flake .#username
          username = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./home.nix ];
          };
        };
      }
    );
}
