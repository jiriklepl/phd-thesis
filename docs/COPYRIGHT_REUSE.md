# Copyright reuse: current status

> **Short version:** six papers are ready for thesis reuse. The ICA3PP 2026
> manuscript needs one status check after the acceptance decision.

## What needs attention

- [ ] **Recheck the ICA3PP paper after the decision.** The repository currently
  describes it as submitted and under review. The thesis will be released only
  after the decision, so this check is mandatory before submission.

Everything else is already reflected in `sources/full/contributions.tex`,
`sources/shared/macros.tex`, and the PDFs in `papers/`.

## Paper-by-paper status

| Status | Local paper | Reuse route | Current thesis treatment |
|---|---|---|---|
| Ready | `vsmelko2022astute.pdf` | Springer thesis-reuse permission | Full Version of Record (VoR), citation, and Springer acknowledgement |
| Ready | `klepl2024pure.pdf` | CC BY 4.0 | Full VoR, citation, licence link, and “no changes” statement |
| Ready | `klepl2024abstractions.pdf` | CC BY 4.0 | Full VoR, citation, DOI, licence link, and “no changes” statement |
| Ready | `klepl2025layout.pdf` | Springer thesis-reuse permission | Full VoR, citation, and Springer acknowledgement |
| Ready | `brabec2025cellato.pdf` | CC BY 4.0 | Official 2026 VoR, citation, DOI, licence link, and “no changes” statement |
| Ready | `brabec2025tutoring.pdf` | Springer thesis-reuse permission | Full VoR, citation, and Springer acknowledgement |
| Check after decision | `klepl2026effect.pdf` | Pre-acceptance manuscript | Labelled “Submitted as”; no open licence; preprint notice included |

## The only time-sensitive item: ICA3PP 2026

Current repository state:

- the manuscript is a **pre-acceptance version**;
- `sources/full/publications.tex` calls it **under review**;
- `sources/full/contributions.tex` calls it **Submitted as**;
- it has **no Creative Commons or other open licence**; and
- its contribution page says that it has not undergone peer review or
  post-submission corrections.

After the decision:

1. **Rejected or still under review:** keep the current preprint and wording.
2. **Accepted but not yet published:** update the status and citation, then
   check the signed Licence to Publish before changing the included file.
3. **Published:** add the actual proceedings title and DOI to the complete
   Springer acknowledgement:

   > This preprint has not undergone peer review (when applicable) or any
   > post-submission improvements or corrections. The Version of Record of this
   > contribution is published in [volume title], and is available online at
   > https://doi.org/[DOI].

Do **not** silently replace the preprint with an accepted manuscript or VoR.
Each version has different reuse conditions.

## Why the current notices are sufficient

### Springer chapters

Applies to:

- `vsmelko2022astute.pdf`
- `klepl2025layout.pdf`
- `brabec2025tutoring.pdf`

Springer Nature permits authors to reuse the VoR in their own thesis and make
the thesis available as required by the awarding institution. The thesis must
give the normal citation and state:

> Reproduced with permission from Springer Nature.

The `\springerpublishedas` macro already prints the citation and this exact
notice. Co-author consent is assumed as stated above.

Source: [Springer Nature Author FAQs](https://www.springernature.com/de/partners/rights-permissions-third-party-distribution/author-faqs/27836660).

### CC BY 4.0 papers

Applies to:

- `klepl2024pure.pdf`
- `klepl2024abstractions.pdf`
- `brabec2025cellato.pdf`

CC BY 4.0 permits redistribution when the reuse gives appropriate credit,
links to the licence, and identifies changes. The `\ccpublishedas` macro prints
the full citation, licence link, and “Reproduced without changes.” The local
PDFs themselves identify these works as CC BY 4.0.

Sources: [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/),
[Elsevier copyright policy](https://www.elsevier.com/about/policies-and-standards/copyright),
and the [official JOT 2026 issue](https://www.jot.fm/contents/issue_2026_01.html).

### ICA3PP preprint

ICA3PP requires original, unpublished work and prohibits simultaneous
submission elsewhere. Its call does not prohibit preprints or theses. Springer
Nature also permits authors to share their pre-acceptance proceedings
manuscripts, but they must not apply a Creative Commons or other open licence.

The current `\submittedas` treatment follows that route. It must be revisited
after the acceptance decision because the thesis will not be released before
then.

Sources: [ICA3PP 2026 Call for Papers](https://hpcn.exeter.ac.uk/ica3pp2026/call4paper.php),
[Springer Nature book and proceedings policies](https://www.springernature.com/cn/open-science/policies/book-policies),
and [LNCS information for authors](https://link.springer.com/series/558/information-for-authors-and-editors).

## Repository implementation

- `sources/full/contributions.tex` uses `\springerpublishedas`,
  `\ccpublishedas`, or `\submittedas` for every included paper.
- `papers/` keeps the seven original PDFs.
- `tools/pdfa.sh` generates image-only PDF/A facsimiles in `papers/pdfa/` for thesis
  assembly. This technical conversion does not change the reuse basis or
  replace the originals.
