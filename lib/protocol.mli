(** Binary protocol for UDP multicast messages.

    Protocol format:
    - Header (8 bytes): version (1) + msg_type (1) + payload_len (2) + reserved (4)
    - Data payload (12 bytes): seq (i32) + timestamp (f64)
    - All integers are little-endian *)

(** Protocol version *)
val version : int

(** Header size in bytes *)
val header_size : int

(** Data payload size in bytes *)
val data_payload_size : int

(** Message type for data messages *)
val msg_type_data : int

(** Protocol header *)
type header = {
  version : int;
  msg_type : int;
  payload_len : int;
}

(** Data message payload *)
type data_payload = {
  seq : int;
  timestamp : float;
}

(** Complete message with header and payload *)
type message = {
  header : header;
  payload : data_payload;
}

(** Encode a data message. Returns bytes ready to send over the network. *)
val encode_data : seq:int -> timestamp:float -> Bytes.t

(** Decode a complete message from bytes. Returns None if invalid. *)
val decode : Bytes.t -> message option

(** Convenience function to extract just the sequence number.
    Returns None if the message is invalid. *)
val decode_seq : Bytes.t -> int option
