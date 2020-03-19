Generate Finnish wordlists from books on Gutenberg
==================================================

Idea blatantly stolen from Duukkis, who shares the final word lists
[here](https://github.com/duukkis/data/tree/master/gutenberg). Unless
you really want to do the parsing yourself, please utilize those files
directly.

Usage
=====

`$ make`

It'll take two hours or so. Downloading 250M books is slow, and Voikko
will take its time to process 500M'ish of Finnish text.

* `data/books/` will contain downloaded books
* `data/lists/` will contain classified word lists when all is complete
