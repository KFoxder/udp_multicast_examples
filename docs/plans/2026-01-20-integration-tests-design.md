# Integration Tests Design

## Goal

Create GitHub Actions integration tests that prove:
1. Sender and receiver binaries start correctly
2. End-to-end communication works (sender sends, receiver receives)

## Approach

Add `--count N` flags to sender and receiver to enable controlled test execution.

## CLI Changes

**Sender** (`dune exec multicast_udp sender -- --count N`):
- Default: 10000 packets
- Sends N packets then exits

**Receivers** (`dune exec multicast_udp lwt|async|none -- --count N`):
- Default: 0 (infinite loop, current behavior)
- When N > 0: exit after receiving N packets

## Implementation Changes

### `bin/main.ml`
- Parse `--count` from `Sys.argv`
- Pass count to each implementation's `run` function

### `bin/multicast_sender.ml`
- Change signature: `run mcast_port mcast_group count`
- Replace hardcoded `10_000` with `count` parameter

### `bin/multicast_recv.ml`
- Change signature: `run mcast_port mcast_group count`
- Track received count, exit when `received >= count` (if count > 0)

### `bin/multicast_recv_lwt.ml`
- Same pattern with `Lwt.return_unit` to exit

### `bin/multicast_recv_async.ml`
- Same pattern with `Deferred.unit` to exit

## CI Workflow Changes

Add to `.github/workflows/ci.yml`:

```yaml
- name: Run unit tests
  run: opam exec -- dune runtest

- name: Integration test - sender startup
  run: |
    timeout 10 opam exec -- dune exec multicast_udp sender -- --count 5 || exit 1

- name: Integration test - sender/receiver communication
  run: |
    opam exec -- dune exec multicast_udp none -- --count 5 &
    RECEIVER_PID=$!
    sleep 1
    opam exec -- dune exec multicast_udp sender -- --count 10
    wait $RECEIVER_PID
```

## Exit Codes

- `0`: Success
- `1`: Error (socket failure, invalid arguments)

## Edge Cases

- `--count 0` on receiver: infinite mode
- `--count 0` on sender: send nothing, exit
- Negative count: error

## Risk

GitHub Actions may not support multicast loopback. If tests fail due to networking restrictions, we can:
- Mark communication test as "allowed to fail"
- Skip it in CI and rely on local testing
