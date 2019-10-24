# bento-emacs

This emacs package allows you to use
[bento](https://pypi.org/project/bento-cli/) as a syntax checker for Python and
JavaScript files via Flycheck. To use it, put it somewhere on your package load
path and `(require 'bento)`; you may need to also make sure to select the
`bento` checker. See [the flycheck
documentation](https://www.flycheck.org/en/latest/user/syntax-checkers.html) for
how to do that.
