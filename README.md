# Optimizing Memory Layouts and Traversal Orders in High-Performance Computing

**PhD dissertation · Jiří Klepl · Charles University, Faculty of Mathematics and Physics · 2026**
Department of Distributed and Dependable Systems · Supervisor: Martin Kruliš

This repository contains the sources of my completed and successfully defended dissertation, together with defense materials and the papers included in the thesis.

The dissertation studies how to optimize memory layouts and traversal orders while keeping algorithmic logic independent of those choices. It develops C++ abstractions for parallel and distributed computation, explores autotuning and cellular automata optimization, and investigates LLM-guided optimization and the effects of abstractions and prompting strategies.

## Dissertation and defense

| Material | Links |
| --- | --- |
| Full dissertation | [Main LaTeX source](thesis.tex) · [Chapters](sources/full/) |
| Abbreviated dissertation (autoreferát) | [Main LaTeX source](thesis-short.tex) · [Chapters](sources/short/) |
| Abstracts | [English](abstracts/abstract-en.tex) · [Czech](abstracts/abstract-cs.tex) |
| Defense slides | [PDF (PPSplit)](defense/Optimizing%20Memory%20Layouts%20and%20Traversal%20Orders%20in%20High-Performance%20Computing%20%28PPSplit%29.pdf) · [PowerPoint](defense/Optimizing%20Memory%20Layouts%20and%20Traversal%20Orders%20in%20High-Performance%20Computing.pptx) · [PowerPoint (PPSplit)](defense/Optimizing%20Memory%20Layouts%20and%20Traversal%20Orders%20in%20High-Performance%20Computing%20%28PPSplit%29.pptx) |
| Dissertation reviews | [Review 1](defense/dissertation-review-1.pdf) · [Review 2](defense/dissertation-review-2.pdf) · [Supervisor’s report](defense/dissertation-review-sup.pdf) |
| Defense invitation | [PDF](defense/pozvanka.pdf) |

The compiled dissertation and autoreferát PDFs are generated locally and are not tracked in this repository. See the build instructions below. The [defense directory](defense/) also contains C++ examples and PowerPoint text-extraction helpers.

## Included publications

The seven papers reproduced in the dissertation are available in [papers/](papers/). Full citations are recorded in [references/bibliography.bib](references/bibliography.bib); the [publication list](sources/full/publications.tex) also covers additional work and individual contributions.

| Paper | Venue / status | Links |
| --- | --- | --- |
| Astute Approach to Handling Memory Layouts of Regular Data Structures | ICA3PP 2022 | [PDF](papers/smelko2022astute.pdf) · [DOI](https://doi.org/10.1007/978-3-031-22677-9_27) |
| Pure C++ Approach to Optimized Parallel Traversal of Regular Data Structures | PMAM @ PPoPP 2024 | [PDF](papers/klepl2024pure.pdf) · [DOI](https://doi.org/10.1145/3649169.3649247) |
| Abstractions for C++ Code Optimizations in Parallel High-Performance Applications | Parallel Computing, 2024 | [PDF](papers/klepl2024abstractions.pdf) · [DOI](https://doi.org/10.1016/j.parco.2024.103096) |
| Layout-Agnostic MPI Abstraction for Distributed Computing in Modern C++ | EuroMPI 2025 | [PDF](papers/klepl2025layout.pdf) · [DOI](https://doi.org/10.1007/978-3-032-07194-1_3) |
| Cellato: A DSL for Cellular Automata Based on C++ Template Meta-Programming | Journal of Object Technology, 2026 | [PDF](papers/brabec2025cellato.pdf) · [DOI](https://doi.org/10.5381/jot.2026.25.1.a13) |
| Tutoring LLM into a Better CUDA Optimizer | Euro-Par 2025 | [PDF](papers/brabec2025tutoring.pdf) · [DOI](https://doi.org/10.1007/978-3-031-99857-7_18) |
| Effect of Abstractions and Prompting Strategies on LLM-Guided High-Performance Optimizations | ICA3PP 2026, accepted; preprint | [PDF](papers/klepl2026effect.pdf) · [arXiv](https://arxiv.org/abs/2608.08085) |

## Software artifacts

| Project | Role in the dissertation |
| --- | --- |
| [Noarr](https://github.com/ParaCoToUl/noarr-structures) | C++20 abstractions for memory layouts, traversals, and parallel algorithms. |
| [Noarr-tuning](https://github.com/ParaCoToUl/noarr-tuning) | Autotuning of Noarr layouts and traversals. |
| [Noarr-MPI](https://github.com/ParaCoToUl/noarr-mpi) | Layout-agnostic MPI datatype construction and distributed communication. |
| [Cellato](https://github.com/ParaCoToUl/cellato) | C++20 DSL for cellular automata with CPU/CUDA implementations and configurable encodings, evaluation, and traversal. |

To collect source snapshots of these four repositories:

```sh
bash tools/package-artifacts.sh
```

This requires Git, ZIP, and network access and creates `artifacts/phd-thesis-artifacts.zip`. It fetches the current default branches and records their commit IDs; it does not reproduce pinned experimental revisions or bundle external dependencies and submodules.

## Building the documents

Use a TeX installation with **LuaLaTeX, Biber, and the packages used by the sources** (including `pdfx` and `biblatex-iso690`), together with **Make, Bash, and Ghostscript**. Run commands from the repository root:

| Command | Output / action |
| --- | --- |
| `make` | `thesis.pdf`, `abstract-en.pdf`, and `abstract-cs.pdf` |
| `make short` | `thesis-short.pdf` |
| `make publications` | `list-of-publications.pdf` |
| `make resume` | `resume.pdf` |
| `make validate` | Build and validate the full dissertation |
| `make validate-short` | Build and validate the abbreviated dissertation |
| `make clean` | Remove generated documents, intermediate files, and validation reports |

The full build prepares 300-dpi image facsimiles of the included papers in `papers/pdfa/` for PDF/A assembly; the original PDFs in `papers/` remain searchable. Validation requires Java, curl, unzip, and standard shell utilities, downloads checksum-pinned veraPDF components on first use, and writes reports to `validation/`. See [PDF/A build and validation notes](docs/PDF_A.md).

Shared metadata and macros live in [sources/shared/](sources/shared/), figures in [img/](img/), and build helpers in [tools/](tools/).

## Template attribution and reuse

The LaTeX foundation is the MFF UK [English thesis template](https://gitlab.mff.cuni.cz/teaching/thesis-templates/thesis-en), authored primarily by **Martin Mareš, Arnošt Komárek, and Michal Kulich**. It also draws on [better-mff-thesis](https://github.com/exaexa/better-mff-thesis), whose credited contributors include Vít Kabele, Mirek Kratochvíl, Jan Joneš, Gabriela Suchopárová, and Evžen Wybitul.

The original template is distributed under [CC0](https://creativecommons.org/public-domain/cc0/). That attribution does not grant a blanket CC0 licence to the dissertation, included papers, or other third-party material. Faculty logos are subject to the faculty’s rules, identified in the original template as Dean’s Directive 5/2016 and related regulations. For the included papers, consult their individual notices and the repository’s [copyright and reuse notes](docs/COPYRIGHT_REUSE.md). Software artifacts carry their own licences in their respective repositories.
