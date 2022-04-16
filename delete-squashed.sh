# https://github.com/not-an-aardvark/git-delete-squashed
set -e
MAIN_BRANCH=${1:-main}
git checkout -q $MAIN_BRANCH
git for-each-ref refs/heads/ "--format=%(refname:short)" | \
  while read branch
  do
    mergeBase=$(git merge-base $MAIN_BRANCH $branch)
    [[ $(git cherry $MAIN_BRANCH $(git commit-tree $(git rev-parse $branch\^{tree}) -p $mergeBase -m _)) == "-"* ]]
    git branch -D $branch
  done
