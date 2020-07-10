git branch auto_commit
git checkout auto_commit
git reset --mixed "origin/master"
git add SCR_Tracker.xlsx
git commit -m "auto commit scr status file"
git push -u --recurse-submodules=check --progress "origin" refs/heads/auto_commit:refs/heads/master
git checkout --force -B "master" "origin/master"
git branch -d "auto_commit"