# SkattCTF — Full Penetration Testing Report

**Author:** m  
**Date:** 2026-03-02  
**Target:** https://skatt.ctfd.io  
**Platform:** CTFd  
**Category:** Web Application Security — Authentication Bypass  
**OWASP Reference:** A07:2021 — Identification and Authentication Failures

---

## 1. Objective

Gain access to the SkattCTF platform by bypassing or circumventing the site participation password gate, using web security techniques.

---

## 2. Reconnaissance

### 2.1 Initial Observation

Navigating to `https://skatt.ctfd.io` presents a "Password Required" page before any content is accessible. All routes (`/challenges`, `/users`, `/scoreboard`) return `HTTP 401 Unauthorized`.

### 2.2 Page Source Analysis

Viewed page source with `Ctrl+U`. Discovered the password mechanism is implemented in client-side JavaScript:

```javascript
// Clears any existing cookie on page load
document.cookie = 'site_password=; expires=Thu, 01 Jan 1970 00:00:01 GMT;';

function setCookie(name, value, days) {
    var expires = "";
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days*24*60*60*1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/";
}

function submitPassword(){
    var password = document.getElementById('site_password').value;
    setCookie("site_password", password, 7);
    window.location.reload();
    return false;
}
```

**Key finding:** The form sets the submitted value as a cookie named `site_password`, then reloads. The server checks this cookie and returns `401` if it doesn't match the real password.

### 2.3 Additional Findings in Source

```javascript
window.init = {
    'start': 1772967600,   // Unix timestamp = Mon May 05 2025
    'end':   1773172800,   // Unix timestamp = Wed May 07 2025
    'userMode': "teams",
}
```

The CTF is scheduled for May 2025 — the site password is likely held until the event begins.

Also found a referenced asset: `/files/5289b8dd3fae5f99fce5b23136024d49/red_tax2.png`  
This file returns `401` without the password — inaccessible without authentication.

### 2.4 Network Analysis

Using DevTools Network tab, confirmed:
- All requests return `401 Unauthorized`
- No POST request is made — password is handled entirely via cookie + page reload
- No rate limiting detected on the endpoint

---

## 3. Attack Methodology

### 3.1 Method 1 — Manual Cookie Manipulation

**Tool:** Chrome DevTools → Application → Cookies  
**Approach:** Manually added `site_password` cookie with guessed values

Passwords tried manually:
- `skatt`, `welcome`, `admin`, `password`, `ctf`

**Result:** ❌ All returned "That password is incorrect"

Also tested via Console:
```javascript
document.cookie = "site_password=skatt"
// Refresh — still 401
```

---

### 3.2 Method 2 — JavaScript Brute Force (Browser Console)

**Tool:** Chrome DevTools Console  
**Approach:** Automated cookie setting + fetch to `/challenges` to detect 200 response

See: `scripts/02_js_bruteforce.js`

**Result:** X All 20 passwords returned `401`

---

### 3.3 Method 3 — ffuf Dictionary Attack

**Tool:** ffuf v2.1.0-dev  
**Wordlist:** SecLists `10k-most-common.txt` (10,000 passwords)  
**Approach:** Cookie fuzzing — inject each password as `site_password` cookie value

See: `scripts/03_ffuf_bruteforce.sh`

**Stats:**
| Metric | Value |
|--------|-------|
| Passwords tried | 10,000 |
| Speed | ~312–373 req/sec |
| Duration | ~32 seconds |
| Successful hits | 0 |

**Result:** X No passwords produced anything other than `401`

---

## 4. Conclusions

| Finding | Detail |
|---------|--------|
| Authentication type | Cookie-based, server-side validated |
| Client-side bypass | Not possible — server validates cookie value |
| Password in common wordlists | No |
| Rate limiting detected | No |
| Vulnerable to brute force | Theoretically yes, practically no |

The site password is a **privately distributed string** shared only with event participants. It is not guessable via common wordlists and brute forcing a random string is computationally infeasible.

---

## 5. What Was Learned

- How CTFd implements site password protection
- How to read and analyze HTML/JavaScript source code
- How cookie-based authentication works
- How to manipulate cookies via DevTools and JavaScript
- How to use `ffuf` for HTTP fuzzing
- How to interpret HTTP status codes in a security context
- How to set up and use SecLists wordlists

---

## 6. Tools Used

| Tool | Version | Purpose |
|------|---------|---------|
| Chrome DevTools | Built-in | Source analysis, cookie manipulation, network inspection |
| ffuf | v2.1.0-dev | HTTP fuzzing / brute force |
| SecLists | Latest | Password wordlists |
| Docker | Latest | Local lab environment |

---

## 7. References

- [CTFd Documentation](https://docs.ctfd.io)
- [OWASP A07 — Authentication Failures](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)
- [ffuf GitHub](https://github.com/ffuf/ffuf)
- [SecLists GitHub](https://github.com/danielmiessler/SecLists)
