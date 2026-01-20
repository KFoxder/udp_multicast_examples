let test_encode_decode_roundtrip () =
  let seq = 42 in
  let timestamp = 1234567890.123456 in
  let encoded = Protocol.encode_data ~seq ~timestamp in
  match Protocol.decode encoded with
  | Some msg ->
    assert (msg.header.version = Protocol.version);
    assert (msg.header.msg_type = Protocol.msg_type_data);
    assert (msg.header.payload_len = Protocol.data_payload_size);
    assert (msg.payload.seq = seq);
    assert (abs_float (msg.payload.timestamp -. timestamp) < 0.0000001);
    print_endline "test_encode_decode_roundtrip: PASSED"
  | None ->
    failwith "test_encode_decode_roundtrip: FAILED - decode returned None"

let test_decode_seq () =
  let seq = 9999 in
  let timestamp = 0.0 in
  let encoded = Protocol.encode_data ~seq ~timestamp in
  match Protocol.decode_seq encoded with
  | Some s ->
    assert (s = seq);
    print_endline "test_decode_seq: PASSED"
  | None ->
    failwith "test_decode_seq: FAILED - decode_seq returned None"

let test_message_size () =
  let encoded = Protocol.encode_data ~seq:1 ~timestamp:0.0 in
  let expected_size = Protocol.header_size + Protocol.data_payload_size in
  assert (Bytes.length encoded = expected_size);
  assert (expected_size = 20);
  print_endline "test_message_size: PASSED"

let test_decode_invalid_short_buffer () =
  let short_buf = Bytes.create 5 in
  assert (Protocol.decode short_buf = None);
  print_endline "test_decode_invalid_short_buffer: PASSED"

let test_decode_invalid_version () =
  let encoded = Protocol.encode_data ~seq:1 ~timestamp:0.0 in
  Bytes.set_uint8 encoded 0 99;
  assert (Protocol.decode encoded = None);
  print_endline "test_decode_invalid_version: PASSED"

let test_decode_invalid_msg_type () =
  let encoded = Protocol.encode_data ~seq:1 ~timestamp:0.0 in
  Bytes.set_uint8 encoded 1 99;
  assert (Protocol.decode encoded = None);
  print_endline "test_decode_invalid_msg_type: PASSED"

let test_decode_invalid_payload_len () =
  let encoded = Protocol.encode_data ~seq:1 ~timestamp:0.0 in
  Bytes.set_uint16_le encoded 2 99;
  assert (Protocol.decode encoded = None);
  print_endline "test_decode_invalid_payload_len: PASSED"

let test_multiple_sequences () =
  for i = 1 to 100 do
    let timestamp = float_of_int i *. 1000.0 in
    let encoded = Protocol.encode_data ~seq:i ~timestamp in
    match Protocol.decode encoded with
    | Some msg ->
      assert (msg.payload.seq = i);
      assert (abs_float (msg.payload.timestamp -. timestamp) < 0.0000001)
    | None ->
      failwith (Printf.sprintf "test_multiple_sequences: FAILED at seq=%d" i)
  done;
  print_endline "test_multiple_sequences: PASSED"

let test_negative_sequence () =
  let seq = -1 in
  let encoded = Protocol.encode_data ~seq ~timestamp:0.0 in
  match Protocol.decode encoded with
  | Some msg ->
    assert (msg.payload.seq = seq);
    print_endline "test_negative_sequence: PASSED"
  | None ->
    failwith "test_negative_sequence: FAILED"

let test_large_timestamp () =
  let timestamp = 9999999999.999999 in
  let encoded = Protocol.encode_data ~seq:1 ~timestamp in
  match Protocol.decode encoded with
  | Some msg ->
    assert (abs_float (msg.payload.timestamp -. timestamp) < 0.0000001);
    print_endline "test_large_timestamp: PASSED"
  | None ->
    failwith "test_large_timestamp: FAILED"

let () =
  print_endline "Running protocol tests...";
  print_endline "";
  test_encode_decode_roundtrip ();
  test_decode_seq ();
  test_message_size ();
  test_decode_invalid_short_buffer ();
  test_decode_invalid_version ();
  test_decode_invalid_msg_type ();
  test_decode_invalid_payload_len ();
  test_multiple_sequences ();
  test_negative_sequence ();
  test_large_timestamp ();
  print_endline "";
  print_endline "All tests passed!"
