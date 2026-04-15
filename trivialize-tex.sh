#!/bin/bash

# Usage: trivialize-tex.sh < input.tex
# Output: the trivialized version of input.tex (to stdout; without many LaTeX commands); tools like Grammarly like it better, usually

set -e

if ! [ -z "${1:-}" ]; then
    cat "$1"
else
    cat
fi |
perl -pe 's/(?<!\\)%.*(\n|$)//g' |  # remove comments, but not escaped ones, and the newline after the comment
perl -pe 's/(?<=\w)\s*\n/ /g' |  # remove newlines between words (but not between paragraphs)
sed 's/\$k\$NN/kNN/g' |
sed 's/top-\$k\$/top-k/g' |
sed 's/na\\"i/naï/g' |
sed 's/Na\\"i/Naï/g' |
sed 's/na\\"{\\i}/naï/g' |
sed 's/Na\\"{\\i}/Naï/g' |
sed 's/\\scriptsize//g' |
sed 's/\\footnotesize//g' |
sed 's/\\small//g' |
sed 's/\\normalsize//g' |
sed 's/\\large\b//g' |
sed 's/\\Large\b//g' |
sed 's/\\LARGE\b//g' |
sed 's/\\huge\b//g' |
sed 's/\\Huge\b//g' |
sed 's/\\centering\b//g' |
sed 's/\\includegraphics\(\[[^]]*\]\)\?{[^}]*}//g' |
sed 's/\\label{[^}]*}//g' |
sed 's/~\?\\cite{[^}]*}//g' |
sed 's/~/ /g' |
sed 's/---/—/g' |
sed 's/--/–/g' |
sed 's/\\le\b/≤/g' |
sed 's/\\ge\b/≥/g' |
sed 's/\\ll\b/≪/g' |
sed 's/\\gg\b/≫/g' |
sed 's/\\times\b/×/g' |
sed 's/\\sim\b/∼/g' |
sed 's/\\&/\&/g' |
sed 's/\\%/%/g' |
sed 's/\\lVert\b/|/g' |
sed 's/\\rVert\b/|/g' |
sed 's/\\item\b/- /g' |
sed 's/\\lstinline\[[^]]*\]/\\lstinline/g' |
sed 's/\\cdot\b/·/g' |
sed 's/\\left\b//g' |
sed 's/\\right\b//g' |
sed 's/\\lceil\b/⌈/g' |
sed 's/\\rceil\b/⌉/g' |
sed 's/\\lfloor\b/⌊/g' |
sed 's/\\rfloor\b/⌋/g' |
sed 's/\\ / /g' |
sed 's/\\cref{[^}]*}/a reference/g' |
sed 's/\\Cref{[^}]*}/A reference/g' |
sed 's/\\ref{[^}]*}/x/g' | # Step~\ref{...} becomes Step x
sed 's/\\begin{[^}]*}\(\[[^]]*\]\)\?//g' |
sed 's/\\end{[^}]*}//g' |
awk '# Footnote extraction
BEGIN {
    footnote_pattern = "\\\\footnote{"
    footnote_count = 0
    footnote_pattern_size = length(footnote_pattern) - 1 # -1 because of the extra backslash
}
{
    while (match($0, footnote_pattern)) {
        start = RSTART
        count = 1
        i = start + footnote_pattern_size
        end = start + footnote_pattern_size
        while (count > 0 && i <= length($0)) {
            c = substr($0, i, 1)
            if (c == "{") count++
            else if (c == "}") {
                count--
                if (count == 0) end = i
            }
            i++
        }
        footnote_id = ++footnote_count
        footnote_text = substr($0, start + footnote_pattern_size, end - start - footnote_pattern_size)
        $0 = substr($0, 1, start - 1) substr($0, end + 1)

        footnotes[footnote_id] = footnote_text
    }
    print
}
END {
    # Print collected footnotes at the end
    if (footnote_count > 0) {
        print "\nFootnotes:"
        for (id in footnotes) {
            print "- [" id "] " footnotes[id]
        }
    }
}' |
sed 's/\\todo{[^}]*}//g' |
sed 's/\\[a-zA-Z]\+{\([^}]*\)}/\1/g' |
sed 's/\\[a-zA-Z]\+{\([^}]*\)}/\1/g' |
sed 's/\\[a-zA-Z]\+{\([^}]*\)}/\1/g' |
sed 's/\$\([0-9.]\+\)\$/\1/g' |
sed 's/\$//g' | # remove remaining $ (math mode delimiters)
sed 's/\\@//g' |
sed '/^$/N;/^\n$/D'
