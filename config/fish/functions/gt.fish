# git tree

function gt
  git log --graph --oneline --decorate --date=relative --exclude=refs/stash --all
end
