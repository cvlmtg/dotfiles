# git tree

function gt
  git log --graph --oneline --exclude=refs/stash --all --date-order
end
