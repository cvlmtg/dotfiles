function git_prompt
  if git rev-parse --is-inside-work-tree &>/dev/null
    set -l branch (git branch --show-current 2>/dev/null)
    set -l dirty (git status --porcelain 2>/dev/null)
    set -l color

    # uncommitted changes or untracked files
    if test -n "$dirty"
      set color (set_color red)
    else
      set -l ahead (git status --porcelain --branch 2>/dev/null | grep -c '\[ahead ')

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
