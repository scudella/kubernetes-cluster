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


oci network route-table list   --profile FEDORA   --auth security_token   --compartment-id ocid1.compartment.oc1..aaaaaaaa7zd7hkamwo6hkp6u7yx25zrcasczel5ad4czfin64zsyrgkh2kga   --query "data[*].\"route-rules\"[*].{Destination: destination, \"Target-Type\": \"destination-type\", Description: description}"   --output table
```

The subnet is `10.0.0.0/24` and the captured route table/security-list IDs
should be treated as environment-specific rather than copied into a generic
configuration file.

Relevant security-list descriptions observed in the capture include:

```bash
oci network security-list list --profile FEDORA --auth security_token  --compartment-id ocid1.compartment.oc1..aaaaaaaa7zd7hkamwo6hkp6u7yx25zrcasczel5ad4czfin64zsyrgkh2kga --output table

```

The Ingress Rules list needs to be simplified.

Besides the securit list, the ssh, mail, kubernetes, and DNS are opened in the security groups per VNIC.

Egress Rules:
[
  {
    'destination': '0.0.0.0/0',
    'destination-type': 'CIDR_BLOCK',
    'icmp-options': None,
    'is-stateless': False,
    'protocol': 'all',
    'tcp-options': None,
    'udp-options': None,
    'description': None
  },
  {
    'destination': '10.100.0.0/24',
    'destination-type': 'CIDR_BLOCK',
    'icmp-options': None,
    'is-stateless': False,
    'protocol': 'all',
    'tcp-options': None,
    'udp-options': None,
    'description': 'wireguard'
  }
]

Ingress Rules:
[
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '10.0.0.0/24',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 6443,
        'min': 6443
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': 'kubernetes api --advertised...'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '10.0.0.0/24',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'All ports from the public intranet'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '177.194.34.165/32',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 8080,
        'min': 8080
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': 'Home Only - kubernetes dashboard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '10.0.0.0/24',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 80,
        'min': 80
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': None
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '177.194.34.165/32',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 1337,
        'min': 1337
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': 'Home only - Access to strapi admin'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '177.194.34.165/32',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 8081,
        'min': 8081
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': 'grafana dashboard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '177.194.34.165/32',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 9093,
        'min': 9093
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': 'alert manager dashboard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '6',
    'source': '177.194.34.165/32',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': {
      'destination-port-range': {
        'max': 9090,
        'min': 9090
      },
      'source-port-range': None
    },
    'udp-options': None,
    'description': 'prometheus dashboard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '17',
    'source': '10.0.0.0/24',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': None
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '1',
    'source': '10.0.0.0/24',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'Ping for k8s'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '17',
    'source': '0.0.0.0/0',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': {
      'destination-port-range': {
        'max': 51820,
        'min': 51820
      },
      'source-port-range': None
    },
    'description': 'wireguard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '1',
    'source': '177.194.34.165/32',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'to test wireguard'
  },
  {
    'icmp-options': {
      'code': None,
      'type': 8
    },
    'is-stateless': False,
    'protocol': '1',
    'source': '0.0.0.0/0',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'testing wireguard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': '1',
    'source': '0.0.0.0/0',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'wireguard'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': 'all',
    'source': '10.0.0.0/16',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'wireguard - traffic from node2 to wg'
  },
  {
    'icmp-options': None,
    'is-stateless': False,
    'protocol': 'all',
    'source': '10.100.0.0/24',
    'source-type': 'CIDR_BLOCK',
    'tcp-options': None,
    'udp-options': None,
    'description': 'pod to pod connection'
  }
]
