// ==UserScript==
// @name         Userstyle (github.css)
// @match        *://github.com/*
// @run-at       document-end
// @grant        GM_addStyle
// ==/UserScript==

GM_addStyle(`
  * {
    border-radius: 0px !important;
  }

  body {
    font-family: JetBrains Mono, monospace !important;
  }
`)
