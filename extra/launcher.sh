# Do not add "!/bin/bash" as it support both bash and zsh
# install:
#    echo source ~/.config/awesome/tyrannical/extra/launcher.sh > ~/.bashrc
# or:
#    echo source ~/.config/awesome/tyrannical/extra/launcher.sh > ~/.zshrc

function tyr() {
    ARGS="$1"
    RET="$2 "
    shift
    shift
    for arg in $@; do
        RET="$RET \"$arg\""
    done
    echo "require('awful').util.spawn('$RET',{$ARGS})" | awesome-client
}


alias tyrf="tyr floating=true"
alias tyrs="tyr sticky=true"
alias tyrt="tyr ontop=true"
alias tyrn="tyr new_tag=true"
alias tyri="tyr intrusive=true"
