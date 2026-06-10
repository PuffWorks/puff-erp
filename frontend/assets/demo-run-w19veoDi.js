import{d as V,r as n,o as R,b1 as B,bV as M,d2 as E,a as r,k as S,w as g,e as t,g as a,m as _,h2 as z,n as H,dm as T,b as x,f as W,R as X,t as Y,F as $,aK as C,_ as j}from"./index-DWf9rLmA.js";import{_ as D}from"./index-DjE6inZ3.js";import{_ as h}from"./index.vue_vue_type_script_setup_true_lang-D7nxPxxF.js";import{g as L}from"./demo-codes-C4Lto5GV.js";const U={class:"run-wrapper"},A={class:"editor-wrapper"},F={class:"editor-item"},I={class:"editor-item-header"},K={class:"editor-item-body"},N={class:"editor-item"},q={class:"editor-item-body"},J={class:"editor-item"},O={class:"editor-item-body"},P={class:"result-wrapper"},G={class:"frame-header"},Q={class:"result-body"},Z={class:"console-wrapper"},ee=V({__name:"demo-run",setup(te){const c=n(`<div style="text-align: center;padding-top: calc(50vh - 24px);">
  <div class="demo-btn" onclick="console.warn('点击了登录按钮');">登录</div>
  <div class="demo-btn" onclick="abcdefghijk">注册</div>
</div>
<canvas class="bg-canvas" id="bgCanvas"></canvas>
`),m=n(`html {
  height: 100%;
}

body {
  margin: 0;
  padding: 0;
  height: 100%;
  background: #001121;
}

.bg-canvas {
  position: fixed;
  top: 0;
  left: 0;
  opacity: 0.6;
  pointer-events: none;
  z-index: -1;
}

.demo-btn {
  color: #01c1ec;
  background: rgba(1, 193, 236, 0.38);
  backdrop-filter: blur(4px);
  padding: 14px 42px;
  display: inline-block;
  clip-path: polygon(0 0, 90% 0, 100% 28%, 100% 100%, 10% 100%, 0 72%);
  transition: all 0.2s;
  letter-spacing: 8px;
  font-weight: bold;
  user-select: none;
  cursor: pointer;
}

.demo-btn:hover {
  color: #fff;
  background: rgba(1, 193, 236, 0.68);
}

.demo-btn + .demo-btn {
  margin-left: 12px;
}
`),u=n(`console.log('Hello World!');

const bgCanvas = document.getElementById('bgCanvas');
const ctx = bgCanvas.getContext('2d');
let width = window.innerWidth;
let height = window.innerHeight;
bgCanvas.width = width;
bgCanvas.height = height;

const points = Array.from({ length: 250 }).map(function () {
  return {
    x: Math.random() * width,
    y: Math.random() * height,
    xa: 2 * Math.random() - 1,
    ya: 2 * Math.random() - 1,
    max: 9000
  };
});

const cursor = { x: null, y: null, max: 20000 };

window.onmousemove = function (e) {
  cursor.x = e.clientX;
  cursor.y = e.clientY;
};

window.onmouseout = function () {
  cursor.x = null;
  cursor.y = null;
};

window.onresize = function () {
  width = window.innerWidth;
  height = window.innerHeight;
  bgCanvas.width = width;
  bgCanvas.height = height;
};

function move() {
  ctx.clearRect(0, 0, width, height);
  const data = [cursor].concat(points);
  points.forEach(function (item) {
    item.x += item.xa;
    item.y += item.ya;
    item.xa *= item.x > width || item.x < 0 ? -1 : 1;
    item.ya *= item.y > height || item.y < 0 ? -1 : 1;
    ctx.fillRect(item.x - 0.5, item.y - 0.5, 1, 1);
    data.forEach((p) => {
      if (item !== p && null !== p.x && null !== p.y) {
        const dX = item.x - p.x;
        const dY = item.y - p.y;
        const distance = dX * dX + dY * dY;
        if (distance < p.max) {
          if (p === cursor && distance >= p.max / 2) {
            item.x -= 0.03 * dX;
            item.y -= 0.03 * dY;
          }
          const level = (p.max - distance) / p.max;
          ctx.beginPath();
          ctx.lineWidth = level / 2;
          ctx.strokeStyle = 'rgba(1, 211, 255, ' + (level + 0.2) + ')';
          ctx.moveTo(item.x, item.y);
          ctx.lineTo(p.x, p.y);
          ctx.stroke();
        }
      }
    });
    data.splice(data.indexOf(item), 1);
  });
  window.requestAnimationFrame(move);
}

move();

console.log('Start Move.');
`),y=n(null),w=n(0),p=n(null),v=n([]),l=i=>{var s,d;if(!i){w.value++,C(()=>{l(!0)});return}v.value=[];const e=(d=(s=y.value)==null?void 0:s.contentWindow)==null?void 0:d.document;e&&(e.open(),e.write(L(m.value,c.value,u.value)),e.close())},b=i=>{i.data&&i.data.id==="iframeConsole"&&(v.value.push(i.data),C(()=>{var e,s;(s=(e=p.value)==null?void 0:e.scrollTo)==null||s.call(e,0,p.value.scrollHeight)}))};R(()=>{window.addEventListener("message",b),l(!0)}),B(()=>{window.removeEventListener("message",b)});const f=n(!1);return M(()=>{f.value&&(l(!0),f.value=!1)}),E(()=>{f.value=!0}),(i,e)=>{const s=H,d=D;return r(),S(d,{header:"代码运行","body-style":{padding:"12px"}},{default:g(()=>[t("div",U,[t("div",A,[t("div",F,[t("div",I,[a(s,{class:"editor-item-icon"},{default:g(()=>[a(_(z))]),_:1}),e[4]||(e[4]=t("div",null,"HTML",-1))]),t("div",K,[a(h,{modelValue:c.value,"onUpdate:modelValue":e[0]||(e[0]=o=>c.value=o),language:"html",style:{height:"128px"}},null,8,["modelValue"])])]),t("div",N,[e[5]||(e[5]=t("div",{class:"editor-item-header"},[t("div",{class:"editor-item-icon is-css"},"*"),t("div",null,"CSS")],-1)),t("div",q,[a(h,{modelValue:m.value,"onUpdate:modelValue":e[1]||(e[1]=o=>m.value=o),language:"css",style:{height:"220px"}},null,8,["modelValue"])])]),t("div",J,[e[6]||(e[6]=t("div",{class:"editor-item-header"},[t("div",{class:"editor-item-icon is-js"},"{}"),t("div",null,"JS")],-1)),t("div",O,[a(h,{modelValue:u.value,"onUpdate:modelValue":e[2]||(e[2]=o=>u.value=o),language:"javascript",style:{height:"320px"}},null,8,["modelValue"])])])]),t("div",P,[t("div",G,[e[7]||(e[7]=t("div",{class:"frame-tool"},null,-1)),e[8]||(e[8]=t("div",{class:"frame-tool is-warning"},null,-1)),e[9]||(e[9]=t("div",{class:"frame-tool is-success"},null,-1)),e[10]||(e[10]=t("div",{style:{margin:"1.68px 2px 0 auto","font-size":"12px"}},"重新运行",-1)),t("div",{class:"frame-btn",onClick:e[3]||(e[3]=o=>l())},[a(s,{style:{transform:"scale(1.09) translate(0.38px, 0.48px)"}},{default:g(()=>[a(_(T))]),_:1})])]),t("div",Q,[(r(),x("iframe",{key:w.value,ref_key:"iframeRef",ref:y}))]),t("div",Z,[e[11]||(e[11]=t("div",{class:"console-header"},[t("span",{style:{"font-family":"Consolas","vertical-align":"-1px"}},[t("span",{style:{"font-size":"18px"}},">"),t("span",{style:{margin:"0 4px 0 -4px","vertical-align":"2px"}},"_")]),t("span",null,"Console")],-1)),t("div",{ref_key:"consoleBodyRef",ref:p,class:"console-body"},[(r(!0),x($,null,W(v.value,(o,k)=>(r(),x("pre",{key:k,class:X(["console-item",{"is-error":o.type==="error"},{"is-warn":o.type==="warn"}])},Y(o.code),3))),128))],512)])])])]),_:1})}}}),ie=j(ee,[["__scopeId","data-v-3a9bc307"]]);export{ie as default};
