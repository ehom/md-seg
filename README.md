# md-seg

This tool is used to segment paragraphs in GitHub Markdown files.

## Build

```
gem build md-seg
```

## Installation

```
gem install md-seg
```

## Usage

<pre>
Usage: md-seg.rb -i INPUT_FILE.md -o OUTPUT_FILE.md [OPTIONS]

Options
    -i, --input PATH                 Required GitHub Markdown filename
    -o, --output PATH                Required Github Markdown output filename
        --debug                      Run in debug mode
    -h, --help                       Show this message
</pre>

### Example

```
$ md-seg.rb --input README.md --output segmented.README.md
```

## Implementation Details

... can be found on this [page](https://ehom.github.io/md-seg/docs).
