# ccg fish completion

# Disable file completion by default
complete -c ccg -f

# Top-level commands
complete -c ccg -n 'not __fish_seen_subcommand_from init add status commit push remote' \
    -a init    -d 'Set up Claude Code process separation'
complete -c ccg -n 'not __fish_seen_subcommand_from init add status commit push remote' \
    -a add     -d 'Stage files (auto-routes to product or claude repo)'
complete -c ccg -n 'not __fish_seen_subcommand_from init add status commit push remote' \
    -a status  -d 'Show status of both repos'
complete -c ccg -n 'not __fish_seen_subcommand_from init add status commit push remote' \
    -a commit  -d 'Commit both repos with one message'
complete -c ccg -n 'not __fish_seen_subcommand_from init add status commit push remote' \
    -a push    -d 'Push both repos'
complete -c ccg -n 'not __fish_seen_subcommand_from init add status commit push remote' \
    -a remote  -d 'Create/connect GitHub remotes'

# ccg add: complete files
complete -c ccg -n '__fish_seen_subcommand_from add' -F

# ccg commit: -m flag
complete -c ccg -n '__fish_seen_subcommand_from commit' -s m -d 'Commit message' -r
