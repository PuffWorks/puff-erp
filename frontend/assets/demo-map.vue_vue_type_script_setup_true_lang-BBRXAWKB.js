import{d as p,d0 as l,d1 as m,r as f,o as _,b1 as k,Z as y,a as u,k as w,w as x,e as v}from"./index-DWf9rLmA.js";import{_ as h}from"./index-DjE6inZ3.js";import{A as g}from"./index-DKq3bB1m.js";const I=p({__name:"demo-map",setup(M){const r=l(),{darkMode:n}=m(r),t=f(null);let o;const d=()=>{g.load({key:"006d995d433058322319fa797f2876f5",version:"2.0",plugins:["AMap.InfoWindow","AMap.Marker"]}).then(e=>{const s={zoom:13,center:[114.346084,30.516215],mapStyle:n.value?"amap://styles/dark":void 0};o=new e.Map(t.value,s);const a=new e.InfoWindow({content:`
            <div style="color: #333;">
              <div style="padding: 5px;font-size: 16px;">武汉易云智科技有限公司</div>
              <div style="padding: 0 5px;">地址: 湖北省武汉市洪山区雄楚大道222号</div>
              <div style="padding: 0 5px;">电话: 020-123456789</div>
            </div>
            <a
              style="padding: 8px 0 0 5px;text-decoration: none;display: inline-block;color: #1677ff;"
              href="//uri.amap.com/marker?position=114.346084,30.511215&name=武汉易云智科技有限公司"
              target="_blank">到这里去→
            </a>
          `});a.open(o,[114.346084,30.511215]);const c=new e.Icon({size:new e.Size(25,34),image:"//a.amap.com/jsapi_demos/static/demo-center/icons/poi-marker-red.png",imageSize:new e.Size(25,34)}),i=new e.Marker({icon:c,position:[114.346084,30.511215],offset:new e.Pixel(-12,-28)});i.setMap(o),i.on("click",()=>{a.open(o)})}).catch(e=>{console.error(e)})};return _(()=>{d()}),k(()=>{o&&(o.destroy(),o=null)}),y(n,e=>{o&&(e?o.setMapStyle("amap://styles/dark"):o.setMapStyle("amap://styles/normal"))}),(e,s)=>{const a=h;return u(),w(a,{header:"官网底部地图"},{default:x(()=>[v("div",{ref_key:"locationMapRef",ref:t,style:{height:"360px","max-width":"800px"}},null,512)]),_:1})}}});export{I as _};
