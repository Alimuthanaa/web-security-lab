// ============================================================
// Script 01 — Manual Cookie Setting
// Target: https://skatt.ctfd.io
// Tool: Chrome DevTools Console
// Description: Manually set site_password cookie with a guess
// ============================================================

// Method 1: Set cookie directly
document.cookie = "site_password=skatt; path=/";

// Then refresh the page to test:
// window.location.reload();

// ------------------------------------------------------------
// Method 2: Using the site's own setCookie function
// (copied from page source)
// ------------------------------------------------------------

function setCookie(name, value, days) {
    var expires = "";
    if (days) {
        var date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/";
}

// Usage:
setCookie("site_password", "skatt", 7);
window.location.reload();

// ------------------------------------------------------------
// Passwords tried manually:
// skatt        → X incorrect
// skattctf     → X incorrect
// welcome      → X incorrect
// admin        → X incorrect
// password     → X incorrect
// ------------------------------------------------------------
