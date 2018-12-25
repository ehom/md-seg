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

```
Usage: md-seg.rb -i INPUT_FILE.md -o OUTPUT_FILE.md [OPTIONS]

Options
    -i, --input PATH                 Required GitHub Markdown filename
    -o, --output PATH                Required Github Markdown output filename
        --debug                      Run in debug mode
    -h, --help                       Show this message
```

### Example

```
$ md-seg.rb --input README.md --output segmented.README.md
```

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
