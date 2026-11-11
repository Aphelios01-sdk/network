#!/usr/bin/env bash
# Stage one service's release notes in this repository as a draft release.
#
# Each release gets its own notes commit: GitHub dates a release by its commit and uses that
# date to order releases, so releases sharing a commit would all tie. A person publishes the
# draft. A published release is never changed; ship a new version instead.
set -euo pipefail

die() {
  echo "stage-release: $*" >&2
  exit 1
}

: "${SERVICE:?}" "${VERSION:?}" "${NOTES:?}" "${SOURCE_REPO:?}" "${TARGET_REPO:?}"
sources="$(dirname "$0")/../release-sources.txt"

[[ $SERVICE =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "bad service name: $SERVICE"
[[ $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$ ]] || die "bad version: $VERSION"
grep -qxF "$SERVICE $SOURCE_REPO" "$sources" ||
  die "$SOURCE_REPO may not publish $SERVICE; add it to .github/release-sources.txt"
[[ -n ${NOTES//[[:space:]]/} ]] || die "notes are empty"

# Everything here is public, so anything that looks internal stops the release.
if grep -qiE 'flop-labs/flop-core|\.ts\.flop\.network|\b([0-9]{1,3}\.){3}[0-9]{1,3}\b' <<<"$NOTES"; then
  die "notes mention a private repo, internal host or IP address"
fi

tag="$SERVICE/$VERSION"
path="releases/$SERVICE/$VERSION.md"

release=$(gh api --paginate "repos/$TARGET_REPO/releases?per_page=100" \
  --jq ".[] | select(.tag_name == \"$tag\") | [.id, .draft] | @tsv")
release_id=${release%%$'\t'*}
if [[ -n $release && ${release#*$'\t'} != true ]]; then
  die "$tag is already published; ship a new version"
fi

# A missing file is the normal first run. Any other lookup failure leaves file_sha empty too,
# and the write below then fails rather than overwrites.
file_sha=$(gh api "repos/$TARGET_REPO/contents/$path" --jq .sha 2>/dev/null || true)
put_body=$(jq -n --arg message "release: $SERVICE $VERSION" --arg notes "$NOTES" --arg sha "$file_sha" \
  '{message: $message, content: ($notes | @base64), branch: "main"}
   + (if $sha == "" then {} else {sha: $sha} end)')
# Releases of different services stage in parallel, and a write that lands while main moves
# can be rejected with a conflict. Retry a few times; anything still failing stops the run.
commit=""
for attempt in 1 2 3; do
  if commit=$(gh api -X PUT "repos/$TARGET_REPO/contents/$path" --input - --jq .commit.sha <<<"$put_body"); then
    break
  fi
  commit=""
  [[ $attempt == 3 ]] || sleep $((attempt * 5))
done
[[ -n $commit ]] || die "could not commit $path"

body=$(jq -n --arg tag "$tag" --arg commit "$commit" --arg name "$SERVICE $VERSION" --arg notes "$NOTES" \
  '{tag_name: $tag, target_commitish: $commit, name: $name, body: $notes, draft: true,
    make_latest: "false"}')
if [[ -n $release ]]; then
  gh api -X PATCH "repos/$TARGET_REPO/releases/$release_id" --input - --silent <<<"$body"
else
  gh api -X POST "repos/$TARGET_REPO/releases" --input - --silent <<<"$body"
fi
echo "staged draft release $tag at $commit"
