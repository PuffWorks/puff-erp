# 硬件 ERP Linux 部署说明

本文档基于当前仓库的实际结构整理，适用于以下部署形态：

- 前端：`ele-admin-plus-ts-pro-erp`，构建后为静态文件
- 后端：`hardware-erp`，Go 单二进制 API 服务
- 反向代理：`Nginx`
- 数据库：`MySQL 8`
- 缓存：`Redis`
- 前端构建环境：`Node.js`

当前系统的典型生产拓扑如下：

```text
Browser
  -> Nginx :80 / :443
      -> /                前端静态文件
      -> /api/v1/         反向代理到 Go API :8080
Go API
  -> MySQL 8
  -> Redis
  -> /data/hardware-erp/uploads    上传目录
  -> /data/hardware-erp/logs       日志目录
```

## 1. 为什么生产环境优先选择 Linux

这套系统推荐优先部署在 Linux，而不是 Windows，原因不是习惯问题，而是运维成本和稳定性问题：

- 进程托管更稳定。Linux 原生适合用 `systemd` 托管 Go 服务，支持开机自启、自动拉起、日志管理、资源限制。
- 反向代理生态成熟。`Nginx` 在 Linux 上部署和调优最直接，静态资源、HTTPS、反向代理、限流都更成熟。
- 数据库和缓存的生产实践更完整。`MySQL`、`Redis` 在 Linux 上的安装、监控、备份、故障处理方案最丰富。
- 资源开销更低。相同配置下，Linux 通常比桌面型系统更节省资源，更适合长期驻留服务。
- 自动化能力更强。部署脚本、日志轮转、定时备份、CI/CD、权限隔离都更容易标准化。
- 安全边界更清晰。文件权限、最小权限账户、开放端口控制、SELinux/AppArmor、`iptables`/`nftables` 都更适合生产。

## 2. CentOS 7.9 和 Debian 如何选

如果是新部署，建议优先选择 Debian；如果客户现场已经统一使用 CentOS 7.9，也可以兼容部署，但不建议再作为新项目默认基线。

### 推荐 Debian 的原因

- 软件源更新，安装 `Go`、`Node.js`、`Nginx`、`Redis`、`MySQL 8` 更省事
- 默认系统更轻，依赖更干净
- 社区维护周期更清晰，适合作为长期维护基线
- 对当前这套 Go + Vue + Nginx 的组合更友好

### CentOS 7.9 仍可参考的场景

- 客户已有 CentOS 7.9 运维规范
- 现网服务器无法短期更换操作系统
- 需要兼容旧环境、旧监控或旧面板体系

### 选型结论

- 新项目：优先 `Debian 12/13`
- 旧环境续用：可参考 `CentOS 7.9`
- 说明：`CentOS Linux 7` 已于 `2024-06-30` 结束生命周期，继续使用时要明确安全更新风险

## 3. 当前系统部署要点

结合仓库内容，当前系统有几个关键点需要先说明：

- 前端生产环境默认请求地址是 `/api/v1`
- 后端默认监听 `8080`
- 推荐 `Nginx` 与后端同机部署，后端仅监听内网地址
- 上传文件不应放到前端站点根目录下，应走后端鉴权接口访问
- 数据库迁移要先执行，再启动新版本 API

当前生产配置文件参考 [configs/config.prod.yaml](f:/erp_gpt_20260507/hardware-erp/configs/config.prod.yaml)：

- `app.port: 8080`
- `mysql.database: hardware_erp_mvp`
- `storage.local_path: /data/hardware-erp/uploads`
- `log.path: /data/hardware-erp/logs/app.log`
- `cors.allowed_origins: []`

前端生产环境参考：

- [ele-admin-plus-ts-pro-erp/.env.production](f:/erp_gpt_20260507/ele-admin-plus-ts-pro-erp/.env.production)
- `VITE_API_URL=/api/v1`

这意味着最稳妥的方式是：

- 前端构建成静态文件
- `Nginx` 提供前端页面
- `Nginx` 将 `/api/v1/` 转发到 `127.0.0.1:8080`
- 前后端同域部署，通常不需要额外开放 CORS

## 4. 生产目录建议

推荐目录：

```text
/data/hardware-erp/
  backend/
    hardware-erp
    config.yaml
    license_public.key
  frontend/
  uploads/
  logs/
  license/
```

如果你沿用发布包里的结构，也可以使用：

```text
/www/wwwroot/hardware-erp/
  backend/
  frontend/
  nginx/
  database/
```

二者都可以，核心原则只有两个：

- 前后端目录分离
- 上传目录、日志目录与前端静态根目录分离

## 5. 部署前准备

建议服务器最低准备：

- CPU：2 核以上
- 内存：4 GB 以上
- 磁盘：40 GB 以上 SSD
- 端口：`80`、`443`

建议内网开放：

- `127.0.0.1:8080` 给 Go API
- `127.0.0.1:3306` 给 MySQL
- `127.0.0.1:6379` 给 Redis

生产环境不建议直接暴露：

- `3306`
- `6379`
- `8080`

## 6. Debian 部署示例

以下示例适合 Debian 12/13，命令按 root 或具备 sudo 权限的用户执行。

### 6.1 安装基础组件

```bash
apt update
apt install -y curl wget gnupg ca-certificates lsb-release unzip tar git vim
```

### 6.2 安装 Nginx

```bash
apt install -y nginx
systemctl enable nginx
systemctl start nginx
```

### 6.3 安装 Redis

```bash
apt install -y redis-server
systemctl enable redis-server
systemctl start redis-server
```

如需密码，修改 `/etc/redis/redis.conf`：

```conf
requirepass your-strong-redis-password
bind 127.0.0.1
```

然后重启：

```bash
systemctl restart redis-server
```

### 6.4 安装 MySQL 8

如果系统软件源已提供 `mysql-server` 8.x，可以直接安装；如果没有，使用 MySQL 官方 APT 源。

```bash
apt install -y mysql-server
systemctl enable mysql
systemctl start mysql
mysql --version
```

创建数据库和账号：

```sql
CREATE DATABASE hardware_erp_mvp DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'erp'@'127.0.0.1' IDENTIFIED BY 'your-strong-mysql-password';
GRANT ALL PRIVILEGES ON hardware_erp_mvp.* TO 'erp'@'127.0.0.1';
FLUSH PRIVILEGES;
```

### 6.5 安装 Go

生产环境如果只运行已编译好的二进制，可以不在服务器安装 Go。

如果需要在服务器本机编译：

```bash
cd /usr/local
wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -xzf go1.24.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >/etc/profile.d/go.sh
source /etc/profile.d/go.sh
go version
```

### 6.6 安装 Node.js

生产环境如果只上传前端 `dist` 目录，可以不在服务器安装 Node.js。

如果需要在服务器构建前端，建议安装 Node.js 22 LTS：

```bash
curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
apt install -y nodejs
node -v
npm -v
```

## 7. CentOS 7.9 部署示例

CentOS 7.9 仅建议在存量环境中使用。由于该系统已结束生命周期，很多新依赖安装会明显比 Debian 更麻烦。

### 7.1 安装基础工具

```bash
yum install -y curl wget tar unzip vim git
```

### 7.2 安装 Nginx

如果系统已有内部 YUM 源，可直接安装；否则先配置可用源。

```bash
yum install -y epel-release
yum install -y nginx
systemctl enable nginx
systemctl start nginx
```

### 7.3 安装 Redis

```bash
yum install -y redis
systemctl enable redis
systemctl start redis
```

如需密码，修改 `/etc/redis.conf`：

```conf
requirepass your-strong-redis-password
bind 127.0.0.1
```

然后重启：

```bash
systemctl restart redis
```

### 7.4 安装 MySQL 8

CentOS 7 安装 MySQL 8 通常使用 MySQL 官方 YUM 仓库：

```bash
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-7.noarch.rpm
yum install -y mysql-community-server
systemctl enable mysqld
systemctl start mysqld
mysql --version
```

创建数据库和账号：

```sql
CREATE DATABASE hardware_erp_mvp DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'erp'@'127.0.0.1' IDENTIFIED BY 'your-strong-mysql-password';
GRANT ALL PRIVILEGES ON hardware_erp_mvp.* TO 'erp'@'127.0.0.1';
FLUSH PRIVILEGES;
```

### 7.5 安装 Go

```bash
cd /usr/local
wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -xzf go1.24.4.linux-amd64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >/etc/profile.d/go.sh
source /etc/profile.d/go.sh
go version
```

### 7.6 安装 Node.js

CentOS 7 安装新版本 Node.js 时，建议优先使用 NodeSource；如果现场策略不允许外部源，则改为离线包。

```bash
curl -fsSL https://rpm.nodesource.com/setup_22.x | bash -
yum install -y nodejs
node -v
npm -v
```

## 8. 部署当前系统

### 8.1 构建前端

在前端目录执行：

```bash
cd ele-admin-plus-ts-pro-erp
npm install
npm run build
```

构建产物默认在：

```text
ele-admin-plus-ts-pro-erp/dist
```

### 8.2 构建后端

在后端目录执行：

```bash
cd hardware-erp
go build -o hardware-erp ./cmd/api
```

Windows 本地交叉编译 Linux 版本也可以：

```powershell
$env:CGO_ENABLED="0"
$env:GOOS="linux"
$env:GOARCH="amd64"
go build -o .\bin\hardware-erp-linux-amd64 .\cmd\api
```

### 8.3 上传文件到服务器

建议将文件上传到：

```text
/data/hardware-erp/backend/
/data/hardware-erp/frontend/
```

需要上传的核心文件：

- 后端二进制
- `config.prod.yaml` 改名后的生产配置
- `license_public.key`
- 前端 `dist` 全量静态文件

### 8.4 修改生产配置

可参考 [configs/config.prod.yaml](f:/erp_gpt_20260507/hardware-erp/configs/config.prod.yaml) 生成服务器配置，例如：

```yaml
app:
  name: hardware-erp-api
  env: prod
  host: 127.0.0.1
  port: 8080
  debug: false

mysql:
  host: 127.0.0.1
  port: 3306
  database: hardware_erp_mvp
  username: erp
  password: your-strong-mysql-password

redis:
  enabled: true
  host: 127.0.0.1
  port: 6379
  password: your-strong-redis-password
  db: 0

jwt:
  secret: replace-with-32-bytes-or-longer-secret
  issuer: hardware-erp-api

storage:
  driver: local
  local_path: /data/hardware-erp/uploads
  public_url: ""

license:
  dir: /data/hardware-erp/license
  public_key_file: ./license_public.key

log:
  level: info
  path: /data/hardware-erp/logs/app.log

cors:
  allowed_origins: []
  allow_credentials: true
```

必须修改的配置项：

- `mysql.username`
- `mysql.password`
- `redis.password`
- `jwt.secret`
- `storage.local_path`
- `log.path`

说明：

- 同机部署建议 `app.host: 127.0.0.1`
- 只有容器化或跨主机访问时才建议 `0.0.0.0`
- 同域部署时 `cors.allowed_origins` 保持空数组即可

### 8.5 初始化数据库

新库初始化可以导入完整 SQL，或按迁移脚本顺序执行。

如果已有完整初始化文件，优先导入完整 SQL；如果是升级已有库，则按迁移顺序执行增量脚本。

核心原则：

- 先迁移数据库
- 再启动新版本 API

否则新版本接口可能访问到旧表结构，导致运行错误。

## 9. systemd 服务配置

可以使用如下服务文件 `/etc/systemd/system/hardware-erp-api.service`：

```ini
[Unit]
Description=Hardware ERP API
After=network-online.target mysqld.service redis.service
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=/data/hardware-erp/backend
ExecStart=/data/hardware-erp/backend/hardware-erp -config /data/hardware-erp/backend/config.yaml
Restart=always
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

启用服务：

```bash
systemctl daemon-reload
systemctl enable hardware-erp-api
systemctl start hardware-erp-api
systemctl status hardware-erp-api
```

查看日志：

```bash
journalctl -u hardware-erp-api -f
tail -f /data/hardware-erp/logs/app.log
```

## 10. Nginx 配置

推荐配置如下：

```nginx
server {
    listen 80;
    server_name erp.example.com;

    root /data/hardware-erp/frontend;
    index index.html;
    client_max_body_size 50m;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/v1/ {
        proxy_pass http://127.0.0.1:8080/api/v1/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header X-Request-ID $request_id;
    }
}
```

说明：

- `/` 对应前端单页应用，必须保留 `try_files ... /index.html`
- `/api/v1/` 对应后端接口前缀，要与前端 `VITE_API_URL` 一致
- `client_max_body_size 50m` 用于支持上传场景

校验配置并重启：

```bash
nginx -t
systemctl reload nginx
```

## 11. 验证步骤

### 11.1 检查后端进程

```bash
systemctl status hardware-erp-api
```

### 11.2 检查健康接口

```bash
curl http://127.0.0.1:8080/healthz
```

### 11.3 检查页面

浏览器访问：

```text
http://your-domain/
```

### 11.4 检查接口代理

浏览器开发者工具确认：

- 页面静态资源返回 `200`
- `/api/v1/...` 请求返回正常
- 没有跨域报错

## 12. 部署文档解释

如果要向实施、运维或客户解释这份文档，可以按下面逻辑讲：

- `Node.js` 只负责前端构建，不是线上常驻服务
- `Go` 后端是线上常驻服务主体，编译后以单二进制运行
- `Nginx` 负责对外访问入口、静态资源分发和 API 反向代理
- `MySQL 8` 保存业务主数据，是核心持久化存储
- `Redis` 负责缓存、会话黑名单、编号辅助、限流等非主存储职责
- Linux 是承载这些组件的最稳妥运行平台

换句话说，整套系统上线时真正长期运行的通常只有四类进程：

- `nginx`
- `hardware-erp`
- `mysqld`
- `redis`

`Node.js` 和 `Go` 编译工具链更多是发布阶段依赖，不一定必须常驻在线上业务机。

## 13. 推荐实施策略

如果你需要一个明确的落地建议，建议按下面执行：

1. 新服务器优先选 Debian
2. 本地或 CI 构建前端 `dist` 和后端 Linux 二进制
3. 服务器只安装 `Nginx + Redis + MySQL 8`
4. 非必要不在生产机安装 Node.js 和 Go
5. `Nginx` 与 Go API 同机部署，后端仅监听 `127.0.0.1`
6. 上传目录、日志目录放到 `/data/hardware-erp/` 之类的独立路径

这样做的好处是：

- 线上环境更干净
- 故障点更少
- 升级更简单
- 安全面更小
