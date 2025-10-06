# ~/.bash_profile - Bash login shell configuration
# Executed for login shells

# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Environment variables for login shells
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Homebrew on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Homebrew on Linux
if [[ -d "/home/linuxbrew/.linuxbrew" ]]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi