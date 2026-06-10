function n(i){if(i==="***")return"***";const t=Number(i!=null?i:0);return Number.isFinite(t)?`¥${t.toLocaleString("zh-CN",{minimumFractionDigits:0,maximumFractionDigits:4})}`:"***"}export{n as m};
