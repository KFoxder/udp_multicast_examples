let version = 1
let header_size = 8
let data_payload_size = 12
let msg_type_data = 0

type header = {
  version : int;
  msg_type : int;
  payload_len : int;
}

type data_payload = {
  seq : int;
  timestamp : float;
}

type message = {
  header : header;
  payload : data_payload;
}

let encode_data ~seq ~timestamp =
  let total_size = header_size + data_payload_size in
  let buf = Bytes.create total_size in
  (* Header: version (1) + msg_type (1) + payload_len (2) + reserved (4) *)
  Bytes.set_uint8 buf 0 version;
  Bytes.set_uint8 buf 1 msg_type_data;
  Bytes.set_uint16_le buf 2 data_payload_size;
  Bytes.set_int32_le buf 4 0l;
  (* Payload: seq (4) + timestamp (8) *)
  Bytes.set_int32_le buf 8 (Int32.of_int seq);
  Bytes.set_int64_le buf 12 (Int64.bits_of_float timestamp);
  buf

let decode_header buf =
  if Bytes.length buf < header_size then None
  else
    let ver = Bytes.get_uint8 buf 0 in
    let msg_type = Bytes.get_uint8 buf 1 in
    let payload_len = Bytes.get_uint16_le buf 2 in
    Some { version = ver; msg_type; payload_len }

let decode_data_payload buf offset =
  if Bytes.length buf < offset + data_payload_size then None
  else
    let seq = Int32.to_int (Bytes.get_int32_le buf offset) in
    let timestamp = Int64.float_of_bits (Bytes.get_int64_le buf (offset + 4)) in
    Some { seq; timestamp }

let decode buf =
  match decode_header buf with
  | None -> None
  | Some header ->
    if header.version <> version then None
    else if header.msg_type <> msg_type_data then None
    else if header.payload_len <> data_payload_size then None
    else if Bytes.length buf < header_size + header.payload_len then None
    else
      match decode_data_payload buf header_size with
      | None -> None
      | Some payload -> Some { header; payload }

let decode_seq buf =
  match decode buf with
  | None -> None
  | Some msg -> Some msg.payload.seq
