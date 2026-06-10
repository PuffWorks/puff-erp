import{e8 as $,b1 as v}from"./index-DWf9rLmA.js";const p="ele-printer-container",y="ele-printer-iframe",d="ele-printing";let w=0;function P(e,t){return e==null?t:Object.assign({},e,t)}function L(){const e=document.getElementById(p);if(e)return e;const t=document.createElement("div");return t.id=p,document.body.appendChild(t),t}function g(e){const t=["@page {"];if(e.margin!=null&&e.margin!==""){const r=typeof e.margin=="number"?e.margin+"px":e.margin;t.push(`margin: ${r};`)}return e.direction!=null&&e.direction!==""&&t.push(`size: ${e.direction};`),e.orientation!=null&&e.orientation!==""&&t.push(`page-orientation: ${e.orientation};`),t.push("}"),t.join(" ")}function h(){const e=document.getElementById(y);if(e){e.parentNode&&e.parentNode.removeChild(e);const t=e.getAttribute("src");if(t)try{window.URL.revokeObjectURL(t)}catch(r){console.error(r)}}}function b(){h();const e=document.createElement("iframe");return e.id=y,e.style.width="66px",e.style.height="66px",e.style.position="fixed",e.style.left="-666px",e.style.top="-666px",document.body.appendChild(e),e.focus(),e}function O(e,t,r){var m;const n=b(),i=n.contentWindow;if(!i)return;i.focus();const o=n.contentDocument||i.document;if(!o)return;const s=L();Array.from(s.querySelectorAll('input[type="text"], input[type="number"]')).forEach(f=>{f.setAttribute("value",f.value)}),o.open();const a=e.options?`JSON.parse('${JSON.stringify(e.options)}')`:"",l=`
  <style type="text/css" media="print">
    ${g(e)}
  </style>
  <script>
    const $html = document.querySelector('html');
    if($html && $html.classList && $html.classList.add) {
      $html.classList.add('${d}');
    }
    window.onload = function() {
      if(${e.title==null?0:1}) {
        document.title = '${e.title}';
      }
      setTimeout(() => {
        window.print(${a});
        window.parent.postMessage('elePrintDone_${t}', '*');
      ${["}, ",r,");"].join("")}
    };
  <\/script>
  `,u=(((m=document.querySelector("html"))==null?void 0:m.outerHTML)||"").replace(/<script/g,'<textarea style="display:none;" ').replace(/<\/script>/g,"</textarea>").replace(/<\/html>/,l+"</html>");return o.write(`<!DOCTYPE html>${u}`),o.close(),i}function C(e){w++;const t=w,r=500,[n]=$(r),i=(s,a)=>{if(a==="_iframe"){O(s,t,r);return}const l=document.querySelector("html");if(!l){e&&e();return}l.classList.add(d);const c=document.createElement("style");c.setAttribute("type","text/css"),c.setAttribute("media","print"),c.innerHTML=g(s),document.body.appendChild(c);const u=document.title;s.title!=null&&s.title!==""&&(document.title=s.title),n(()=>{window.print(s.options),n(()=>{l.classList.remove(d),document.body.removeChild(c),s.title!=null&&(document.title=u),e&&e()})})},o=s=>{s.data===`elePrintDone_${t}`&&n(()=>{h(),e&&e()})};return v(()=>{window.removeEventListener("message",o)}),window.addEventListener("message",o),i}function E(e){const t=b();t.onload=()=>{const n=t.getAttribute("src");if(n){t.focus();try{t.contentWindow&&t.contentWindow.print(e.options),e.done&&e.done(),window.URL.revokeObjectURL(n);return}catch(i){console.error(i)}!e.arraybuffer&&e.url?(window.URL.revokeObjectURL(n),window.open(e.url)):window.open(n),e.done&&e.done()}};const r=n=>{const i=new window.Blob([n],{type:"application/pdf"});if(window.navigator&&window.navigator.msSaveOrOpenBlob){window.navigator.msSaveOrOpenBlob(i,"print.pdf"),e.done&&e.done();return}t.setAttribute("src",window.URL.createObjectURL(i))};if(e.arraybuffer){r(e.arraybuffer);return}if(e.url){const n=new window.XMLHttpRequest;n.open("GET",e.url,!0),n.responseType="arraybuffer",n.onload=()=>{if([200,201].indexOf(n.status)!==-1){r(n.response);return}e.error&&e.error(n.status,n.statusText)},n.send()}}export{L as g,P as m,E as p,C as u};
