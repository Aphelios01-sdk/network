# FLOP Network — reports and feedback

The public intake for the **running** FLOP Network: bugs in nodes you operate, protocol
behaviour that contradicts the spec, gateway problems, docs gaps, and feature requests. The code lives elsewhere; this
repository holds the issues, the triage process, and public release notes for FLOP services.

## Where things go

| You have | Go to |
|---|---|
| Anything exploitable — verification bypass, slashing evasion, theft from an escrow, HTLC or voucher flow | **Private** report, per [SECURITY.md](SECURITY.md). Never a public issue. |
| A miner or validator misbehaving, crashing, or failing to sync | [Node bug](../../issues/new?template=node-bug.yml) |
| On-chain behaviour that contradicts the spec — a reward, slash, fee or settlement that came out wrong | [Protocol behaviour](../../issues/new?template=protocol.yml) |
| The hosted gateway or API returning errors or wrong prices | [Gateway](../../issues/new?template=gateway.yml) |
| Docs that are wrong, missing, or out of date | [Docs](../../issues/new?template=docs.yml) |
| Something you want the network or its tooling to do | [Feature request](../../issues/new?template=feature.yml) |
| An erratum, ambiguity, or challenge against the **specification** itself | [flop-labs/yellowpaper](https://github.com/flop-labs/yellowpaper/issues/new/choose) |
| A setup question | [ask.flop.finance](https://ask.flop.finance), which answers from the published docs |

The gateway is a convenience service run by FLOP Labs, not part of the protocol. A gateway outage
is not a network failure, and reports about it are kept separate on purpose.

## What does not belong here

- Exploits, in any form, including "I think this might be exploitable". See [SECURITY.md](SECURITY.md).
- Price, token, or listing questions. There is no FLOP price and nothing here will discuss one.
- Support for third-party wallets, exchanges, or hosting providers.

## Triage

Every new issue starts as `status:triage`. A maintainer labels it by `area:` and `type:`, then
moves it to `status:accepted`, `status:needs-info`, or `status:wontfix`. An issue waiting on
`status:needs-info` for 14 days is marked stale and closes 7 days later unless someone replies.
Issues that turn out to be code work may be transferred to the relevant repository; they keep
their history and get `status:moved-to-core`.

## Releases

Public release notes for FLOP services are published as [releases](../../releases), tagged
`<service>/v<version>`, such as `rest-gateway/v1.4.0`. These releases carry notes only; their
source archives contain this repository, not the service.

- **GitHub account:** choose Watch → Custom → Releases on this repository. GitHub notifies you
  in its inbox, and by email if your notification settings allow it.
- **Feed reader:** subscribe to [releases.atom](https://github.com/flop-labs/network/releases.atom).
  No account is needed.
- **Slack:** once GitHub's Slack app is in a channel, run
  `/github subscribe flop-labs/network releases`.
- **Agents and scripts:** read `GET /repos/flop-labs/network/releases`. The feed shows recent
  releases only, so use the API for history.

These options cover every service here. To follow one service, filter on the tag prefix.

A service with its own public repository can be followed the same way. For example,
[technocore-chat](https://github.com/flop-labs/technocore-chat/releases) publishes notes-only
releases, so watch that repository, add its
[releases.atom](https://github.com/flop-labs/technocore-chat/releases.atom) to a feed reader, or run
`/github subscribe flop-labs/technocore-chat releases` in Slack.

Changes to the release staging scripts are checked by the **Release staging checks**
workflow on matching pull requests, pushes to `main`, or manual dispatch. It runs Bash
syntax checks and `.github/scripts/stage-release.test.sh` with a fake `gh`, without
release credentials or publishing a release.

## Links

- [flop.finance](https://flop.finance) — project home
- [Testnet](https://flop.finance/testnet/) — how to join as a miner or validator
- [Whitepaper](https://flop.finance/whitepaper/) and [Yellow Paper](https://github.com/flop-labs/yellowpaper)
- [Devnet explorer](https://explorer.devnet.flop.network) and [faucet](https://faucet.flop.network)
- [ask.flop.finance](https://ask.flop.finance) — searchable docs assistant

## License

Templates and documentation here are licensed under either of [Apache License, Version
2.0](LICENSE-APACHE) or [MIT license](LICENSE-MIT), at your option. Content you post in issues stays
yours, under the [GitHub Terms of Service](https://docs.github.com/en/site-policy/github-terms/github-terms-of-service).
