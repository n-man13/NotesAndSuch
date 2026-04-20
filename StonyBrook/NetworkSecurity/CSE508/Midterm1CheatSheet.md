# Midterm 1 Cheat Sheet — CSE508

A compact reference for core concepts likely to appear on the midterm.

---

## Diffie‑Hellman
 - DLP (Discrete Logarithm Problem): given $g^a$, find $a$.
 - CDH (Computational Diffie‑Hellman): given $g^a$ and $g^b$, compute $g^{ab}$.
 - DDH (Decisional Diffie‑Hellman): given $g^a, g^b$ and a value $Z$, decide whether $Z=g^{ab}$ or $Z$ is random.

> Notes: problems are defined over a chosen cyclic group (e.g., $\mathbb{Z}_p^*$ or elliptic-curve groups).

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

## TLS 1.3 Protocol Exchange (1‑RTT overview)
1. **ClientHello** — client sends supported cipher suites and a KeyShare (e.g., ECDHE public key share).
2. **ServerHello & Response** — server replies with selected cipher suite, server KeyShare; sends encrypted extensions and Certificate; includes Finished MAC to prove handshake integrity.
3. **Client Finished** — client verifies server Certificate and Finished; sends its own Finished message.

- TLS 1.3 reduces round trips by sending key shares early; handshake keys derive from ECDHE and certificates.

---

## Merkle Tree (construction)
1. Hash each data block to produce leaves: $H_1, H_2, \ldots$.
2. Pair neighboring leaves, concatenate pairs, and hash pairs to form parent nodes: e.g. $H_{12} = H( H_1 \| H_2 )$.
3. Repeat upward until a single root hash remains — the Merkle root.

---

## Common Weaknesses — quick mapping
| Weakness | Typical attack | Mitigation |
|---|---|---|
| Static keys | Retrospective decryption | Use ephemeral keys (PFS) |
| No randoms | Replay attacks | Use nonces, sequence numbers, timestamps |
| Weak hashing | Collision attacks | Use SHA‑256 or stronger |
| Plaintext handshake | Eavesdropping | Encrypt handshake (modern TLS) |

---

## DNS Protocol Recap
 - Lookup flow: stub resolver (client) → recursive resolver (ISP or public resolver) which performs iterative queries starting at the root → TLD → authoritative name server; the resolver caches the answer and returns it to the client.

 - Typical transports and ports:
   - UDP/53: standard queries/responses (fast, connectionless).
   - TCP/53: zone transfers (AXFR/IXFR), large/truncated responses, and DNS-over-TLS (DoT).

 - Key header fields (DNS message format):
   - 16-bit Transaction ID (TXID)
   - Flags: QR (query/response), Opcode, AA (authoritative answer), TC (truncation), RD (recursion desired), RA (recursion available), RCODE (response code)
   - Counts: QDCOUNT, ANCOUNT, NSCOUNT, ARCOUNT

 - Common query / resource record (RR) types: `A`, `AAAA`, `NS`, `CNAME`, `MX`, `PTR`, `TXT`, `SRV`, `SOA`, `AXFR`.

 - Resolution modes:
   - Recursive: the resolver does the full lookup and returns a final answer to the client.
   - Iterative/referral: a server returns a referral to the next-level name servers; the resolver follows the referral.

 - Caching & TTL:
   - Responses are cached by resolvers for the record's TTL seconds.
   - Negative caching (NXDOMAIN) is controlled by SOA/minimum values.
   - TTLs determine propagation time for updates and the window for stale data.

 - Extensions & modern features:
   - EDNS(0): allows larger UDP payloads and additional options (bigger responses, EDNS flags).
   - DNS over TLS (DoT) and DNS over HTTPS (DoH): encrypt DNS for privacy and tamper-resistance.
   - DNS Cookies, Query Name Minimization: reduce abuse and improve privacy/security.

 - Common attacks & mitigations:
   - Cache poisoning: mitigate with TXID + source-port randomization and DNSSEC validation.
   - Amplification/reflection: mitigate by restricting open resolvers and rate-limiting.
   - On-path tampering / eavesdropping: mitigate with DoT/DoH and DNSSEC.

 - Operational notes:
   - Truncation (TC bit): when UDP response exceeds negotiated size, server sets TC; client retries over TCP.
   - Zone transfers (AXFR) should be restricted and authenticated (e.g., TSIG).

 **Diagram:**

 ![DNS packet on the wire](media/DNSPacket.png)


### DNSSEC
- Adds digital signatures to DNS records and a chain of trust (root → TLD → authoritative).
- Provides integrity and authentication, but not privacy (DNSSEC responses are still visible unless combined with DoT/DoH).

---

## MAC vs Digital Signature (comparison)
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

