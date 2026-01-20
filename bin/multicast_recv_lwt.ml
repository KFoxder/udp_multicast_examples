let rec handle_request sock buffer expected_seq count received =
  if count > 0 && !received >= count
  then (
    print_endline ("Received " ^ string_of_int !received ^ " packets, exiting");
    Lwt.return_unit)
  else (
    let%lwt sock = sock in
    let%lwt num_bytes, sender_addr = Lwt_unix.recvfrom sock buffer 0 1024 [] in
    (match sender_addr with
     | Core_unix.ADDR_INET (sender_ip, port) ->
       print_endline
         ("Received request from: "
          ^ Core_unix.Inet_addr.to_string sender_ip
          ^ ":"
          ^ string_of_int port);
       let msg_bytes = Bytes.sub buffer 0 num_bytes in
       (match Protocol.decode msg_bytes with
        | Some msg ->
          Printf.printf
            "Received message: seq=%d, time=%f\n%!"
            msg.payload.seq
            msg.payload.timestamp;
          if msg.payload.seq <> !expected_seq
          then
            Printf.printf
              "OUT OF ORDER: expected %d, got %d\n%!"
              !expected_seq
              msg.payload.seq;
          expected_seq := msg.payload.seq + 1;
          received := !received + 1
        | None -> print_endline "Warning: received invalid message")
     | _ -> print_endline "Received request from unknown address");
    handle_request (Lwt.return sock) buffer expected_seq count received)
;;

let create_socket mcast_port mcast_group =
  print_endline "Creating Socket";
  let sock = Core_unix.socket ~domain:PF_INET ~kind:SOCK_DGRAM ~protocol:0 () in
  Core_unix.set_mcast_ttl sock 0;
  Core_unix.set_mcast_loop sock true;
  Core_unix.setsockopt sock Core_unix.SO_REUSEPORT true;
  let bind_addr = Core_unix.ADDR_INET (Core_unix.Inet_addr.bind_any, mcast_port) in
  Core_unix.bind sock ~addr:bind_addr;
  Core_unix.mcast_join sock (Core_unix.ADDR_INET (mcast_group, 0));
  let lwt_sock = Lwt_unix.of_unix_file_descr ~blocking:false sock in
  Lwt.return lwt_sock
;;

let create_server sock count =
  print_endline "Creating Buffer";
  let buffer = Bytes.create 1024 in
  let expected_seq = ref 0 in
  let received = ref 0 in
  print_endline "Creating Server";
  handle_request sock buffer expected_seq count received
;;

let run mcast_port mcast_group count =
  print_endline "Running Lwt UDP Multicast";
  print_endline ("Port: " ^ string_of_int mcast_port);
  print_endline ("Group: " ^ Core_unix.Inet_addr.to_string mcast_group);
  print_endline ("Count: " ^ string_of_int count ^ " (0 = infinite)");
  let sock = create_socket mcast_port mcast_group in
  Lwt_main.run @@ create_server sock count
;;
