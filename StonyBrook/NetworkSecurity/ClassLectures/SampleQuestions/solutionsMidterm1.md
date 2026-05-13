# Solutions to Midterm 1 Sample Questions

## Problem 1 (Message Authentication Code)
The scheme is broken because the XOR sum allows for **message reordering** and **existential forgery**.
*   **Attack 1 (Reordering):** Since XOR is commutative, $MAC(K, M_1 \parallel M_2) = MAC_B(K, M_1) \oplus MAC_B(K, M_2) = MAC_B(K, M_2) \oplus MAC_B(K, M_1) = MAC(K, M_2 \parallel M_1)$. An attacker can swap blocks and the MAC remains valid.
*   **Attack 2 (Mixing):** If an attacker knows $MAC(K, M_A \parallel M_B)$ and $MAC(K, M_C \parallel M_D)$, they can forge $MAC(K, M_A \parallel M_B \parallel M_C \parallel M_D)$ by simply XORing the two known MACs.

## Problem 2 (Multiplicative Homomorphic Encryption)
**Property:** A scheme is multiplicatively homomorphic if the product of two ciphertexts decrypts to the product of the original plaintexts: $Dec(Enc(m_1) \cdot Enc(m_2)) = m_1 \cdot m_2$.
**El Gammal Proof:**
*   $Enc(m_1) = (g^{r_1}, m_1 \cdot y^{r_1})$ and $Enc(m_2) = (g^{r_2}, m_2 \cdot y^{r_2})$.
*   Component-wise multiplication: $(g^{r_1} \cdot g^{r_2}, (m_1 \cdot y^{r_1}) \cdot (m_2 \cdot y^{r_2})) = (g^{r_1+r_2}, (m_1 \cdot m_2) \cdot y^{r_1+r_2})$.
*   The result is a valid encryption of $m_1 \cdot m_2$ with randomness $r_1+r_2$.

## Problem 3 (Shared Key Between Friends)
Alice, Bob, and Carol can use **Group Diffie-Hellman**:
1. Alice sends $g^a$ to Bob.
2. Bob sends $(g^a)^b = g^{ab}$ to Carol.
3. Carol sends $(g^{ab})^c = g^{abc}$ to Alice and Bob.
Alternatively, they can use a circular approach where each computes intermediate keys until everyone shares $g^{abc}$.

## Problem 4 (Outsourced Storage)
Use a **Merkle Tree**. 
1. Compute leaf hashes: $h_1=H(1), h_2=H(2), h_3=H(3), h_4=H(4)$.
2. Compute parents: $h_{12}=H(h_1 \parallel h_2), h_{34}=H(h_3 \parallel h_4)$.
3. Compute root: $R = H(h_{12} \parallel h_{34})$.
4. Store $R$ locally. To verify reading '3', the server provides $3$ and the "audit path" $\{h_4, h_{12}\}$. The client checks if $H(h_{12} \parallel H(H(3) \parallel h_4)) == R$.

## Problem 5 (Perfect Secrecy)
A cipher is **perfectly secure** if the ciphertext provides absolutely no information about the plaintext. Mathematically, $P(M=m | C=c) = P(M=m)$. Observing $C$ does not change the prior probability of any message $M$.

## Problem 6 (User Authentication - AES GCM)
**AES-GCM** provides **Authenticated Encryption (AEAD)**. Unlike ECB/CTR/CBC, GCM generates an authentication tag. This ensures **integrity and authenticity**; if an attacker modifies the ciphertext, the tag verification will fail, preventing bit-flipping attacks.

## Problem 7 (M2M Authentication)
The threat is **Impersonation/Spoofing**. If an attacker possesses the private key of an old, expired (but "accepted") certificate, they can impersonate the service. In modern times, if the CA was compromised in the past, any certificate from that era would be trusted indefinitely by this buggy implementation.

## Problem 8 (Computational Security)
**Example:** AES with a 128-bit key.
*   **Computationally Secure:** Breaking it via brute force takes $2^{128}$ operations, which is infeasible.
*   **Perfect Secrecy Insecure:** Since the key space ($2^{128}$) is smaller than the possible message space (e.g., a 1GB file), multiple plaintexts could map to the same ciphertext. An adversary with infinite computing power could identify the correct plaintext.

## Problem 9 (User Authentication - Salting)
If passwords are not salted, an adversary can use **Rainbow Tables** or precomputed dictionary attacks. They precalculate $H(password)$ for millions of common strings and simply look up the stolen hashes to find the passwords instantly.

## Problem 10 (Random One-time Pad)
**Security Implication:** Key reuse leads to total loss of confidentiality.
If $c_1 = m_1 \oplus v$ and $c_2 = m_2 \oplus v$, then $c_1 \oplus c_2 = (m_1 \oplus v) \oplus (m_2 \oplus v) = m_1 \oplus m_2$.
This leaks the XOR sum of the plaintexts, which often allows recovery of both messages using frequency analysis.

## Problem 11 (Cipher Security)
The designer should protect against a **Chosen Plaintext Attack (CPA)**. If the adversary knows the first message is always "HELLO", they have a known plaintext. To prevent them from learning information about subsequent messages, the cipher must be IND-CPA secure (indistinguishable under chosen plaintext attack).

## Problem 12 (Digital Signature)
*   **Why sign the hash?** **Efficiency:** Signing a small, fixed-size hash (e.g., 256 bits) is much faster than signing a large document. **Security:** It prevents structural attacks on the underlying asymmetric math.
*   **Properties needed:** **Strong Collision Resistance** is vital to ensure an attacker cannot find two different messages $M_1$ and $M_2$ such that $H(M_1) = H(M_2)$, which would allow a signature on $M_1$ to be valid for $M_2$.

## Problem 13 (Non-repudiation)
*   **Digital Signatures (Asymmetric):** Only the sender has the private key. If a signature is valid, only the sender could have created it.
*   **MAC (Symmetric):** Both the sender and receiver share the same key $K$. If a MAC is valid, the receiver could have generated it themselves to frame the sender. Thus, the sender can "repudiate" (deny) the message.

## Problem 14 (RSA and IND-CPA)
Original RSA is **deterministic**. For a public key $(n, e)$, the encryption of $m$ is always $m^e \pmod n$. 
In an IND-CPA game, the adversary picks $m_0$ and $m_1$. The challenger returns $C = Enc(m_b)$. The adversary simply computes $c'_0 = m_0^e \pmod n$. If $C = c'_0$, then $b=0$, else $b=1$. The adversary wins with probability 1.

## Problem 15 (User Authentication - Honeywords)
*   **Goal:** To detect if a password database has been stolen and is being used by an attacker.
*   **Offline Attack:** An attacker steals the hashed password file and tries to crack it locally on their own hardware.
*   **Online Attack:** An attacker tries to log in to a live website by guessing passwords.
*   Honeywords provide "fake" passwords in the database. If an attacker uses a honeyword during an online login attempt, the system knows the database was compromised.
