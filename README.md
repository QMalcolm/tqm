# Tqm

My personal website project :) This isn't an open source project, but I like developing in public. If you find bugs on my site, [please feel free to report them][bugs].

# Local development

## Language dependencies
I use [asdf][asdf] for managing my language dependencies for projects. If you want to use it / check it out, [here are their getting started docs][asdf-setup]. With `asdf` installed, getting the languages setup is as easy as running `$ asdf install` in the repo. Alternatively, install the versions of `erlang` and `elixir` described in this repositories [.tool-versions][tool-versions] file.

## Dev dependencies

* Run `mix setup` to install and setup project dependencies
* Install `pre-commit` to so that pre-commit runs when you make git commits `$ pip install pre-commit`

## Running locally
* Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

[asdf]: https://asdf-vm.com/
[asdf-setup]: https://asdf-vm.com/guide/getting-started.html
[bugs]: https://github.com/QMalcolm/tqm/issues/new
[tool-versions]: .tool-versions
