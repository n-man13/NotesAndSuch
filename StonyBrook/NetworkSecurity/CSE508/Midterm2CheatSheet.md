# Midterm 2 Cheat Sheet — CSE508

A compact reference for core concepts likely to appear on the midterm.

---

## Diffie‑Hellman
 - DLP (Discrete Logarithm Problem): given $g^a$, find $a$.
 - CDH (Computational Diffie‑Hellman): given $g^a$ and $g^b$, compute $g^{ab}$.
 - DDH (Decisional Diffie‑Hellman): given $g^a, g^b$ and a value $Z$, decide whether $Z=g^{ab}$ or $Z$ is random.

---

## One‑Time Pad (OTP)
- Encrypt: ciphertext = plaintext XOR key (key length = message length).
- Perfect secrecy if: key is truly random, used only once, and kept secret.
- Danger: key reuse — XOR of two ciphertexts cancels the key and leaks information.

---

## AES Modes (quick)
- **AES‑ECB**: encrypts each block independently. Leaks plaintext patterns (do not use for structured data).
- **AES‑CBC**: provides confidentiality (chain blocks), but no built‑in integrity/authentication.
- **AES‑CTR**: turns block cipher into stream cipher (keystream XOR plaintext); no authenticity.
- **AES‑GCM**: AEAD mode — provides both confidentiality and integrity (recommended when available).

> Use authenticated encryption (AEAD) whenever possible (e.g., GCM, ChaCha20‑Poly1305).

---

## Merkle Tree (construction)
1. Hash each data block to produce leaves: $H_1, H_2, \ldots$.
2. Pair neighboring leaves, concatenate pairs, and hash pairs to form parent nodes: e.g. $H_{12} = H( H_1 \| H_2 )$
3. Repeat upward until a single root hash remains — the Merkle root.

---

## Common Weaknesses
| Weakness | Typical attack | Mitigation |
|---|---|---|
| Static keys | Retrospective decryption | Use ephemeral keys (PFS) |
| No randoms | Replay attacks | Use nonces, sequence numbers, timestamps |
| Weak hashing | Collision attacks | Use SHA‑256 or stronger |
| Plaintext handshake | Eavesdropping | Encrypt handshake (modern TLS) |

---

## DNS Protocol Recap

- Flow: stub resolver → recursive resolver → root → TLD → authoritative server; resolver caches and returns the answer.

- Transport: UDP/53 (default, fast) ; TCP/53 (truncation, large responses, AXFR) ; DoT/DoH for encrypted queries.

- Key fields & RRs (very quick): 16‑bit TXID; flags (QR, TC, RD, RA); counts (QD/AN/NS/AR); common RRs: A, AAAA, NS, CNAME, MX, PTR, TXT, SOA.

- Caching/TTL: answers cached for TTL seconds; negative caching via SOA; TTL controls propagation/staleness window.

- Important extensions: EDNS(0) (larger UDP payloads), DNS Cookies, QNAME minimization.

- Attacks & short mitigations: cache poisoning → TXID+source‑port randomization + DNSSEC; amplification → close/harden open resolvers + rate‑limit; on‑path tampering → DoT/DoH.

- Ops notes: TC→retry over TCP; restrict/authenticate AXFR (TSIG); avoid open recursive resolvers.

### DNSSEC
- Adds digital signatures to DNS records and a chain of trust (root → TLD → authoritative).
- Provides integrity and authentication, but not privacy (DNSSEC responses are still visible unless combined with DoT/DoH).

---

## SSL/TLS
- Purpose: provides encryption (confidentiality), integrity, and server/client authentication for application protocols (e.g., HTTPS, IMAPS).
- TLS 1.3 (modern) handshake, high level:
  - ClientHello (versions, cipher suites, key_share, SNI, PSK offers) → ServerHello (chosen suite, server key_share).
  - Encrypted handshake: EncryptedExtensions, Certificate, CertificateVerify, Finished — most handshake data after ServerHello is encrypted.
  - Key exchange: ECDHE (ephemeral) for forward secrecy; symmetric keys derived with HKDF.
  - Record layer: AEAD ciphers (e.g., AES-GCM, ChaCha20-Poly1305) provide combined auth+enc.
- Key features: authenticated encryption (AEAD), ephemeral key exchange (ECDHE), session resumption via PSK/tickets, optional 0-RTT early data (replay risks).
- Certificate validation: verify chain, check CN/SAN, validity window, revocation methods (OCSP/CRL/OCSP stapling); TLS session resumption relies on ticket/PSK trust.
- Operational notes: prefer TLS 1.3; disable legacy cipher suites and renegotiation; enable OCSP stapling and short-lived certs where possible.

### TLS 1.3 Protocol Exchange (1‑RTT overview)
1. **ClientHello** — client sends supported cipher suites and a KeyShare (e.g., ECDHE public key share).
2. **ServerHello & Response** — server replies with selected cipher suite, server KeyShare; sends encrypted extensions and Certificate; includes Finished MAC to prove handshake integrity.
3. **Client Finished** — client verifies server Certificate and Finished; sends its own Finished message.

- TLS 1.3 reduces round trips by sending key shares early; handshake keys derive from ECDHE and certificates.

### TLS — Common vulnerabilities & pitfalls
- Certificate issues: misissued or compromised CAs, improper chain/hostname/expiry checks, and unreliable revocation handling (CRL/OCSP).
- Protocol downgrade & legacy ciphers: fallback to weak suites enables downgrade attacks.
- Handshake/implementation bugs: e.g., Early CCS and similar flaws that allow weak keying or transcript manipulation.
- 0-RTT replay risks: TLS 1.3 early data may be replayed unless mitigated at the application layer.
- RNG & key management: poor randomness, nonce reuse, and long-lived keys (no PFS) weaken security.
- Side-channel and memory bugs: timing/oracle attacks, Heartbleed-style memory leaks, and other implementation defects.

---

## Certificate Transparency (CT) & ACME
- Certificate Transparency: public, append-only logs of issued certificates. CAs submit certs to CT logs and return Signed Certificate Timestamps (SCTs).
  - SCTs are embedded in certificates or stapled by servers; monitors/auditors watch logs to detect misissuance.
  - CT helps detect rogue or misissued certificates quickly by providing public visibility.
- ACME (Automated Certificate Management Environment): protocol (used by Let's Encrypt) for automated issuance/renewal of certificates.
  - ACME uses challenges (HTTP-01, DNS-01, TLS-ALPN-01) to prove domain control and an account key for the requester.
  - ACME + short-lived certs encourage automation and reduce manual CA processes.

---

## Denial-of-Service (DoS)
- Goal: deny or degrade availability. Often distributed (DDoS); can exhaust bandwidth, CPU, memory, sockets, or human attention.

- Categories:
  - Volumetric / Amplification: spoofed small requests cause much larger replies (Smurf, DNS/NTP/CLDAP/SSDP).
  - Transport/state exhaustion: SYN flooding (half‑open connections), TCP RST injection to kill sessions.
  - Application‑layer: connection flooding, Slowloris, HTTP/2 Rapid Reset, and algorithmic complexity attacks.

- Short mitigations:
  - Network: upstream filtering, ingress/egress filtering (uRPF), Anycast/CDN, blackholing and capacity planning.
  - Transport: SYN cookies, drop old half‑opens, connection limits, TCP timeouts, rate limiting.
  - Application: WAFs, request rate‑limits, resource quotas, fix algorithmic worst-cases (input validation, safer parsers).
  - Amplification-specific: disable/respond-to-broadcasts, restrict/harden open UDP services, close open resolvers, apply rate limits.

- Extra notes: Smurf (broadcast amplification), SYN cookies (state‑less SYN defense), Slowloris (hold connections open), HTTP/2 Rapid Reset (stream-reset abuse).

---

## Firewalls & Tunnels
 - Firewalls:
   - Types: stateless (ACLs), stateful (tracks sessions), NGFW (L7 inspection).
   - Rule order (quick): `allow RELATED,ESTABLISHED` → allow required services → `default-deny`.
   - Placement: edge chokepoint + internal segmentation (VLAN/DMZ).
   - Pitfalls: open management ports, UPnP/auto-port-mapping, misordered rules, broad CIDRs.
   - Quick `iptables` snippet:
     - `iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT`
     - `iptables -A INPUT -p tcp --dport 22 -s 198.51.100.0/24 -j ACCEPT`
     - `iptables -A INPUT -j DROP`
- Tunnels / VPNs:
  - IPSec (site-to-site, transport vs tunnel mode), OpenVPN/TLS-based VPNs, WireGuard (modern, simple, fast), SSH tunnels.
  - Use strong auth (certificates or strong PSKs), encrypt both control and data planes, and enable perfect forward secrecy where possible.
  - NAT traversal: NAT-T for IPsec, UDP encapsulation, STUN/TURN for P2P apps.

---

## BGP (Border Gateway Protocol)
- Purpose: inter-domain routing between Autonomous Systems (ASes). BGP runs over TCP port 179 and exchanges route announcements (prefixes + attributes).
- Core message types: OPEN, UPDATE (announcements/withdrawals), KEEPALIVE, NOTIFICATION.
- Route selection (simplified): highest local-pref → shortest AS_PATH → lowest origin type → lowest MED → eBGP over iBGP → lowest IGP cost to next-hop.
- Common issues: route hijacks (malicious or accidental announcements), prefix leaks, AS path manipulation.
- Mitigations: prefix filtering and route-policy, max-prefix limits, IRR-based filtering, RPKI/ROA origin validation (detect bogus origin AS), monitoring (BGPmon), and strict peering policies.

### eBGP vs iBGP
- eBGP (external BGP): runs between different Autonomous Systems (ASes). Peers are typically directly connected; eBGP updates normally modify the `AS_PATH` (prepend local AS) and are used to advertise reachability to the global Internet.
- iBGP (internal BGP): runs within a single AS. iBGP preserves `AS_PATH` (does not prepend) and peers may be multiple hops away; routes learned from one iBGP peer are not re-advertised to another iBGP peer (split-horizon), so a full mesh or route reflectors are required for scalability.
- Operational notes: eBGP sessions often assume adjacent peers and may use TTL/adjacency checks; iBGP requires careful topology (full mesh, route reflectors, or confederations) to ensure route propagation and avoid loops.

### BGP — Security risks
- Prefix hijacking: an AS advertises IP prefixes it does not own (maliciously or by misconfiguration), causing traffic to be diverted or dropped.
- Route leaks: an AS improperly advertises routes learned from one peer to others, exposing prefixes to unintended paths and disrupting routing.
- Path manipulation & AS_PATH spoofing: altering `AS_PATH` or prepending to influence route selection and route acceptance.
- Lack of authentication: classic BGP has no cryptographic origin/path validation, enabling impersonation and false announcements.
- Session attacks: TCP-level attacks (RST injection, session hijacking) or compromised peers can inject malicious UPDATEs.
- Instability & amplification: frequent bogus announcements/withdrawals (flapping) can create routing instability and large control-plane loads.
- RPKI/ROA risks & operational pitfalls: incomplete deployment, misconfigured ROAs, and reliance on a centralized trust infrastructure can cause accidental outages or false validation failures.
- Impact: traffic interception (MitM), blackholing, censorship, interception for data exfiltration or DDoS amplification via misdirected traffic.

**Brief mitigations:** strict prefix filtering, IRR/RPKI origin validation, max-prefix and sanity checks, neighbor authentication/ACLs, TTL/adjacency protections, monitoring and rapid remediation (BGPmon, route collectors).

---

## MAC vs Digital Signature
| Feature | MAC | Digital Signature |
|---|---:|---:|
| Key type | Symmetric (shared secret) | Asymmetric (public/private pair) |
| Speed | Very fast | Slower (public-key ops) |
| Non-repudiation | No | Yes |
| Primary use | Packet/message integrity | Legal docs, code signing, non‑repudiation |

---

## Short Practical Notes
- Depth of crypto security often relies on proper randomness and forward secrecy.
- Prefer ephemeral (per-session) keying for confidentiality forward secrecy.
- For network security QA: know tradeoffs (speed vs non‑repudiation), and when to use AEAD vs separate MAC+enc schemes.

---

