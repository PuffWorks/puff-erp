import{d as c,r as a,a as s,k as i,w as d,e as p,g as v}from"./index-DWf9rLmA.js";import{_ as m}from"./index-DjE6inZ3.js";import{_ as f}from"./index.vue_vue_type_script_setup_true_lang-D7nxPxxF.js";const y={style:{border:"1px solid var(--el-border-color)"}},k=c({__name:"demo-diff",setup(g){const o=a(`/**
 * 下载文件
 * @param data 二进制数据
 * @param name 文件名
 * @param type 文件类型
 */
export function download(data, name, type) {
  const blob = new Blob([data], { type: type || 'application/octet-stream' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = name;
  a.style.display = 'none';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}

/**
 * 深度克隆
 * @param value 对象
 */
export function cloneDeep(value) {
  const cache = new WeakMap();
  const clone = (value) => {
    if (typeof value !== 'object' || value == null) {
      return value;
    }
    // 处理 Date 对象
    if (value instanceof Date) {
      return new Date(value);
    }
    // 处理 RegExp 对象
    if (value instanceof RegExp) {
      return new RegExp(value.source, value.flags);
    }
    // 处理函数
    if (typeof value === 'function') {
      return value;
    }
    // 处理循环引用
    if (cache.has(value)) {
      return cache.get(value);
    }
    const result = Array.isArray(value) ? [] : {};
    cache.set(value, result);
    for (const key of Reflect.ownKeys(value)) {
      result[key] = clone(value[key]);
    }
    return result;
  };
  return clone(value);
}
`),n=a("javascript"),l=a(`/**
 * 下载文件
 * @param data 二进制数据
 * @param name 文件名
 */
export function download(data, name) {
  const blob = new Blob([data], { type: 'application/octet-stream' });
  const url = window.URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = name;
  a.style.display = 'none';
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}

/**
 * 深度克隆
 * @param value 对象
 */
export function cloneDeep(value) {
  const cache = new WeakMap();
  const clone = (value) => {
    if (typeof value !== 'object' || value === null) {
      return value;
    }
    if (cache.has(value)) {
      return cache.get(value);
    }
    const result = Array.isArray(value) ? [] : {};
    cache.set(value, result);
    for (const key of Reflect.ownKeys(value)) {
      result[key] = clone(value[key]);
    }
    return result;
  };
  return clone(value);
}
`),r=a("javascript");return(b,e)=>{const u=m;return s(),i(u,{header:"代码差异对比","body-style":{padding:"12px"}},{default:d(()=>[p("div",y,[v(f,{modelValue:o.value,"onUpdate:modelValue":e[0]||(e[0]=t=>o.value=t),language:n.value,original:l.value,"onUpdate:original":e[1]||(e[1]=t=>l.value=t),"original-language":r.value,diff:!0,style:{height:"460px"}},null,8,["modelValue","language","original","original-language"])])]),_:1})}}});export{k as _};
