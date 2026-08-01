# PDF/A-2u build and validation

Run the final archival check with:

```sh
make validate
```

This builds `thesis.pdf` and performs two veraPDF 1.30.2 checks:

1. the complete standard PDF/A-2u profile; and
2. the custom profile pinned to commit
   `3a3ae11f99ef9dd5b7ed6e92108256554b38a6f0` of
   [`mff-cuni-cz/cuni-thesis-validator`](https://github.com/mff-cuni-cz/cuni-thesis-validator).

The first run downloads checksum-pinned copies of the official validator
profile and veraPDF into `.cache/cuni-thesis-validator/`. XML reports are
written to `validation/`. Both directories are generated and ignored by Git.

## File-size requirement

MFF Dean's Measure 26/2023 applies to dissertations and limits files uploaded
to SIS to 850 MB. Charles University's Rector's Measure 72/2017 delegates the
exact maximum to the SIS methodology and requires oversized files to be handed
to the faculty for assisted upload. Neither measure dictates image resolution
or JPEG quality.

The `validate` target treats 850 MB as 850,000,000 bytes and fails before PDF/A
validation if `thesis.pdf` exceeds it. The current 300-dpi build is only about
23 MB, leaving a very large safety margin.

Sources checked on 13 July 2026:

- [MFF Dean's Measure 26/2023, article 4(6)](https://www.mff.cuni.cz/cs/vnitrni-zalezitosti/predpisy/opatreni-dekana/opatreni-dekana-c-26-2023)
- [Rector's Measure 72/2017, articles 5(7)--(8)](https://cuni.cz/UK-8701.html)

## Why the paper copies are rasterized

The thesis source itself is valid PDF/A-2u, but directly importing the seven
publisher PDFs also imports their non-archival font, colour, and metadata
objects. Declaring the assembled file to be PDF/A does not convert those
objects. The Makefile therefore calls `tools/pdfa.sh`, which uses Ghostscript's
`pdfimage24` device to make 300-dpi RGB page facsimiles in `papers/pdfa/`; the
originals in `papers/` remain untouched. This preserves the complete visual
papers and yields a compliant assembled thesis, at the cost of making the
reproduced paper pages image-only.

The facsimiles use lossless Flate compression. Ghostscript's own documentation
warns that JPEG is intended for photographs and is unsuitable for most rendered
pages containing text and graphics. At only about 23 MB there is no need to
trade fidelity for lossy JPEG compression. The 300-dpi resolution can still be
overridden if necessary, for example:

```sh
make ARCHIVAL_DPI=400 thesis.pdf
```

Any change to these settings requires running `make validate` again.

Ghostscript reference: [PDF image and JPEG output devices](https://ghostscript.readthedocs.io/en/gs10.07.1/Devices.html).

## University-profile compatibility note

The pinned university repository currently combines veraPDF 1.12.1 with a
newer profile that references the `actualEncoding` model property; that
combination throws an evaluation error instead of validating a file. Conversely,
veraPDF 1.30 renamed the profile's old `TR` and `TR2` properties. The validation
script checksum-verifies the university profile and applies only the semantic
property-name equivalents required by veraPDF 1.30:

- `TR == null` becomes `containsTR == false`;
- `TR2 == null || TR2 == "Default"` becomes
  `containsTR2 == false || TR2NameValue == "Default"`.

The transformed profile is itself checksum-pinned, and the separate standard
PDF/A-2u run guards against omissions in the custom profile.
