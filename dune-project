(lang dune 3.15)

(name multicast_udp)

(generate_opam_files true)

(source
 (github KFoxder/multicast_udp_ocaml))

(authors "Kevin Fox")

(maintainers "Kevin Fox")
(package
 (name multicast_udp)
 (synopsis "Multicast UDP Examples")
 (description "UDP Multicast examples using lwt & async.")
 (depends 
  (ocaml (= "5.1.1"))
  (async (= "v0.16.0"))
  (async_udp (= "v0.16.0"))
  (async_unix (= "v0.16.0"))
  (core (= "v0.16.2"))
  (core_unix (= "v0.16.0"))
  (lwt (= "5.7.0"))
  (lwt_ppx (= "2.1.0"))
  (ppx_let (= "v0.16.0"))
  )
 (tags
  (topics udp multicast lwt async)))
