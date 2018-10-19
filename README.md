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
$ md-seg.rb --input-file filename.md --output-file file-containing-segmented-paragraphs.md
```

### Example

```
$ md-seg.rb --input-file README.md --output-file segmented.README.md
```

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
