#!/usr/bin/env bash

set -euo pipefail

root_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
pdf=${1:-"$root_dir/thesis.pdf"}
case "$pdf" in
  /*) ;;
  *) pdf="$PWD/$pdf" ;;
esac

cache_dir=${CUNI_VALIDATOR_CACHE:-"$root_dir/.cache/cuni-thesis-validator"}
report_dir=${CUNI_VALIDATOR_REPORT_DIR:-"$root_dir/validation"}

validator_commit=3a3ae11f99ef9dd5b7ed6e92108256554b38a6f0
profile_name=UK-7987-version1-custom9.xml
profile_sha256=007c70396fe57f82eee136d76148a17664c2a3ac76a05dcac49e0631fcfbf3d6
compatible_profile_sha256=71fa33995b43b298d597fc87b3c0338bfa38e97ba183c32f92342d2650125ca9
verapdf_version=1.30.2
verapdf_zip_sha256=6cc6341cb1af644044054b81f00a6590a7918abb18f762243de115258bcad838

profile_url="https://raw.githubusercontent.com/mff-cuni-cz/cuni-thesis-validator/$validator_commit/$profile_name"
verapdf_url="https://software.verapdf.org/rel/1.30/verapdf-greenfield-$verapdf_version-installer.zip"

for command in curl java sed sha256sum unzip grep; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    exit 2
  fi
done

if [[ ! -f "$pdf" ]]; then
  echo "PDF not found: $pdf" >&2
  exit 2
fi

mkdir -p "$cache_dir" "$report_dir"

download_checked() {
  local url=$1
  local sha256=$2
  local destination=$3

  if [[ -f "$destination" ]] &&
      printf '%s  %s\n' "$sha256" "$destination" | sha256sum --check --status; then
    return
  fi

  rm -f "$destination" "$destination.part"
  echo "Downloading $url"
  curl --fail --location --output "$destination.part" "$url"
  printf '%s  %s\n' "$sha256" "$destination.part" | sha256sum --check --status
  mv "$destination.part" "$destination"
}

official_profile="$cache_dir/$profile_name"
compatible_profile="$cache_dir/UK-7987-version1-custom9-verapdf-1.30.xml"
download_checked "$profile_url" "$profile_sha256" "$official_profile"

# The repository's current profile predates two veraPDF 1.30 model-property
# renames. These expression-only substitutions preserve the university rules:
# a TR key must be absent, and TR2 must be absent or have the value Default.
if [[ ! -f "$compatible_profile" ]] ||
    ! printf '%s  %s\n' "$compatible_profile_sha256" "$compatible_profile" |
      sha256sum --check --status; then
  cp "$official_profile" "$compatible_profile"
  sed -i \
    -e 's#<test>TR == null</test>#<test>containsTR == false</test>#' \
    -e 's#<test>TR2 == null || TR2 == \&quot;Default\&quot;</test>#<test>containsTR2 == false || TR2NameValue == \&quot;Default\&quot;</test>#' \
    -e 's#<argument>TR2</argument>#<argument>TR2NameValue</argument>#' \
    "$compatible_profile"
  printf '%s  %s\n' "$compatible_profile_sha256" "$compatible_profile" |
    sha256sum --check --status
fi

verapdf_home="$cache_dir/verapdf-$verapdf_version"
verapdf="$verapdf_home/verapdf"

if [[ ! -x "$verapdf" ]]; then
  installer_zip="$cache_dir/verapdf-greenfield-$verapdf_version-installer.zip"
  installer_dir="$cache_dir/verapdf-installer-$verapdf_version"
  auto_install="$cache_dir/verapdf-auto-install-$verapdf_version.xml"

  download_checked "$verapdf_url" "$verapdf_zip_sha256" "$installer_zip"
  rm -rf "$installer_dir" "$verapdf_home"
  mkdir -p "$installer_dir"
  unzip -q "$installer_zip" -d "$installer_dir"

  cat >"$auto_install" <<EOF
<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<AutomatedInstallation langpack="eng">
  <com.izforge.izpack.panels.htmlhello.HTMLHelloPanel id="welcome"/>
  <com.izforge.izpack.panels.target.TargetPanel id="install_dir">
    <installpath>$verapdf_home</installpath>
  </com.izforge.izpack.panels.target.TargetPanel>
  <com.izforge.izpack.panels.packs.PacksPanel id="sdk_pack_select">
    <pack index="0" name="veraPDF GUI" selected="false"/>
    <pack index="1" name="veraPDF CLI" selected="true"/>
    <pack index="2" name="veraPDF Documentation" selected="false"/>
    <pack index="3" name="veraPDF Sample Plugins" selected="false"/>
  </com.izforge.izpack.panels.packs.PacksPanel>
  <com.izforge.izpack.panels.install.InstallPanel id="install"/>
  <com.izforge.izpack.panels.finish.FinishPanel id="finish"/>
</AutomatedInstallation>
EOF

  java -jar \
    "$installer_dir/verapdf-greenfield-$verapdf_version/verapdf-izpack-installer-$verapdf_version.jar" \
    "$auto_install"
fi

validate() {
  local label=$1
  local report=$2
  shift 2

  echo "Validating $label"
  HOME="$cache_dir" "$verapdf" --format xml "$@" "$pdf" >"$report.tmp"
  mv "$report.tmp" "$report"

  if ! grep -q 'validationReports compliant="1" nonCompliant="0" failedJobs="0"' "$report"; then
    grep 'validationReport\|validationReports' "$report" >&2 || true
    echo "$label validation failed; full report: $report" >&2
    return 1
  fi

  grep 'validationReports ' "$report"
  echo "Report: $report"
}

validate "standard PDF/A-2u" "$report_dir/thesis-pdfa-2u.xml" --flavour 2u
validate "Charles University custom profile" "$report_dir/thesis-cuni.xml" \
  --profile "$compatible_profile"

echo "PDF/A-2u validation passed: $pdf"
