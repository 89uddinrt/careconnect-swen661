# Security scan — Victor's screens (Contacts, Messaging, Settings)

Run 2026-09-08, against `WK4-Victor` (Dart SDK 3.13.1, Flutter's bundled toolchain).

## Dependency vulnerabilities — OSV-Scanner

[OSV-Scanner](https://github.com/google/osv-scanner) v2.5.1 (Google's open-source
vulnerability scanner) was run against the resolved dependency tree in
`pubspec.lock`:

```
$ osv-scanner scan source -L pubspec.lock

Scanned pubspec.lock file and found 47 packages
No issues found
```

47 resolved packages (`provider`, `go_router`, `shared_preferences`, and their
transitive dependencies) were checked against the [OSV database](https://osv.dev).
**No known vulnerabilities were found.**

Full JSON output: `osv-scanner scan source -L pubspec.lock --format json`
returns `"results": []`.

## Code-level review

`flutter analyze` reports zero issues (no errors, no warnings — see
`flutter analyze` in the repo's test suite). In addition, the following manual
checks were run against `lib/`:

| Check | Result |
|:------|:-------|
| Hardcoded API keys / secrets / passwords | None found |
| Plaintext `http://` network calls | None found (no network calls at all yet — data is mocked in-memory, per [Known issues](../README.md#known-issues-and-limitations)) |
| `dart:mirrors`, `Process.run`, `eval`-style dynamic execution | None found |
| Sensitive data in `SharedPreferences` | Only accessibility preferences (caption size/colour, volume, vibration pattern) are persisted — no PII, credentials, or health data |

## Notes / follow-up

- No backend or network layer exists yet on this branch (contacts/messages are
  seeded from local mock fixtures), so there is no attack surface for
  injection, TLS, or auth vulnerabilities to scan for at this stage.
- Re-run `osv-scanner scan source -L pubspec.lock` after any dependency bump,
  and before final submission, to catch newly disclosed CVEs.
