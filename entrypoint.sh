#!/bin/bash
# shellcheck disable=SC2086

set -e

cd "${GITHUB_WORKSPACE}/${INPUT_WORKDIR}" || exit 1

echo '::group:: ls'
ls -alrtF
echo '::endgroup::'

TEMP_PATH="$(mktemp -d)"

# https://github.com/get-woke/woke
# if we need to rebuild woke command
echo '::group:: Installing woke ...'
if [ -n "$INPUT_WOKE_VERSION" ]; then
  if [[ "$INPUT_WOKE_VERSION" =~ ^[a-z0-9.]+$ ]]; then
    echo INFO: Using input version "$INPUT_WOKE_VERSION"
  else
    echo ERROR: Invalid INPUT_WOKE_VERSION "$INPUT_WOKE_VERSION"
    exit 1
  fi
else
  echo ERROR: INPUT_WOKE_VERSION must be specified
  exit 1
fi
url="https://raw.githubusercontent.com/linux-system-roles/lsr-woke-action/$INPUT_WOKE_VERSION/woke"
if ! curl --fail "$url" -o "${TEMP_PATH}/woke" || [ ! -s "${TEMP_PATH}/woke" ]; then
   echo ERROR: Could not download woke command
   exit 1
fi
chmod 0755 "${TEMP_PATH}/woke"
echo '::endgroup::'

echo '::group:: Running woke ...'
"${TEMP_PATH}/woke" \
  --output github-actions \
  --exit-1-on-failure="${INPUT_FAIL_ON_ERROR:-false}" \
  ${INPUT_WOKE_ARGS}
echo '::endgroup::'
