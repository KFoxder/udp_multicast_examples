let mcast_port = 5007
let mcast_group = Core_unix.Inet_addr.of_string "224.1.1.1"

let parse_count () =
  let count = ref 0 in
  for i = 2 to Array.length Sys.argv - 1 do
    if Sys.argv.(i) = "--count" && i + 1 < Array.length Sys.argv
    then count := int_of_string Sys.argv.(i + 1)
  done;
  !count
;;

let () =
  if Array.length Sys.argv < 2
  then print_endline "Usage: async|lwt|none|sender [--count N]"
  else (
    let arg = Sys.argv.(1) in
    let count = parse_count () in
    match arg with
    | "async" -> Multicast_recv_async.run mcast_port mcast_group count
    | "lwt" -> Multicast_recv_lwt.run mcast_port mcast_group count
    | "none" -> Multicast_recv.run mcast_port mcast_group count
    | "sender" -> Multicast_sender.run mcast_port mcast_group count
    | _ -> Printf.printf "Unknown argument: %s\n" arg)
;;
