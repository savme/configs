function fish_greeting
end

export LANG="en_US.UTF-8"
export EDITOR=nvim

eval "$(/opt/homebrew/bin/brew shellenv)"

alias ll 'ls -lah'
alias vi nvim
alias vim nvim

abbr -a k kubectl
abbr -a g git

fish_add_path $HOME/.cargo/bin
fish_add_path "$(go env GOPATH)/bin"
fish_add_path /opt/homebrew/share/google-cloud-sdk/bin

if test -f $HOME/.config/fish/extras.fish
    source $HOME/.config/fish/extras.fish
end

direnv hook fish | source
starship init fish | source

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init2.fish 2>/dev/null || :
