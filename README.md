# OCaml UDP Multicast Examples

Goal of this is to provide UDP multicast examples using the two main OCaml concurrency libraries [`lwt`](https://github.com/ocsigen/lwt), [`async`](https://github.com/janestreet/async) and no concurrency. I couldn't find good examples at the time so I created them for anyone who may need them as a starting point in the future.

### Setup
```
opam switch create udp_multicast ocaml.5.1.1
eval $(opam env --switch=udp_multicast)
opam install dune
opam install . --deps-only
```

#### Run UDP Multicast Listener
```
# Run one (or all three) of the multicast listeners
# Option 1: Run lwt
dune exec multicast_udp lwt
# Option 2: Run async 
dune exec multicast_udp async
# Option 3: Run with no concurrency
dune exec multicast_udp none
```

#### Run UDP Multicast Sender
```
# In a seperate terminal run:
dune exec multicast_udp sender
```

#### Screenshots
![](./screenshot.gif)

### Helpful Resources
- [Linux Documentation - Multicast](https://tldp.org/HOWTO/Multicast-HOWTO.html)
- [Real World Ocaml - Concurrent Programming](https://dev.realworldocaml.org/concurrent-programming.html)
- [UDP Client and Server in OCaml](https://medium.com/@aryangodara_19887/udp-client-and-server-in-ocaml-e203116a997c)
- [UDP Multicast in C](https://gist.github.com/hostilefork/f7cae3dc33e7416f2dd25a402857b6c6)

