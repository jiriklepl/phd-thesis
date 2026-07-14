#!/usr/bin/env bash

set -euo pipefail

root_dir=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
output=${1:-"$root_dir/phd-thesis-artifacts.zip"}
case "$output" in
  /*) ;;
  *) output="$PWD/$output" ;;
esac

for command in find git grep zip; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing required command: $command" >&2
    exit 2
  fi
done

mkdir -p "$(dirname -- "$output")"
work_dir=$(mktemp -d "${TMPDIR:-/tmp}/phd-thesis-artifacts.XXXXXX")
trap 'rm -rf "$work_dir"' EXIT

archive_root="$work_dir/phd-thesis-artifacts"
mkdir -p "$archive_root"

# directory|repository|ref|description
repositories=(
  "noarr-structures|https://github.com/ParaCoToUl/noarr-structures.git||Noarr: C++20 library for layout- and traversal-agnostic data structures and algorithms."
  "noarr-tuning|https://github.com/ParaCoToUl/noarr-tuning.git||Autotuning integration for Noarr layouts and traversals."
  "noarr-mpi|https://github.com/ParaCoToUl/noarr-mpi.git||Noarr MPI extensions for layout-agnostic datatype construction and distributed communication."
  "cellato|https://github.com/ParaCoToUl/cellato.git||Cellato: C++20 embedded DSL and CPU/CUDA implementations for cellular automata and stencil computations."
)

readme="$archive_root/README.md"
{
  echo "# PhD thesis software artifacts"
  echo
  echo "This archive collects the open-source software and experimental repositories referenced by the thesis. Each directory is a source snapshot; Git metadata has been removed, and external dependencies and submodules are not bundled. Consult the README file in each directory for further information about the repository and its contents."
  echo
  echo "## Repository map"
  echo
  echo "- **Noarr ecosystem:** \`noarr-structures\` is the core Noarr library; \`noarr-tuning\` and \`noarr-mpi\` provide autotuning and distributed-memory extensions."
  echo "- **Cellato:** \`cellato\` contains the Cellato library for cellular automata; includes Cellato DSL with components for efficient CPU and CUDA implementations and implementations of the automata used in benchmarks."
  echo
  echo "## Source snapshots"
  echo
  echo "Generated on $(date -u +%Y-%m-%d) from the following revisions:"
  echo
  echo "| Directory | Revision | Source | Description |"
  echo "| --- | --- | --- | --- |"
} >"$readme"

for repository in "${repositories[@]}"; do
  IFS='|' read -r directory url ref description <<<"$repository"
  destination="$archive_root/$directory"

  echo "Cloning $url${ref:+ ($ref)}"
  clone_args=(--depth 1)
  if [[ -n "$ref" ]]; then
    clone_args+=(--branch "$ref" --single-branch)
  fi
  git clone "${clone_args[@]}" -- "$url" "$destination"

  if [[ -f "$destination/.gitattributes" ]] &&
      grep -q 'filter=lfs' "$destination/.gitattributes" &&
      ! git -C "$destination" lfs env >/dev/null 2>&1; then
    echo "Repository $url uses Git LFS, but git-lfs is unavailable." >&2
    exit 2
  fi

  revision=$(git -C "$destination" rev-parse HEAD)
  printf "| \`%s\` | \`%s\` | <%s> | %s |\n" \
    "$directory" "$revision" "${url%.git}" "$description" >>"$readme"
  while IFS= read -r -d '' git_metadata; do
    rm -rf -- "$git_metadata"
  done < <(find "$destination" -name .git -prune -print0)
done

archive_tmp="$work_dir/phd-thesis-artifacts.zip"
(
  cd "$work_dir"
  zip -q -r -y "$archive_tmp" "$(basename -- "$archive_root")"
)
mv -f -- "$archive_tmp" "$output"

echo "Created $output"
