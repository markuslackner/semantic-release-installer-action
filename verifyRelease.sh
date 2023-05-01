#!/usr/bin/env bash

echo "TODO: outsource this scripts to a dedicated semantic-release plugin!"

nextReleaseVersion=${1}

lastReleaseVersion=${2}
lastReleaseGitTag=${3}
lastReleaseGitHead=${4}

commitLintingEnabled=${5}
verifyDryRunVersion=${6}

## NextRelease Version
echo "NEXT_RELEASE_VERSION=${nextReleaseVersion}"
echo "NEXT_RELEASE_VERSION=${nextReleaseVersion}" >> $GITHUB_ENV

## Verify DryRun Version with next Release Version
if [[ ${verifyDryRunVersion} && ${verifyDryRunVersion} == 'true' ]]; then
  echo "verification of dryrun version is enabled"
  if [[ ${VERSION_DRYRUN} ]]; then
    echo "version of dryRun-release: ${VERSION_DRYRUN}"
    echo "version of next-release: ${nextReleaseVersion}"
    if [[ ${VERSION_DRYRUN} != ${nextReleaseVersion} ]] ; then
      echo "dryRun-release version does not match the next release versions: ${VERSION_DRYRUN} != ${nextReleaseVersion}"
      echo "## 🔥Publishing Release failed: no valid commits available 😑👷" >> $GITHUB_STEP_SUMMARY
      echo "dryRun-release-version does not match the next-release-versions: ${VERSION_DRYRUN} != ${nextReleaseVersion}" >> $GITHUB_STEP_SUMMARY
      exit 1
    fi
  else
    echo "## 🔥Publishing Release failed: environment variable \$VERSION_DRYRUN not found 😑👷" >> $GITHUB_STEP_SUMMARY
    exit 1
  fi
else
  echo "verification of dryrun version is disabled, skipping it..."
fi

## Commit Linting
if [[ ${commitLintingEnabled} && ${commitLintingEnabled} == 'true' ]]; then
  echo "commitLinting is enabled"
  if [[ ${lastReleaseGitHead} ]]; then
    echo "lastRelease found: version=${lastReleaseVersion}, tag=${lastReleaseGitTag}, commit=${lastReleaseGitHead}"

    # linting messages of all commits since the last release tag
    #   => lint type-presets: https://github.com/conventional-changelog/commitlint/tree/master/%40commitlint/config-conventional#type-enum
    commitlint --from ${lastReleaseGitTag} --to HEAD --verbose
  else
    echo "lastRelease not available, skipping commit commit linting..."
  fi
else
    echo "commit linting is disabled, skipping it..."
fi


