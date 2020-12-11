# AsciiDoc Sources

This directory contains the [AsciiDoc] sources and assets of various HTML documents found in the repository.


-----

**Table of Contents**

<!-- MarkdownTOC autolink="true" bracket="round" autoanchor="false" lowercase="only_ascii" uri_encoding="true" levels="1,2,3" -->

- [Directory Contents](#directory-contents)
- [Documents List](#documents-list)
- [About](#about)
- [System Requirements](#system-requirements)

<!-- /MarkdownTOC -->

-----

# Directory Contents

- [`CompilerInterface.asciidoc`][CompilerInterface.asciidoc] — _[PureBasic Compiler Interface]_.
- [`DocMaker-Help.asciidoc`][DocMaker-Help.asciidoc] — _[PureBasic DocMaker Help]_.
- [`DocMaker-Tags.asciidoc`][DocMaker-Tags.asciidoc] — _[PureBasic DocMaker Tags Guide]_.
- [`PB-DLL-Importer.asciidoc`][PB-DLL-Importer.asciidoc] — _[PureBasic DLL Importer]_.
- [`PB-Documentation-Guide.asciidoc`][PB-Documentation-Guide.asciidoc] — _[PureBasic Documentation Guidelines]_.
- [`PB-Library-SDK.asciidoc`][PB-Library-SDK.asciidoc] — _[PureBasic Library SDK]_.
- [`PureUnit-Help.asciidoc`][PureUnit-Help.asciidoc] — _[PureUnit: Automated Testing in PureBasic]_.
- [`inc_contributing.adoc`][inc_contributing.adoc] — shared include file for "Contributing and Support" aside-box.
- [`inc_warn-editing.adoc`][inc_warn-editing.adoc] — shared include file with HTML commented warning about editing.
- [`asciidoc2html.sh`][asciidoc2html.sh] — converter script.


# Documents List

The following table maps the AsciiDoc sources of this folder to their generated HTML documents elsewhere in the repository.

|                         AsciiDoc Source File                         |                              Generated HTML File                              |
|----------------------------------------------------------------------|-------------------------------------------------------------------------------|
| [`CompilerInterface.asciidoc`][CompilerInterface.asciidoc]           | [`../PureBasicIDE/sdk/CompilerInterface.html`][CompilerInterface.html]        |
| [`DocMaker-Help.asciidoc`][DocMaker-Help.asciidoc]                   | [`../Documentation/DocMaker-Help.html`][DocMaker-Help.html]                   |
| [`DocMaker-Tags.asciidoc`][DocMaker-Tags.asciidoc]                   | [`../Documentation/DocMaker-Tags.html`][DocMaker-Tags.html]                   |
| [`PB-DLL-Importer.asciidoc`][PB-DLL-Importer.asciidoc]               | [`../PureBasicIDE/sdk/PB-DLL-Importer.html`][PB-DLL-Importer.html]            |
| [`PB-Documentation-Guide.asciidoc`][PB-Documentation-Guide.asciidoc] | [`../Documentation/PB-Documentation-Guide.html`][PB-Documentation-Guide.html] |
| [`PB-Library-SDK.asciidoc`][PB-Library-SDK.asciidoc]                 | [`../PureBasicIDE/sdk/PB-Library-SDK.html`][PB-Library-SDK.html]              |
| [`PureUnit-Help.asciidoc`][PureUnit-Help.asciidoc]                   | [`../PureBasicIDE/sdk/PureUnit-Help.html`][PureUnit-Help.html]                |


# About

The purpose of this directory is to gather various PureBasic and SpiderBasic documents, which were originally distributed as plain text files, and convert them to AsciiDoc sources in order to allow creating rich formated HTML versions.

Keeping all the AsciiDoc sources and their assets in this folder prevents cluttering the repository with unnecessary files, by keeping just the HTML documents in the destination folders.
The generated HTML documents are fully self-contained, they don't rely on external CSS stylesheets or image files (images are included in the generated document via [Data URIs]).

[AsciiDoc] is an optimal documentation format for collaborative editing since it relies on UTF-8 text sources, which are ideal for version controlled projects (unlike binary document formats like Word, or other formats which are zipped files).
Furthermore, the AsciiDoc syntax offers powerful formatting features (much richer than Markdown), yet remaining human-readable and easy to work with, using any text editor.

Although for the purpose of this repository we only convert the documents to HTML, the AsciiDoc sources can be converted to a wide variety of output formats, making these sources highly reusable in other projects (including websites created with CMSs supporting AsciiDoc).

HTML is an ideal format for distributing documents, since every end user has a web browser, whereas formats like Markdown require a previewer tool which might not be present natively on every OS.

The [`asciidoc2html.sh`][asciidoc2html.sh] conversion script couples each source file with a designated target folder via an associative array (aka _map_ or _hash table_) thus allowing each converted HTML document to be stored in any repository folder.


# System Requirements

The documents, assets and scripts in this folder were designed to work with the [Asciidoctor Ruby gem].

Although AsciiDoc is an implementation-independent specification, due to slight differences between the various AsciiDoc implementations, using other AsciiDoc tools might produce slightly different output documents.

Furthermore, in order to use other AsciiDoc implementations, you'll need to adapt the converter script.


<!-----------------------------------------------------------------------------
                               REFERENCE LINKS
------------------------------------------------------------------------------>

[AsciiDoc]: https://asciidoc.org/ "Visit AsciiDoc website"
[Asciidoctor]: https://asciidoctor.org/ "Visit Asciidoctor website"
[Asciidoctor Ruby gem]: https://rubygems.org/gems/asciidoctor "Asciidoctor page at RubyGems"

[Data URIs]: https://en.wikipedia.org/wiki/Data_URI_scheme "Wikipedia page on data URI scheme"

<!-- project folders -->

[Documentation/]: ../Documentation/ "Navigate to folder"

<!-- project files -->

[CompilerInterface.asciidoc]: ./CompilerInterface.asciidoc "View source document"
[DocMaker-Help.asciidoc]: ./DocMaker-Help.asciidoc "View source document"
[DocMaker-Tags.asciidoc]: ./DocMaker-Tags.asciidoc "View source document"
[PB-DLL-Importer.asciidoc]: ./PB-DLL-Importer.asciidoc "View source document"
[PB-Documentation-Guide.asciidoc]: ./PB-Documentation-Guide.asciidoc "View source document"
[PB-Library-SDK.asciidoc]: ./PB-Library-SDK.asciidoc "View source document"
[PureUnit-Help.asciidoc]: ./PureUnit-Help.asciidoc "View source document"
[asciidoc2html.sh]: ./asciidoc2html.sh "View source script"
[inc_contributing.adoc]: ./inc_contributing.adoc "View source document"
[inc_warn-editing.adoc]: ./inc_warn-editing.adoc "View source document"

<!-- html output files -->

[CompilerInterface.html]: ../PureBasicIDE/sdk/CompilerInterface.html "View generated HTML document"
[DocMaker-Help.html]: ../Documentation/DocMaker-Help.html "View generated HTML document"
[DocMaker-Tags.html]: ../Documentation/DocMaker-Tags.html "View generated HTML document"
[PB-DLL-Importer.html]: ../PureBasicIDE/sdk/PB-DLL-Importer.html "View generated HTML document"
[PB-Documentation-Guide.html]: ../Documentation/PB-Documentation-Guide.html "View generated HTML document"
[PB-Library-SDK.html]: ../PureBasicIDE/sdk/PB-Library-SDK.html "View generated HTML document"
[PureUnit-Help.html]: ../PureBasicIDE/sdk/PureUnit-Help.html "View generated HTML document"

<!-- html outpt docs by title -->

[PureBasic Compiler Interface]: ../PureBasicIDE/sdk/CompilerInterface.html "View generated HTML document"
[PureBasic DLL Importer]: ../PureBasicIDE/sdk/PB-DLL-Importer.html "View generated HTML document"
[PureBasic DocMaker Help]: ../Documentation/DocMaker-Help.html "View generated HTML file"
[PureBasic DocMaker Tags Guide]: ../Documentation/DocMaker-Tags.html "View generated HTML file"
[PureBasic Documentation Guidelines]: ../Documentation/PB-Documentation-Guide.html "View generated HTML file"
[PureBasic Library SDK]: ../PureBasicIDE/sdk/PB-Library-SDK.html "View generated HTML document"
[PureUnit: Automated Testing in PureBasic]: ../PureBasicIDE/sdk/PureUnit-Help.html "View generated HTML document"

<!-- EOF -->
