# Releasing

A release is a `vX.Y.Z` tag. Pushing it runs the **Publish** workflow, which publishes every
package to pub.dev under that version, in dependency order. All packages always share one version.

The very first release is different: it is published by hand, then automated publishing is turned
on. See [The first release](#the-first-release).

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
    - About an hour later, each package's **Scores** tab on pub.dev shows 160 points, or explains
      what costs points.
    - The example app builds against the published packages.

A version on pub.dev is permanent. For 7 days after publishing it can be *retracted*, which hides it
from new installs, but it can never be replaced or deleted. When a release is wrong, fix it forward
with the next version. A package name, once published, is reserved for good.

## The first release

pub.dev turns on automated publishing only for packages that already exist, so the first version is
published by hand, from your machine.

1. **Sign in.** Open [pub.dev](https://pub.dev) and sign in with the Google account that should own
   the packages. Then log the command line in; it opens a browser to confirm:

    ```bash
    dart pub login
    ```

   A *verified publisher* (a badge such as `example.dev` instead of your email) needs a domain you
   own, verified with a DNS record in Google Search Console; a `github.io` address can't be
   verified. It is optional: packages can move to a publisher later, from each package's admin page.
2. **Check everything passes,** as in step 4 above, with a clean working tree.
3. **Publish each package, in this order.** A package can only go up once the packages it depends
   on are on pub.dev, which takes seconds. Each command shows what it will upload and asks to
   confirm. Use `flutter pub publish`, not `dart pub publish`: the vendor packages depend on Flutter.

    ```bash
    for package in herald herald_testing herald_log \
        herald_firebase herald_adjust herald_mixpanel herald_appsflyer herald_amplitude; do
      (cd "packages/$package" && flutter pub publish)
    done
    ```

4. **Don't tag this version.** Pushing its `v…` tag would start the Publish workflow, which fails
   because the version already exists. The first tagged release is the next version.
5. **Create the `pub.dev` environment** in the GitHub repository: *Settings → Environments → New
   environment*, named `pub.dev`. Under its deployment rules, allow only tags matching `v*`. Adding
   yourself as a required reviewer makes every release wait for your approval.
6. **Turn on automated publishing for each package.** On `https://pub.dev/packages/<package>/admin`,
   under *Automated publishing*, choose *Enable publishing from GitHub Actions* with:
    - repository: `MkhytarMkhoian/herald-flutter`;
    - tag pattern: `v{{version}}`;
    - *Require GitHub Actions environment*: `pub.dev`.

   No password or token is stored: GitHub proves to pub.dev that the run came from this
   repository's tag.
7. **Release the next version with the steps above,** to check the workflow end to end.
