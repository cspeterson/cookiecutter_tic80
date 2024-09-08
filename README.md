This project is a [Cookiecutter] template for a Python [TIC-80] project.

The development setup includes a text-based cart and a separate script file. These features are only supported by [TIC-80 Pro].

Specifically, this is all arranged:

* `pylint`, `mypy`, and `black` configured to allow for the idiosyncrasies of TIC-80
* `mypy` configured with TIC-80 function stubs for type checking
* A `Makefile` with all targets running TIC-80 with the local filesystem in the repo.

# Intended workflow

1. Write code in `scripy.py` with your editor of choice
1. Run the cart with `make`
1. Edit assets
1. Save (`ctrl+s`)

This allows

* asset editing inside TIC-80
* code editing in an external editor
* avoids needing to reload either your external editor or TIC-80 itself on changes

Note that saving asset changes inside TIC-80 duplicates all the code from `script.py` into `cart.py`. This has no functional impact, as the `make` targets still run TIC-80 with the code from `script.py` no matter what.

# Usage

Run the cart with the separate script file:

```sh
# The default target is `run`
make
```

Build the releases for different platforms:

```sh
make build
```

[Cookiecutter]: https://www.cookiecutter.io/
[TIC-80 Pro]: https://nesbox.itch.io/tic80
[TIC-80]: https://tic80.com/
