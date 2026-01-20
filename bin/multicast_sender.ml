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

let run mcast_port mcast_group count =
  let count = if count = 0 then 10_000 else count in
  print_endline "Running UDP Multicast Sender";
  print_endline ("Port: " ^ string_of_int mcast_port);
  print_endline ("Group: " ^ Core_unix.Inet_addr.to_string mcast_group);
  print_endline ("Count: " ^ string_of_int count);
  let sock = create_socket mcast_port mcast_group in
  let sent = ref 0 in
  for i = 1 to count do
    let time = Unix.gettimeofday () in
    let msg = Protocol.encode_data ~seq:i ~timestamp:time in
    let msg_len = Bytes.length msg in
    let _ =
      Unix.sendto
        sock
        msg
        0
        msg_len
        []
        (Core_unix.ADDR_INET (mcast_group, mcast_port))
    in
    sent := !sent + 1
  done;
  print_endline ("Finished sending " ^ string_of_int !sent ^ " packets");
  ()
;;
