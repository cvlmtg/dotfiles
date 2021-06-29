function git_prompt
    if command git rev-parse --show-toplevel >/dev/null 2>/dev/null
        set -l branch (command git branch 2>/dev/null | sed -n '/\* /s///p')
        set -l dirty  (command git status --porcelain 2>/dev/null | wc -l)
        set -l color

        # uncommitted changes or untracked files
        if test $dirty -ne 0
            set color (set_color red)
        else
            set -l ahead (command git log '@{u}..HEAD' --oneline 2>/dev/null | wc -l)

            # we are ahead of the remote branch (unpushed commits)
            if test $ahead -ne 0
                set color (set_color blue)
            else
                set color (set_color yellow)
            end
        end

        printf ' (%s%s%s)' $color $branch (set_color normal)
    end
end

function fish_prompt --description 'Write out the prompt'
    set -l last_status $status

    git_prompt

    if test $last_status -eq 0
        set_color $fish_color_cwd
    else
        set_color $fish_color_error
    end

    printf ' %s ' (prompt_pwd)
    if test $USER = 'root'
        set_color red
        printf '# '
    end

    set_color normal
end
