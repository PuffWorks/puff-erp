# Hardware20260607_1 - Linux CentOS 7.9 閮ㄧ讲鍖?
鐢熸垚鏃ユ湡锛?(Get-Date -Format 'yyyy-MM-dd')

鏈寘闈㈠悜 Linux CentOS 7.9 / 瀹濆鐜锛屽寘鍚噸鏂版瀯寤虹殑鍓嶇 dist銆丩inux amd64 鍚庣銆佹暟鎹簱瀹屾暣 SQL 鍜岃縼绉昏剼鏈€?
## 鍖呭唴瀹?
- **frontend/**锛歏ite 鐢熶骇鏋勫缓鍚庣殑鍓嶇闈欐€佹枃浠?- **backend/hardware-erp**锛歀inux amd64 鍚庣鍙墽琛屾枃浠?- **backend/config.yaml**锛氱敓浜ч厤缃ā鏉匡紙涓婄嚎鍓嶅繀椤讳慨鏀规暟鎹簱瀵嗙爜銆丷edis 瀵嗙爜銆乯wt.secret锛?- **backend/license_public.key**锛氳鍙瘉鍏挜
- **database/Hardware20260607_1_full.sql**锛氬畬鏁?SQL锛屽寘鍚墍鏈夎縼绉?(001-069)
- **database/hardware_erp_full.sql**锛氬畬鏁?SQL 鐨勯€氱敤鏂囦欢鍚嶅壇鏈?- **database/migrations/**锛氬崟涓縼绉绘枃浠?001-069
- **nginx/hardware-erp.conf**锛歂ginx 绀轰緥閰嶇疆
- **server_install_or_update.sh**锛氭湇鍔″櫒瀹夎/鏇存柊鑴氭湰

## 蹇€熼儴缃?
### 1. 涓婁紶骞惰В鍘?
\\\ash
cd /tmp
tar -xzf Hardware20260607_1.tar.gz
cd Hardware20260607_1
\\\

### 2. 鍏ㄦ柊瀹夎锛堝惈鏁版嵁搴撳垵濮嬪寲锛?
\\\ash
chmod +x server_install_or_update.sh
DB_MODE=full DB_NAME=hardware_erp_mvp DB_USER=root DB_PASSWORD='鎮ㄧ殑鏁版嵁搴撳瘑鐮? ./server_install_or_update.sh
\\\

### 3. 鏇存柊宸叉湁绯荤粺锛堜笉鍔ㄦ暟鎹簱锛?
\\\ash
DB_MODE=skip ./server_install_or_update.sh
\\\

### 4. 鏇存柊宸叉湁绯荤粺骞跺簲鐢ㄦ柊杩佺Щ

渚嬪浠庝箣鍓嶇殑鐗堟湰琛ヨ窇杩佺Щ鑷?
\\\ash
DB_MODE=migrate MIGRATION_FROM=068 MIGRATION_TO=069 DB_NAME=hardware_erp_mvp DB_USER=root DB_PASSWORD='鎮ㄧ殑鏁版嵁搴撳瘑鐮? ./server_install_or_update.sh
\\\

## 閰嶇疆璇存槑

閮ㄧ讲鍚庤绔嬪嵆淇敼閰嶇疆鏂囦欢锛?
\\\ash
vi /www/wwwroot/hardware-erp/backend/config.yaml
\\\

蹇呴』淇敼鐨勯厤缃」锛?- \mysql.password\锛氭暟鎹簱瀵嗙爜
- \jwt.secret\锛氭敼涓洪殢鏈哄瓧绗︿覆锛堣嚦灏?32 浣嶏級
- \edis.password\锛氬鏋?Redis 鏈夊瘑鐮?
## 鏈嶅姟绠＄悊

\\\ash
# 鏌ョ湅鏈嶅姟鐘舵€?systemctl status hardware-erp-api

# 閲嶅惎鏈嶅姟
systemctl restart hardware-erp-api

# 鏌ョ湅鏃ュ織
tail -f /www/wwwroot/hardware-erp/backend/logs/app.log

# 鍋ュ悍妫€鏌?curl http://127.0.0.1:8080/healthz
\\\

## Nginx 閰嶇疆

灏?\
ginx/hardware-erp.conf\ 澶嶅埗 to Nginx 閰嶇疆鐩綍锛屾垨鍦ㄥ疂濉旈潰鏉夸腑閰嶇疆锛?
绔欑偣鏍圭洰褰曪細\/www/wwwroot/hardware-erp/frontend\

`
ginx
location / {
    try_files $uri $uri/ /index.html;
}

location /api/v1/ {
    proxy_pass http://127.0.0.1:8080/api/v1/;
}
`

## 榛樿璐﹀彿

- 鐢ㄦ埛鍚嶏細dmin
- 瀵嗙爜锛歚admin123

**閲嶈**锛氫笂绾垮悗绔嬪嵆淇敼绠＄悊鍛樺瘑鐮侊紒

## 瀹夊叏寤鸿

1. 浠呭紑鏀?80/443 绔彛鍒板叕缃?2. 鍚庣 8080銆丮ySQL 3306銆丷edis 6379 涓嶈鐩存帴鏆撮湶鍏綉
3. 淇敼鎵€鏈夐粯璁ゅ瘑鐮?and 瀵嗛挜
4. 瀹氭湡澶囦唤鏁版嵁搴?5. 鐩戞帶鏃ュ織鏂囦欢澶у皬

## 澶囦唤浣嶇疆

鑴氭湰浼氳嚜鍔ㄥ浠芥棫鏂囦欢鍜屾暟鎹簱鍒帮細/www/backup/hardware-erp/