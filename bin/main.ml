let mcast_port = 5007
let mcast_group = Core_unix.Inet_addr.of_string "224.1.1.1"

let () =
  if Array.length Sys.argv < 2
  then print_endline "Usage: async|lwt|none|sender"
  else (
    let arg = Sys.argv.(1) in
    match arg with
    | "async" -> Multicast_recv_async.run mcast_port mcast_group
    | "lwt" -> Multicast_recv_lwt.run mcast_port mcast_group
    | "none" -> Multicast_recv.run mcast_port mcast_group
    | "sender" -> Multicast_sender.run mcast_port mcast_group
    | _ -> Printf.printf "Unknown argument: %s\n" arg)
;;
