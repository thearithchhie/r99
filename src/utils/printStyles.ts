import siemreapTtf from "@/assets/fonts/Siemreap-Regular.ttf?url";

const CSS_BODY = `@page{size:58mm 102mm;margin:0}
*{box-sizing:border-box;margin:0;padding:0;-webkit-print-color-adjust:exact;print-color-adjust:exact}
body{font-family:'Siemreap',sans-serif;width:58mm;background:#fff;padding:1pt}
.card{border-radius:12pt;border:1.2pt solid #000;padding:6pt 6pt;margin-top:2pt;page-break-inside:avoid;}
.page-break{page-break-after:always;margin-bottom:1mm;}
.hrow{display:flex;align-items:center;justify-content:center;gap:4pt;font-size:11pt;font-weight:bold;color:#000;margin-bottom:1pt}
.sender-label{display:flex;align-items:center;justify-content:center;gap:4pt;font-size:10pt;font-weight:bold;color:#000;margin-bottom:1pt}
.sender-phone{text-align:center;font-family:system-ui,-apple-system,sans-serif;font-size:11.5pt;font-weight:bold;color:#000;margin-bottom:3pt}
.sec-hdr{display:flex;align-items:center;gap:3pt;margin-top:3pt;margin-bottom:1pt;font-size:10.5pt;font-weight:bold;color:#000}
.sec-val{background:#fff;border-radius:8pt;border:0.5pt solid #b8b8b8;padding:2pt 8pt;font-family:system-ui,-apple-system,sans-serif;font-size:12pt;font-weight:bold;color:#000;margin-bottom:1pt}
.sec-val.phone{font-size:10.5pt}
.sec-val.loc{font-family:'Siemreap',sans-serif;font-size:8.5pt;padding:2pt 8pt}
.drow{background:#fff;border-radius:8pt;border:0.5pt solid #b8b8b8;display:flex;align-items:center;justify-content:space-between;padding:0 6pt;height:20pt;font-size:9.8pt;font-weight:bold;color:#000;margin-top:3pt;margin-bottom:2pt}
.drow-amt{font-size:9.4pt}
.drow-left{display:inline-flex;align-items:center;gap:3pt}
.icon{flex-shrink:0}
.chips{display:flex;gap:4pt}
.chip{flex:1;min-width:0;background:#fff;border-radius:8pt;border:0.5pt solid #b8b8b8;padding:2pt 3pt;display:flex;align-items:center;justify-content:flex-start;gap:3pt;overflow:hidden;font-size:8pt;font-weight:bold;color:#000;min-height:18pt}
.klabel{font-family:'Siemreap',sans-serif;font-size:6.5pt;text-align:left;line-height:1.2}
.chk{width:12pt;height:12pt;border:1pt solid #000;border-radius:2pt;flex-shrink:0;display:flex;align-items:center;justify-content:center;font-family:system-ui,-apple-system,sans-serif;font-size:10pt;line-height:1}
.footer{text-align:center;font-size:9.2pt;font-weight:bold;color:#000;line-height:1.3;margin-top:3pt}`;

function buildStyles(fontSrc: string): string {
  return `@font-face{font-family:'Siemreap';src:url('${fontSrc}') format('truetype');font-display:swap}${CSS_BODY}`;
}

// Cached base64 font — fetched once, then reused for all print calls
let _cachedStyles: string | null = null;

export async function getPrintStyles(): Promise<string> {
  if (_cachedStyles) return _cachedStyles;
  try {
    const res = await fetch(siemreapTtf);
    const buf = await res.arrayBuffer();
    const bytes = new Uint8Array(buf);
    let bin = "";
    for (let i = 0; i < bytes.length; i++) bin += String.fromCharCode(bytes[i]);
    const b64 = `data:font/truetype;base64,${btoa(bin)}`;
    _cachedStyles = buildStyles(b64);
  } catch {
    // Fallback to URL if fetch fails
    _cachedStyles = buildStyles(new URL(siemreapTtf, window.location.origin).href);
  }
  return _cachedStyles;
}

// Synchronous fallback kept for any legacy references
export const PRINT_STYLES = buildStyles(new URL(siemreapTtf, window.location.origin).href);

/**
 * Hidden iframe print — works on desktop without a user gesture.
 * Use this for WebSocket-triggered auto-print on Mac.
 * Do NOT use on iOS (iframe.print is a no-op there).
 */
export async function printWithIframe(buildContent: (styles: string) => string): Promise<void> {
  const styles = await getPrintStyles();
  const html = buildContent(styles);
  return new Promise<void>((resolve) => {
    const iframe = document.createElement("iframe");
    iframe.style.cssText = "position:fixed;left:-9999px;top:-9999px;width:58mm;height:102mm;border:0";
    document.body.appendChild(iframe);
    const win = iframe.contentWindow!;
    const doc = iframe.contentDocument!;
    doc.write(html);
    doc.close();
    doc.fonts.ready.then(() => {
      win.print();
      const cleanup = () => { iframe.remove(); resolve(); };
      win.addEventListener("afterprint", cleanup, { once: true });
      setTimeout(cleanup, 30_000);
    });
  });
}

/**
 * Open a new window immediately (preserving user gesture for iOS/popup blocker),
 * then inject font-inlined styles + auto-print script into the HTML.
 * Works on desktop, Android, and iOS Safari.
 */
export async function printHtml(buildContent: (styles: string) => string): Promise<void> {
  // Must be synchronous — opens before any await so popup blocker allows it
  const win = window.open("", "_blank");
  if (!win) return;

  const styles = await getPrintStyles();

  // Embedded auto-print — runs in the new window's own context (iOS-compatible)
  const autoprint = `<script>window.addEventListener('load',function(){setTimeout(function(){window.print();window.addEventListener('afterprint',function(){window.close();},{once:true});},300);});<\/script>`;

  const html = buildContent(styles).replace("</head>", autoprint + "</head>");
  win.document.write(html);
  win.document.close();
}
