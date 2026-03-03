# SkattCTF — Authentication Bypass Attempt
**Author:** m  
**Date:** 2026-03-02  
**Target:** https://skatt.ctfd.io  
**Category:** Web Application Security — Authentication Bypass  
**Status:** Password not found (privately held by organizer)

---

## Summary

SkattCTF is a Norwegian-themed CTF platform ("Skatt" = Tax in Norwegian) built on CTFd.
The site requires a participation password before granting access to any content.

This documents the full methodology used to attempt bypassing or brute forcing the site password gate.

---

## Folder Structure

```
skattctf/
├── README.md                   ← This file
├── report/
│   └── full_report.md          ← Detailed written report
├── scripts/
│   ├── 01_cookie_manual.js     ← Manual cookie setting in browser
│   ├── 02_js_bruteforce.js     ← Browser console brute force script
│   └── 03_ffuf_bruteforce.sh   ← Terminal ffuf attack command
└── notes/
    └── findings.md             ← Raw findings and observations
```

---

## Quick Results

| Method | Tool | Result |
|--------|------|--------|
| Manual cookie manipulation | DevTools | ❌ Server-side validation |
| JavaScript brute force | Browser Console | ❌ All 401 |
| Dictionary attack | ffuf + SecLists 10k | ❌ All 401 |

---

## Key Finding

The password form is client-side JavaScript but validated server-side.
The password is a privately shared string — not in any common wordlist.

```
HTTP 401 = Wrong password
HTTP 200 = Correct password (never achieved)
```
