# beyul fileformat

the basic structure of a beyul file consists of two parts: a header, which
contains information on how to process the document, and the body, which
describes the document structure and contents. the header specification will
remain constant, but the body format is versioned. 

## the header

the header is simply the first line in a beyul document.

it contains a series of comma separated keys and values, like 

    version:mk1,ft:markdown

the main purpose of the header is to specify which version of the beyul file
format specification is used in the document, so the version data is required.

the header can specify extra metadata (for example, what filetype to
set when the file has been reconstructed, like in the example above).

## body formats

### mk1

mk1 documents are mere lists of paths relative to the file, whose contents are
read and appended serially into view. For example, if we have a `1.part` file
containing

    first line

and a `2.part` file containing

    second line

a `doc.beyul` containing

    version:mk1
    1.part
    2.part

will be displayed as 

    first line
    second line


