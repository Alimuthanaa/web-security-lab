# Web Security Lab
**Author:** Mont (Alimuthanaa)  
**Started:** 2026-03-02  

This is my personal web security learning portfolio. It documents hands-on practice with real CTF platforms and deliberately vulnerable applications, covering attack techniques, tools, and methodology used in web application penetration testing.

Each folder contains a full writeup of a specific attack or challenge, including scripts, findings, and reflections.

---

## Labs

| # | Name | Category | Target | Status |
|---|------|----------|--------|--------|
| 01 | [SkattCTF — Authentication Bypass](./01-skattctf/) | Auth Bypass | skatt.ctfd.io | Password not found |
| 02 | [DVWA — Brute Force](./02-dvwa-brute-force/) | Brute Force | localhost (DVWA) | Completed (Low + Medium) |

---

## Tools Used

| Tool | Purpose |
|------|---------|
| Chrome DevTools | Source analysis, cookie manipulation, network inspection |
| ffuf | HTTP fuzzing and brute force |
| SecLists | Password and payload wordlists |
| Docker | Running local vulnerable applications |
| DVWA | Deliberately vulnerable web app |

---

## Setup

### DVWA (Local Lab)
```bash
docker pull vulnerables/web-dvwa
docker run -d -p 80:80 vulnerables/web-dvwa
# Access at http://localhost
# Default credentials: admin / password
```

### SecLists
```bash
git clone https://github.com/danielmiessler/SecLists.git ~/SecLists
```

### ffuf
```bash
brew install ffuf
```

---

## Learning Path

These labs follow the OWASP Top 10 as a rough guide, starting with authentication failures and working towards more complex vulnerabilities like injection, XSS, and file inclusion.

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [ffuf Documentation](https://github.com/ffuf/ffuf)
- [SecLists](https://github.com/danielmiessler/SecLists)
- [DVWA](https://github.com/digininja/DVWA)