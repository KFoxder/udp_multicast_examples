# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OCaml UDP multicast examples demonstrating three concurrency approaches: Lwt, Async (Jane Street), and synchronous. Educational project for learning UDP multicast patterns.

## Build Commands

```bash
# Build the project
dune build

# Run Lwt-based receiver
dune exec multicast_udp lwt

# Run Async-based receiver
dune exec multicast_udp async

# Run synchronous receiver
dune exec multicast_udp none

# Run sender (in separate terminal)
dune exec multicast_udp sender
```

## Development Setup

```bash
# Create and use project-specific opam switch
opam switch create udp_multicast ocaml.5.1.1
eval $(opam env --switch=udp_multicast)

# Install dependencies
opam install dune
opam install . --deps-only

# Optional: LSP and formatting
opam install ocaml-lsp-server ocamlformat
```

## Architecture

**Entry Point:** `bin/main.ml` dispatches to implementations based on command-line argument.

**Three Receiver Implementations:**
- `multicast_recv.ml` - Synchronous with blocking `Unix.recvfrom` and tail recursion
- `multicast_recv_lwt.ml` - Lwt promises with `let%lwt` syntax via lwt_ppx
- `multicast_recv_async.ml` - Jane Street Async with `let%bind` syntax, uses `Async_udp.recvfrom_loop`

**Sender:** `multicast_sender.ml` sends 10,000 numbered/timestamped packets.

**Multicast Config:** Port 5007, Group 224.1.1.1 (hardcoded in main.ml)

All implementations share the same socket setup pattern: create UDP socket → configure multicast options (TTL, loopback, reuse) → bind to port → join multicast group.

## Code Style

Uses Jane Street profile for ocamlformat (`.ocamlformat`). Dependencies pinned to exact versions in `dune-project`.
