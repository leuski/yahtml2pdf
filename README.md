# yahtml2pdf

Yet Another HTML 2 PDF converter

This is a fully Swift native tool that takes an HTML page and prints it out to PDF.

```
OVERVIEW: Converts an HTML file into a PDF using WebKit. Supports generating
the table of contents and including a cover page.

USAGE: yahtml2pdf [<options>] <input-path> <output-path>

ARGUMENTS:
  <input-path>            The path to the source HTML file.
  <output-path>           The path to the final PDF file.

TABLE OF CONTENTS:
  --toc                   Generate Table of Content and insert it in front of
                          the document.
  --dump-toc <path to store TOC XML file>
                          The path where to store the TOC xml file. Normally we
                          do not save the xml file but convert it into HTML.
                          This might be useful for debugging the XSL
                          stylesheet. If omitted, no file is saved. Optional.
  --xsl-style-sheet <path to xsl stylesheet>
                          The path to a custom xsl stylesheet for creating the
                          Table of Content. Optional.
  --toc-user-style-sheet <path to style sheet>
                          The path for the CSS style sheet to include with the
                          table of contents Optional.
  --toc-language <language code>
                          The language for the table of contents.  Default
                          value provided. (default: en)
  --toc-title <string>    The title for the table of contents.  Default value
                          provided. (default: Table of Contents)
  --outline               Generate the document outline in the final PDF. The
                          table of Contents is a part of the document itself.
                          The outline is the navigation menu in the PDF.

PAGE OPTIONS:
  --margin-left <length value>
                          Left page margin. Can be specified in points (pt),
                          inches (in), millimeters (mm), or centimeters (cm).
                          Default value provided. (default: 1.0 in)
  --margin-right <length value>
                          Right page margin. Can be specified in points (pt),
                          inches (in), millimeters (mm), or centimeters (cm).
                          Default value provided. (default: 1.0 in)
  --margin-top <length value>
                          Top page margin. Can be specified in points (pt),
                          inches (in), millimeters (mm), or centimeters (cm).
                          Default value provided. (default: 1.0 in)
  --margin-bottom <length value>
                          Bottom page margin. Can be specified in points (pt),
                          inches (in), millimeters (mm), or centimeters (cm).
                          Default value provided. (default: 1.0 in)
  --paper-width <length value>
                          Paper width. Can be specified in points (pt), inches
                          (in), millimeters (mm), or centimeters (cm). You must
                          supply either both paper-width and paper-height
                          values or neither. If you provide only one of them,
                          it will be ignored. If both are omitted, the default
                          paper size "US Letter" will be used. Optional.
  --paper-height <length value>
                          Paper height. Can be specified in points (pt), inches
                          (in), millimeters (mm), or centimeters (cm). Optional.

OPTIONS:
  --cover <path to the cover page html>
                          The path to the cover page html file if a cover page
                          is required. Optional.
  -h, --help              Show help information.
```
