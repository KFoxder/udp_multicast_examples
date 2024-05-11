let rec handle_request sock buffer =
  let num_bytes, sender_addr = Unix.recvfrom sock buffer 0 1024 [] in
  (match sender_addr with
   | Core_unix.ADDR_INET (sender_ip, port) ->
     print_endline
       ("Received request from: "
        ^ Core_unix.Inet_addr.to_string sender_ip
        ^ ":"
        ^ string_of_int port);
     let message = Bytes.sub_string buffer 0 num_bytes in
     print_endline ("Received message: " ^ message)
   | _ -> print_endline "Received request from unknown address");
  handle_request sock buffer
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
  sock
;;

let create_server sock =
  print_endline "Creating Buffer";
  let buffer = Bytes.create 1024 in
  print_endline "Creating Server";
  handle_request sock buffer
;;

let run mcast_port mcast_group =
  print_endline "Running non-concurrent UDP Multicast";
  print_endline ("Port: " ^ string_of_int mcast_port);
  print_endline ("Group: " ^ Core_unix.Inet_addr.to_string mcast_group);
  let sock = create_socket mcast_port mcast_group in
  create_server sock
;;
