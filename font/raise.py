import fontforge
import psMat
import sys

matrix = psMat.translate(0, int(sys.argv[1]))
font = fontforge.open(sys.argv[2])

font.familyname += " Raised"
font.fontname += "-Raised"
font.fullname += " Raised"

font.selection.all()
[glyph.transform(matrix) for glyph in font.selection.byGlyphs]

font.generate(sys.argv[3])
