# herdr-reviewer

A Herdr mod, distributed by people copying `mods/reviewer/` or letting the
agent in their Herdr window fetch it from herdr.dev. There is no package
manager, so the version has to live in the files themselves.

## Releasing

The version is the `version` field in `mods/reviewer/mod.json`. Each release
is an annotated tag `v<version>` on master pointing at the commit that set
that field.

For every change a user would notice (behaviour, command names, props,
keys), in the same commit or PR:

1. Bump `version` in `mods/reviewer/mod.json`.
2. Update the Versions section of `README.md` with the Herdr version it was
   tested on (`herdr-app --version` and `herdr --version`).
3. Run `herdr-app check mods/reviewer` and try the mod in the app.
4. Keep `RECIPE.md` in step with the code; on a mismatched Herdr version the
   recipe is what users get.

After it lands on master:

```
git tag -a v<version> -m "reviewer <version>"
git push origin master v<version>
```

Patch for fixes, minor for new behaviour. No changelog until a release
changes something users must read about before upgrading. When Herdr
ships a new `changes` mod, port what is wanted and update `cloned_from`.

## Commits

Never add Co-Authored-By trailers or "Generated with" lines to commits or
PR descriptions.
