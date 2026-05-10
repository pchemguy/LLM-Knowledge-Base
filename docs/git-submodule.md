# Add git submodule with custom folder name

1. Create target folder, e.g., `resources/gowtham0992/Link`
2. Run

```
git submodule add --name Link https://github.com/gowtham0992/link.git resources/gowtham0992
```

By default, `git submodule add <git url> <prefix>` will create the `link` subfolder (from the `link.git` part) `<prefix>/link` and will clone the submodule into this subfolder. When `--name <NAME>` is supplied, it will be used as the submodule root directory name.
