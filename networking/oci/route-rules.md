# OCI VCN routes required by the Fedora/WireGuard integration

The captured route table contains the following relevant destinations:

| Destination | Description |
|---|---|
| `10.100.0.0/24` | WireGuard network |
| `192.168.0.0/24` | wireguard |
| `10.32.0.0/16` | wireguard pod to pod communication |

The original capture queried only `destination`, `destination-type` and
`description`. It did not expose the target/next-hop values. Therefore this
file intentionally leaves the target unspecified rather than inventing a
configuration.

Before changing the route table, inspect the current values with:

```bash
oci network route-table list   --profile FEDORA   --auth security_token   --compartment-id <COMPARTMENT_OCID>   --output json
```

The subnet is `10.0.0.0/24` and the captured route table/security-list IDs
should be treated as environment-specific rather than copied into a generic
configuration file.

Relevant security-list descriptions observed in the capture include:

- `wireguard`
- `wireguard - traffic from node2 to wg`
- `pod to pod connection`

Review these rules together with the route table because both directions of
the path are required.
