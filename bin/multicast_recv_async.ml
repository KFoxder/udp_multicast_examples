open Async.Deferred.Let_syntax

let make_handle_request expected_seq =
  fun (buf : Async_udp.write_buffer) (addr : Async.Socket.Address.Inet.t) ->
    let msg_bytes = Bytes.of_string (Iobuf.to_string buf) in
    let addr_str = Async.Socket.Address.Inet.to_string addr in
    print_endline ("Received request from: " ^ addr_str);
    match Protocol.decode msg_bytes with
    | Some msg ->
      Printf.printf "Received message: seq=%d, time=%f\n%!" msg.payload.seq msg.payload.timestamp;
      if msg.payload.seq <> !expected_seq
      then
        Printf.printf "OUT OF ORDER: expected %d, got %d\n%!" !expected_seq msg.payload.seq;
      expected_seq := msg.payload.seq + 1
    | None -> print_endline "Warning: received invalid message"
;;

let create_socket mcast_port mcast_group =
  print_endline "Creating Socket";
  let sock = Async_unix.Socket.create Async_unix.Socket.Type.udp in
  Async.Socket.setopt sock Async_unix.Socket.Opt.mcast_ttl 0;
  Async.Socket.setopt sock Async_unix.Socket.Opt.mcast_loop true;
  Async.Socket.setopt sock Async_unix.Socket.Opt.reuseport true;
  let mcast_group_host_and_port =
    Async_unix.Socket.Address.Inet.create mcast_group ~port:mcast_port
  in
  Async.Socket.mcast_join sock mcast_group_host_and_port;
  let bind_addr = Async_unix.Socket.Address.Inet.create_bind_any ~port:mcast_port in
  let async_sock = Async.Socket.bind sock bind_addr in
  async_sock
;;

let create_server sock =
  print_endline "Creating Server";
  let%bind sock = sock in
  let expected_seq = ref 0 in
  let handle_request = make_handle_request expected_seq in
  let loop_res = Async_udp.recvfrom_loop (Async.Socket.fd sock) handle_request in
  loop_res
;;

let run mcast_port mcast_group =
  print_endline "Running Async UDP Multicast";
  print_endline ("Port: " ^ string_of_int mcast_port);
  print_endline ("Group: " ^ Core_unix.Inet_addr.to_string mcast_group);
  let sock = create_socket mcast_port mcast_group in
  let _ = create_server sock in
  Core.never_returns (Async.Scheduler.go ())
;;
