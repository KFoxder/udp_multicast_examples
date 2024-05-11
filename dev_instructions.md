opam switch create udp_multicast ocaml.5.1.1
opam install dune
opam install . --deps-only

# For VS Code & formatting
opam install ocaml-lsp-server ocamlformat