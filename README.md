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
  --toc-headings <list of numbers>
                          The HTML heading tags to include into the Table of
                          Contents.  A comma seprated list of heading levels.
                          Default value provided. (default: 1,2,3)
  --toc-depth <depth>     The depth of the Table of Contents. The effect is
                          different from the allowed headings list. For
                          example, if your document has
                            <h1>...</h1>
                            <h3>Heading 3</h3>
                          and you set the depth to 2, 'Heading 3' will be
                          included in the table. If, on the other hand, you
                          have
                            <h1>...</h1>
                            <h2>...</h2>
                            <h3>Heading 3</h3>
                          here, there is an h2 tag between <h1> and <h3>, --
                          'Heading 3' will not be included in the table.
                          Default value provided. (default: 6)
  --outline               Generate the document outline in the final PDF. The
                          table of Contents is a part of the document itself.
                          The outline is the navigation menu in the PDF.
  --outline-headings <list of numbers>
                          The HTML heading tags to include into the Table of
                          Contents.  A comma seprated list of heading levels.
                          Default value provided. (default: 1,2,3)
  --outline-depth <depth> The depth of the outline. The effect is different
                          from the allowed headings list. For example, if your
                          document has
                            <h1>...</h1>
                            <h3>Heading 3</h3>
                          and you set the depth to 2, 'Heading 3' will be
                          included in the outline. If, on the other hand, you
                          have
                            <h1>...</h1>
                            <h2>...</h2>
                            <h3>Heading 3</h3>
                          here, there is an h2 tag between <h1> and <h3>, --
                          'Heading 3' will not be included in the outline.
                          Default value provided. (default: 6)

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
