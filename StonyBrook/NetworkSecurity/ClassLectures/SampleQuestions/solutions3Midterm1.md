# Solutions to Midterm 1 Sample Questions (3)

## 1. Hard Problems of Diffie-Hellman

**Problem:** Show that it is possible to solve the Decisional Diffie-Hellman (DDH) problem if one knows how to solve the Discrete Logarithm (DLG) problem.

**Solution:**
1.  **Define the Problems:**
    *   **DLG:** Given a cyclic group $G$ with generator $g$ and an element $y = g^x$, find the exponent $x$.
    *   **DDH:** Given a tuple $(g, g^a, g^b, Z)$, decide whether $Z = g^{ab}$ or $Z$ is a random element $g^c$ from the group.
2.  **The Reduction:**
    *   Suppose we have an oracle or algorithm that solves DLG.
    *   Given the DDH challenge $(g, g^a, g^b, Z)$:
        *   Apply the DLG solver to the pair $(g, g^a)$ to find the value of $a$.
        *   Once $a$ is known, take the third element of the challenge tuple, $g^b$.
        *   Compute $(g^b)^a = g^{ba} = g^{ab}$.
        *   Compare the computed value $g^{ab}$ with the provided value $Z$.
    *   If $g^{ab} = Z$, then the tuple is a valid Diffie-Hellman tuple.
    *   If $g^{ab} \neq Z$, then $Z$ was a random element.
3.  **Conclusion:** Since knowing $a$ allows for the trivial verification of $g^{ab}$, solving DLG is sufficient to solve DDH.

---

## 2. Sending a Message Securely

**Problem:** Design a protocol to send a secret message $M$ to a law enforcement agency over an insecure medium with no pre-shared keys, ensuring confidentiality and integrity against powerful adversaries.

**Protocol Construction:**

1.  **Step 1: Obtain Public Key and Authentication:**
    *   Since there is no pre-shared key, we must use Public Key Infrastructure (PKI).
    *   The sender fetches the Law Enforcement Agency's (LEA) digital certificate ($Cert_{LEA}$) from a trusted Certificate Authority (CA).
    *   The sender verifies the CA's signature on $Cert_{LEA}$ using the CA's public key (hardcoded in most systems) to ensure they are talking to the real agency and not an interceptor.
2.  **Step 2: Key Exchange (Hybrid Encryption):**
    *   The sender generates a fresh, random symmetric session key $K_s$ (e.g., a 256-bit AES key).
    *   The sender encrypts $K_s$ using the LEA's public key ($PK_{LEA}$) found in the certificate: $E_1 = RSA\_Encrypt(PK_{LEA}, K_s)$.
3.  **Step 3: Encrypting the Message with Integrity:**
    *   The sender uses an **Authenticated Encryption with Associated Data (AEAD)** scheme, such as **AES-GCM**.
    *   The sender computes: $(Ciphertext, Tag) = AES\_GCM\_Encrypt(K_s, Nonce, M)$.
    *   The *Ciphertext* ensures **Confidentiality**, while the *Tag* (MAC) ensures **Integrity** and authenticity.
4.  **Step 4: Transmission:**
    *   The sender transmits the bundle: $[E_1, Nonce, Ciphertext, Tag]$ to the agency.
5.  **Agency Side:**
    *   The LEA uses its private key to decrypt $E_1$ and recover $K_s$.
    *   The LEA uses $K_s$, the *Nonce*, and the *Tag* to decrypt the *Ciphertext*. If the *Tag* does not match, the LEA detects tampering and rejects the message.

---

## 3. RSA's Multiplicative Homomorphism

**Problem:** Prove that RSA is a multiplicatively homomorphic encryption scheme.

**Proof:**
1.  **RSA Encryption Definition:** Given a public key $(n, e)$, the encryption of a message $m$ is defined as:
    $$Enc(K, m) = m^e \pmod n$$
2.  **Multiplicative Homomorphism Requirement:** We must show that $Enc(K, m_1) \cdot Enc(K, m_2) = Enc(K, m_1 \cdot m_2)$.
3.  **Expansion:**
    *   Let $C_1 = Enc(K, m_1) = m_1^e \pmod n$
    *   Let $C_2 = Enc(K, m_2) = m_2^e \pmod n$
4.  **Multiplication of Ciphertexts:**
    $$C_1 \cdot C_2 = (m_1^e \pmod n) \cdot (m_2^e \pmod n)$$
    $$C_1 \cdot C_2 = (m_1 \cdot m_2)^e \pmod n$$
5.  **Result:** The expression $(m_1 \cdot m_2)^e \pmod n$ is exactly the RSA encryption of the product $(m_1 \cdot m_2)$. Thus, RSA is multiplicatively homomorphic.
