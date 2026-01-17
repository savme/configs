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

if test -f $HOME/.config/fish/extras.fish
    source $HOME/.config/fish/extras.fish
end

direnv hook fish | source
starship init fish | source
