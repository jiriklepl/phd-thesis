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

## Why the paper copies are rasterized

The thesis source itself is valid PDF/A-2u, but directly importing the seven
publisher PDFs also imports their non-archival font, colour, and metadata
objects. Declaring the assembled file to be PDF/A does not convert those
objects. The Makefile therefore calls `pdfa.sh`, which uses Ghostscript's
`pdfimage24` device to make 200-dpi RGB page facsimiles in `papers/pdfa/`; the
originals in `papers/` remain untouched. This preserves the complete visual
papers and yields a compliant assembled thesis, at the cost of making the
reproduced paper pages image-only.

The resolution and JPEG quality can be overridden if needed, for example:

```sh
make ARCHIVAL_DPI=300 ARCHIVAL_JPEG_QUALITY=98 thesis.pdf
```

Any change to these settings requires running `make validate` again.

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
