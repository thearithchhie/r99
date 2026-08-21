import siemreapTtf from "@/assets/fonts/Siemreap-Regular.ttf";

const fontUrl = new URL(siemreapTtf, window.location.origin).href;

export const PRINT_STYLES = `@page{size:58mm 102mm;margin:0}
*{box-sizing:border-box;margin:0;padding:0;-webkit-print-color-adjust:exact;print-color-adjust:exact}
@font-face{font-family:'Siemreap';src:url('${fontUrl}') format('truetype');font-display:swap}
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
