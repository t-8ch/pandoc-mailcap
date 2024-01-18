# pandoc-mailcap

Pandoc based mailcap helper to convert HTML to text.
For usage with text-based mail clients like mutt or neomutt.

## Example

Example configuration in `~/.mailcap`.

```mailcap
text/html; /home/t-8ch/bin/pandoc-mailcap %s %{charset} ; copiousoutput
```
