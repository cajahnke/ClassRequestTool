# Development Notes

## Git Workflow Conventions

At any point in time, there are several git branches that can be meaningful to general developers.

| Branch | Description |
| ------ | ----------- |
| master | Stable branch.  We tag releases for internal purposes, but the tip of master should be considered stable at all times. |
| dev    | Development branch. New work should generally be rebased onto the tip of this; all code goes into dev before being merged into master. |
| ltsclasreq-N<sub><a href="#fn-1" name="tg-1">1</a></sub> | Topic branches. These are feature branches being worked on by Harvard devs.  They should NOT have work based on them; they are subject to rebase/deletion at any time. |

All changes propagate, ideally, in one of two fashions:
  * topic branch → dev → master
  * pull request → dev → master

Summary - anything other than `dev` or `master` can be rebased or deleted at any time.

## Git Integration

A git pre-commit hook is provided whose purpose is to keep those pesky 'console.log' and 'binding.pry' statements  out of the repository.

To install:

```Shell
  ln -s /path/to/CRT/pre-commit.sh .git/hooks/pre-commit
```

You can suppress the pre-commit hook by doing:

```Shell
  git commit --no-verify
```

... but in general, don't.

---

<a href="#tg-1" name="fn-1">1</a> - Where N is a number.
