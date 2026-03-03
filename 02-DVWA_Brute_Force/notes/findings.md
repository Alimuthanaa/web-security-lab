# DVWA Brute Force — Raw Findings & Observations

## Target Info
- URL: http://localhost/vulnerabilities/brute/
- Platform: DVWA v1.10 (Docker)
- Account targeted: admin
- Password found: `password`

---

## Login Form Behavior

- Form submits via GET request (parameters visible in URL)
- Failed login message: `"Username and/or password incorrect."`
- Successful login message: `"Welcome to the password protected area admin"`
- Session cookie required: PHPSESSID + security level

---

## FUZZ Placeholder Behavior

ffuf replaces the exact word `FUZZ` in the URL with each wordlist entry.
Must be written exactly as `FUZZ` — any other word will be sent literally.

Example substitution:
```
Wordlist line: "password"
URL sent:      ?username=admin&password=password&Login=Login
```

---

## Low Security Observations

- No server-side delay
- No rate limiting
- No IP blocking detected
- Speed: 1,666 req/sec
- 10,000 passwords in 6 seconds
- Password `password` found at position ~1,000 in wordlist

---

## Medium Security Observations

- Server adds `sleep(2)` after each failed attempt
- Speed drops to ~1 req/sec
- 77 errors observed at 40 threads (timeouts)
- Fixed by reducing to `-t 1`
- Attack still works — just significantly slower
- Estimated 3-4 hours for full 10k wordlist

---

## Key Difference Between Levels

| Property | Low | Medium |
|----------|-----|--------|
| Sleep delay | None | 2 seconds |
| Threads needed | 40 | 1 |
| Speed | 1666 req/sec | ~1 req/sec |
| Attack viable | ✅ | ✅ (slow) |
| Error count | 0 | 77 at 40 threads |

---

## Reasoning Notes

- Confirmed username `admin` was valid before attacking — in real pentest this would require enumeration first
- Session cookie must match security level cookie — mismatched cookies cause unexpected behavior
- `-fr` flag is critical — without it all 10,000 responses would print and the hit would be buried
