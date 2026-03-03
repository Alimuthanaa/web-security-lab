# DVWA — Brute Force Attack
**Author:** Mont (Alimuthanaa)  
**Date:** 2026-03-03  
**Target:** http://localhost (DVWA v1.10)  
**Category:** Web Application Security — Authentication Brute Force  
**OWASP Reference:** A07:2021 — Identification and Authentication Failures

---

## Summary

A brute force attack against the DVWA login form using ffuf and SecLists.
Tested across Low and Medium security levels to understand both the attack and how server-side defenses affect it.

---

## Folder Structure

```
dvwa-brute-force/
├── README.md                        ← This file
├── report/
│   └── full_report.md               ← Detailed written report
├── scripts/
│   ├── 01_ffuf_low.sh               ← ffuf attack on Low security
│   └── 02_ffuf_medium.sh            ← ffuf attack on Medium security
└── notes/
    └── findings.md                  ← Raw findings and observations
```

---

## Results Summary

| Security Level | Password Found | Speed | Time |
|---------------|---------------|-------|------|
| Low | ✅ `password` | 1666 req/sec | ~6 seconds |
| Medium | ✅ `password` | ~1 req/sec | ~3-4 hours |

---

## Key Takeaway

The same attack works on both levels — Medium just adds a `sleep(2)` delay server-side, making it significantly slower but not impossible.
