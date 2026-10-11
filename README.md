# tmux-static

Portable builds of [tmux](https://github.com/tmux/tmux), the terminal multiplexer, with libevent, jemalloc, and ncurses linked in statically, built with [zig](https://ziglang.org) as the C toolchain.

- Linux glibc: only glibc is linked dynamically, and only symbols up to glibc 2.17, so the
  binaries run on anything from CentOS 7 onwards
- Linux musl (`--static`): fully static, no runtime dependencies at all (e.g. Alpine)
- macOS: only libSystem is dynamic (it ships with macOS, which has no fully static binaries)

Common terminal descriptions (xterm, xterm-256color, screen, screen-256color, tmux, tmux-256color,
linux, vt100, vt220, rxvt, alacritty, kitty, foot, wezterm, ...) are compiled into ncurses, so tmux
works even on systems without a terminfo database. The system database is still used first, from
`/etc/terminfo`, `/lib/terminfo`, `/usr/share/terminfo`, and `/usr/lib/terminfo`, or from
`$TERMINFO`, `$TERMINFO_DIRS`, and `~/.terminfo`.

The build uses jemalloc, as upstream does on macOS, and has no utf8proc and no systemd support.

## Prerequisites

- `zig`, GNU make (the `make` 3.81 of macOS is enough), `git`
- `autoconf`, `automake`, `libtool`, `pkg-config`, and `bison` (the git trees of tmux and libevent ship no `configure` script)

## Installation

Clone the repo with submodules (shallow, the history of the vendored projects is not needed):

```shell
git clone --recurse-submodules --shallow-submodules https://github.com/zshsetup/tmux-static
cd tmux-static
```

## Usage

```shell
./build.sh
```

Output is installed under `dist/`:

- `dist/bin/tmux`: the binary; copy it anywhere on your `PATH`
- `dist/share/man/man1/tmux.1`: the man page

Pass `--static` for the fully static musl build on Linux (output in `dist-static/`), `--clean` to
remove previous build output first, and `--jobs N` to control parallelism.

To run the smoke tests against the build:

```shell
./tests/run_smoke_tests.sh            # dist/
./tests/run_smoke_tests.sh --static   # dist-static/
```

## Releases

Publishing a GitHub release tagged like the contents of `VERSION`, the tag checked out in
`vendor/tmux`, builds and attaches `tmux-static-<platform>.tar.gz` for `macos-arm64`,
`linux-amd64`, `linux-arm64`, `linux-musl-amd64`, and `linux-musl-arm64`, together with the sources
they were built from (`tmux-static-sources.tar.gz`).

To update a vendored project, check out a new release tag in its submodule, commit it, and update
`VERSION` if it is the main one, e.g.
`git -C vendor/tmux fetch --depth 1 origin tag 3.8 && git -C vendor/tmux checkout 3.8`.

## Acknowledgments

This repository builds and vendors the following upstream projects, unmodified, as git
submodules under `vendor/`. Credit goes to their respective authors:

- [tmux](https://github.com/tmux/tmux) by Nicholas Marriott and contributors
- [libevent](https://libevent.org/) by Niels Provos, Nick Mathewson, and contributors
- [jemalloc](https://jemalloc.net/) by Jason Evans, Facebook, Inc., and contributors
- [ncurses](https://invisible-island.net/ncurses/) by Thomas E. Dickey and Free Software Foundation, Inc.

## License

MIT for the code in this repository. See `NOTICE` for the licenses of the upstream projects and the
resulting binaries, which are ISC (tmux), BSD-3-Clause (libevent), BSD-2-Clause (jemalloc), and X11-MIT (ncurses).
