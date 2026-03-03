# SkattCTF — Raw Findings & Observations

## Target Info
- URL: https://skatt.ctfd.io
- Platform: CTFd (cloud hosted)
- CTF dates: May 5–7 2025 (from source code timestamps)
- Theme: Norwegian tax ("Skatt" = Tax in Norwegian)

---

## Page Source Findings

### Password mechanism (client-side JS)
- Form submits via `submitPassword()` JavaScript function
- Sets cookie `site_password` with submitted value
- Reloads page — server checks cookie server-side
- No actual POST request is made to the server

### CTF timing (Unix timestamps from source)
- Start: `1772967600` = Monday May 5, 2025
- End:   `1773172800` = Wednesday May 7, 2025

### Hidden asset found
- `/files/5289b8dd3fae5f99fce5b23136024d49/red_tax2.png`
- Also used as the favicon
- Returns 401 without valid password cookie
- Possibly a hint/clue for inside the CTF

### CSRF nonce found in source
- `csrfNonce: "5e4bfa15e39f88f4085c66cd10815cd7a6df25d3c1c0f8c7b58c88ee794e925f"`
- Not useful for password bypass

---

## HTTP Response Observations

| Endpoint | Method | Response |
|----------|--------|----------|
| / | GET | 401 |
| /challenges | GET | 401 |
| /users | GET | 401 |
| /scoreboard | GET | 401 |
| /red_tax2.png | GET | 401 |
| / | POST (wrong path) | 404 |

---

## Cookie Behavior
- On page load: existing `site_password` cookie is **cleared** by the JS
- On submit: new cookie set with 7-day expiry
- Server validates cookie value and returns 401 if wrong

---

## Rate Limiting
- No rate limiting detected during ffuf scan at 40 threads
- ~373 requests/second sustained without blocks or CAPTCHAs
- No IP ban observed

---

## Conclusion
Password is privately held. Not in SecLists 10k common passwords.
Next step when CTF opens: get password from organizer/Discord.
