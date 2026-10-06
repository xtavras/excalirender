# Build and Install on macOS (Apple Silicon)

The `canvas` package downloads a prebuilt macOS arm64 addon that bundles
its own Cairo and Pango libraries. Homebrew Cairo or Pango is not needed.

## 1. Install Bun

```bash
brew install oven-sh/bun/bun
```

To skip a global install, prefix the commands below with `npx`:
`npx bun@latest install` and `npx bun@latest run build:macos`.

## 2. Build

From the repository root:

```bash
bun install
bun run build:macos
```

This creates `dist/excalirender-darwin-arm64.tar.gz`.

## 3. Install

```bash
mkdir -p ~/.local/lib ~/bin
rm -rf ~/.local/lib/excalirender
tar xzf dist/excalirender-darwin-arm64.tar.gz -C ~/.local/lib
ln -sf ~/.local/lib/excalirender/bin/excalirender ~/bin/excalirender
```

`~/bin/excalirender` must be a symlink, not a copy. The launcher resolves
its own path to find the bundled `lib/` directory.

If `~/bin` is not in your `PATH`, add this line to `~/.zshrc`:

```bash
export PATH="$HOME/bin:$PATH"
```

## 4. Verify

```bash
excalirender sample.excalidraw -o /tmp/test.png
```

To update, repeat steps 2 and 3.
