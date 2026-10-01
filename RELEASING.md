# Releasing

A release is a `vX.Y.Z` tag. Pushing it runs the **Publish** workflow, which publishes every
package to pub.dev under that version, in dependency order. All packages always share one version.

## Steps

1. **Update `CHANGELOG.md`.**
    - Under `## Version X.Y.Z`, replace `_Unreleased_` with the release date, `_YYYY-MM-DD_`.
    - Check that every change a user would notice is listed, each starting with `New:`, `Fix:`,
      `Upgrade:` or `Breaking:`.
2. **Set the version in every package.** Melos bumps each package's `version` and the constraints
   between them together, and adds the entry to each package's `CHANGELOG.md`:

    ```bash
    dart run melos version --manual-version herald:X.Y.Z --yes --no-git-tag-version
    ```

   Check that every `packages/*/pubspec.yaml` now says `version: X.Y.Z`. The workflow refuses to
   publish otherwise.
3. **Update the version shown to readers,** in the install snippets of `README.md`.
4. **Check that everything passes:**

    ```bash
    dart run melos run format:check
    dart run melos run analyze
    dart run melos run test
    dart run melos run publish:dry
    ```

5. **Commit, tag and push:**

    ```bash
    git commit -am "Release X.Y.Z"
    git tag vX.Y.Z
    git push origin main vX.Y.Z
    ```

6. **Verify:**
    - The Publish workflow is green on the tag.
    - Every package shows `X.Y.Z` on pub.dev: `https://pub.dev/packages/herald`.
    - The example app builds against the published packages.

A version on pub.dev is permanent: it can be retracted but never replaced. When a release is wrong,
fix it forward with the next patch version.

## One-time setup

- **Publish each package once by hand.** pub.dev's automated publishing can only be turned on for a
  package that exists. For the first release, run `flutter pub publish` in each package directory,
  in the order the workflow uses.
- **Turn on automated publishing** on each package's pub.dev admin page: *Publish from GitHub
  Actions*, repository `MkhytarMkhoian/herald-flutter`, tag pattern `v{{version}}`, and require the
  `pub.dev` environment.
- **Create the `pub.dev` environment** in the repository's settings, so a publish can be limited to
  tags and, if you like, need an approval.
