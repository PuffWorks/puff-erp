

`puff-erp` 是一套面向服务器、硬件设备、IT 代理商和项目型销售企业的前后端分离 ERP 系统，覆盖 CRM 客户管理、报价、销售、采购、库存、SN 序列号、财务收付款、合同、售后、报表看板、权限控制、系统授权等核心业务流程。

系统以“货、钱、单”三条主线为设计核心：

* 货：库存、入库、出库、盘点、SN 生命周期、库存流水全程可追溯
* 钱：应收、应付、收款、付款、核销、反冲与业务单据联动
* 单：报价、销售订单、采购订单、入库单、出库单、合同、售后工单形成完整证据链

`puff-erp` 不是简单的进销存系统，而是一套可用于中小型硬件代理商日常经营管理的业务 ERP。

---

## 技术栈

### 后端

* Go
* Gin
* GORM
* MySQL
* Redis
* JWT
* RBAC 权限控制

### 前端

* Vue 3
* Vite
* TypeScript
* Element Plus
* EleAdmin Plus

### 部署

* Nginx
* MySQL
* Redis
* 构建脚本
* 数据库迁移脚本
* 系统授权文件
* 前后端分离部署

---

## 核心功能

### 系统管理

* 登录、退出、验证码
* 用户管理
* 角色管理
* 菜单管理
* 组织机构
* 数据字典
* 编号规则
* 系统配置
* 登录日志
* 操作日志
* 文件管理
* 用户代登录
* 只读代登录
* 系统授权
* 模块授权
* 数据范围控制

---

### CRM 中心

* CRM 看板
* 数据公海
* 我的客户
* 联系人管理
* 跟进记录
* 商机管理
* 销售任务
* 线索管理
* 客户分配、领取、转移、退回公海
* 客户标签
* 商机转报价
* 客户 360 视图

---

### 基础资料

* 客户管理
* 供应商管理
* 仓库管理
* 项目管理
* 商品分类
* 品牌分类
* 品牌管理
* 商品管理
* SKU 管理
* 商品、品牌、SKU 联动
* 启用、禁用、删除、导入、导出

---

### 销售管理

* 报价单
* 报价审批
* 报价确认
* 报价复制
* 报价转销售订单
* 销售订单
* 销售订单审批
* 销售订单确认
* 销售订单库存检查
* 缺货生成采购
* 销售出库
* 销售打印
* 销售导出

---

### 采购管理

* 采购订单
* 采购审批
* 采购确认
* 缺货采购链路
* 采购入库
* 采购打印
* 采购导出
* 与销售订单缺货采购流程联动

---

### 库存管理

* 库存现存量
* 库存流水
* 入库单
* 出库单
* 库存盘点
* 盘点录入
* 盘点审核
* 盘点调整
* 盘点导入
* 盘点导出
* SN 序列号管理
* SN 生命周期
* 入库建档
* 出库校验
* 状态校验
* 数量匹配校验

---

### 财务管理

* 应收管理
* 应付管理
* 收款单
* 付款单
* 核销记录
* 收款取消
* 付款取消
* 核销反冲
* 与销售订单、采购订单金额状态联动

---

### 合同管理

* 合同模板
* 合同列表
* 合同创建
* 合同修改
* 合同签署
* 合同完成
* 合同取消
* 合同文件上传
* 合同文件下载
* 合同文件删除
* 支持关联客户、供应商、报价单、销售订单、采购订单、项目

---

### 售后管理

* 售后工单
* 工单创建
* 工单修改
* 工单处理
* 工单关闭
* 工单取消
* 质保查询
* 关联客户、销售订单、商品、SKU、SN

---

### 报表与看板

* 工作台
* 待办事项
* 预警提醒
* 近期订单
* 近期日志
* 销售报表
* 采购报表
* 库存报表
* 财务报表
* 售后报表
* CRM 看板

---

### 导入导出与附件

* 通用导入模板
* 导入预览
* 导入确认
* 导入任务列表
* 导入错误明细
* 通用业务附件上传
* 附件列表
* 附件下载
* 附件删除
* 多业务模块导出

---

### 消息中心

* 消息列表
* 未读数量
* 待办事项
* 标记已读
* 全部已读
* 完成待办
* 删除消息

---

## 项目特点

### 1. 面向硬件代理商业务场景

系统适用于服务器、网络设备、存储设备、配件、项目型销售等业务场景，支持报价、销售、缺货采购、入库、出库、收付款、售后等完整流程。

### 2. 以单据驱动业务

库存变化、财务金额变化、SN 生命周期变化均由业务单据驱动，避免直接修改库存或金额导致数据失真。

### 3. 支持 SN 序列号管理

适合硬件设备行业对设备序列号、质保、售后、出入库生命周期的追踪要求。

### 4. 支持系统授权

内置机器码离线授权机制，可控制授权客户、产品版本、授权模块、授权功能、最大用户数、机构数、仓库数和有效期。

### 5. 权限体系完整

支持 JWT 登录、RBAC 权限、菜单权限、按钮权限、数据范围、模块授权、字段可见性控制。

### 6. 支持客户经营

内置 CRM 中心，支持线索、数据公海、我的客户、联系人、跟进记录、商机、销售任务和 CRM 看板，帮助企业从“订单管理”升级到“客户经营”。

---

## 适用场景

* 服务器代理商
* IT 硬件销售公司
* 网络设备代理商
* 系统集成商
* 项目型销售企业
* 中小型进销存升级 ERP 场景
* 需要私有化部署的企业管理系统

---

## 系统主流程

```text
CRM 线索
  ↓
客户 / 数据公海 / 我的客户
  ↓
联系人 / 跟进记录 / 商机
  ↓
报价单
  ↓
销售订单
  ↓
库存检查
  ↓
库存充足 → 销售出库
  ↓
库存不足 → 缺货采购 → 采购入库 → 销售出库
  ↓
应收 / 收款 / 核销
  ↓
合同 / 售后 / 报表
```

采购链路：

```text
销售缺货 / 手工采购
  ↓
采购订单
  ↓
采购审批
  ↓
采购确认
  ↓
采购入库
  ↓
库存增加
  ↓
应付 / 付款 / 核销
```

库存链路：

```text
采购入库
  ↓
库存现存量
  ↓
销售出库
  ↓
库存流水
  ↓
盘点 / 调整 / SN 生命周期
```

---

## 项目定位

`puff-erp` 的目标是为中小型硬件代理商提供一套可私有化部署、可扩展、可持续演进的 ERP 系统。

系统重点解决：

* 客户数据分散
* 报价和订单脱节
* 销售缺货无法快速生成采购
* 库存数量和实际不一致
* SN 序列号无法追踪
* 财务收付款与业务单据脱节
* 合同和售后缺少统一管理
* 报表无法反映真实经营状态
* 权限、授权、日志、附件不规范

---

## 当前状态

项目仍在持续开发和完善中，后续计划增强：

* 售后管理增强
* 备件申请与售后出库
* 返厂维修
* 客户回访
* 价格体系
* 客户信用控制
* 采购询价比价
* 供应商评级
* 项目交付
* 发票与对账
* 经营驾驶舱增强
* 数据一致性检查中心

---

## License

本项目授权方式以项目实际协议为准。

如用于商业化、私有化交付或二次开发，请根据实际授权规则使用。

如需正式使用请关注
公众号：爱折腾的程序员Puff
<img width="565" height="559" alt="image" src="https://github.com/user-attachments/assets/150efd1c-23ae-47e8-bff6-0ecb78294481" />


# 补充部署与运维指南

---

# 环境变量覆盖配置（ENV > YAML）

系统支持通过环境变量覆盖配置文件中的参数。

优先级：

```text
环境变量（ENV）
    ↓
config.yaml
    ↓
系统默认值
```

例如：

```yaml
mysql:
  host: 127.0.0.1
  port: 3306
```

可通过环境变量覆盖：

```bash
export MYSQL_HOST=10.0.0.10
export MYSQL_PORT=3306
```

启动后实际生效：

```yaml
mysql:
  host: 10.0.0.10
  port: 3306
```

推荐支持的环境变量：

| 环境变量           | 对应配置           |
| -------------- | -------------- |
| APP_ENV        | app.env        |
| APP_PORT       | app.port       |
| MYSQL_HOST     | mysql.host     |
| MYSQL_PORT     | mysql.port     |
| MYSQL_DATABASE | mysql.database |
| MYSQL_USERNAME | mysql.username |
| MYSQL_PASSWORD | mysql.password |
| REDIS_HOST     | redis.host     |
| REDIS_PORT     | redis.port     |
| REDIS_PASSWORD | redis.password |
| JWT_SECRET     | jwt.secret     |
| LOG_LEVEL      | log.level      |

Docker 场景：

```bash
docker run \
-e MYSQL_HOST=mysql \
-e MYSQL_PASSWORD=123456 \
-e JWT_SECRET=xxxxxxxx \
hardware-erp-api
```

---

# 数据库迁移（Migration）

系统采用自动版本化迁移管理数据库结构。

目录结构：

```text
database/
└── migrations/
    ├── 001_create_users.sql
    ├── 002_create_roles.sql
    ├── 003_create_products.sql
    └── ...
```

---

## 执行迁移

```bash
./hardware-erp-api migrate up
```

执行结果：

```text
Migration 001_create_users success
Migration 002_create_roles success
Migration 003_create_products success
```

---

## 回滚迁移

回滚最近一次：

```bash
./hardware-erp-api migrate down
```

回滚指定版本：

```bash
./hardware-erp-api migrate down --version=3
```

---

## 查看迁移状态

```bash
./hardware-erp-api migrate status
```

示例：

```text
Version    Status
001        Applied
002        Applied
003        Applied
004        Pending
```

---

# 初始化超级管理员账号

首次部署后需要初始化系统管理员。

执行：

```bash
./hardware-erp-api init-admin
```

默认创建：

```text
用户名：admin
密码：admin123456
角色：SuperAdmin
```

首次登录后必须修改密码。

---

## 自定义管理员

```bash
./hardware-erp-api init-admin \
--username=admin \
--password=StrongPassword@123
```

成功提示：

```text
Super administrator created successfully.
```

---

## 重置管理员密码

```bash
./hardware-erp-api reset-admin-password \
--username=admin \
--password=NewPassword@123
```

---

# 单商户模式说明

当前系统采用：

```text
Single Merchant Architecture
（单商户架构）
```

系统服务于单一企业，不支持 SaaS 多租户。

---

## 架构特点

```text
一个数据库
一个商户
多个用户
多个角色
```

关系：

```text
Company
 ├── Users
 ├── Roles
 ├── Warehouses
 ├── Products
 ├── Purchases
 ├── Sales
 └── Finance
```

---

## 数据表设计

无需：

```sql
tenant_id
merchant_id
shop_id
```

例如：

```sql
CREATE TABLE products (
    id BIGINT PRIMARY KEY,
    sku VARCHAR(50),
    name VARCHAR(200),
    stock_quantity DECIMAL(18,2)
);
```

而不是：

```sql
CREATE TABLE products (
    id BIGINT PRIMARY KEY,
    tenant_id BIGINT,
    sku VARCHAR(50),
    name VARCHAR(200)
);
```

---

## 系统初始化

首次安装创建：

```text
Company
 └── Default Company
```

配置表：

```text
system_settings
company_profile
```

保存企业信息：

* 企业名称
* 联系方式
* Logo
* 地址
* 税号
* 默认货币

---

## 后续升级

如未来升级为：

```text
Multi Merchant
Multi Tenant SaaS
```

建议新增：

```sql
tenant_id
merchant_id
```

并逐步改造权限模型。

---

# Nginx 反向代理配置

配置文件：

```text
/etc/nginx/conf.d/hardware-erp.conf
```

示例：

```nginx
server {
    listen 80;
    server_name erp.example.com;

    client_max_body_size 100m;

    location / {
        proxy_pass http://127.0.0.1:8080;

        proxy_http_version 1.1;

        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;

        proxy_set_header X-Forwarded-For
        $proxy_add_x_forwarded_for;

        proxy_set_header X-Forwarded-Proto
        $scheme;
    }
}
```

---

## HTTPS 配置

```nginx
server {
    listen 443 ssl http2;
    server_name erp.example.com;

    ssl_certificate
    /etc/letsencrypt/live/erp/fullchain.pem;

    ssl_certificate_key
    /etc/letsencrypt/live/erp/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
    }
}
```

测试：

```bash
nginx -t
```

重载：

```bash
systemctl reload nginx
```

---

# Systemd 服务部署（生产环境）

创建服务文件：

```bash
/etc/systemd/system/hardware-erp.service
```

内容：

```ini
[Unit]
Description=Hardware ERP API
After=network.target mysql.service redis.service

[Service]
Type=simple

User=erp
Group=erp

WorkingDirectory=/opt/hardware-erp

ExecStart=/opt/hardware-erp/hardware-erp-api \
--config=/opt/hardware-erp/configs/config.yaml

Restart=always
RestartSec=5

LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
```

---

## 重新加载

```bash
systemctl daemon-reload
```

---

## 启动服务

```bash
systemctl start hardware-erp
```

---

## 开机启动

```bash
systemctl enable hardware-erp
```

---

## 查看状态

```bash
systemctl status hardware-erp
```

---

## 查看日志

```bash
journalctl -u hardware-erp -f
```

---

# 生产环境部署检查清单

部署前确认：

```text
[✓] MySQL正常运行
[✓] Redis正常运行
[✓] 数据库迁移完成
[✓] 超级管理员已创建
[✓] JWT Secret已修改
[✓] Redis密码已修改
[✓] MySQL密码已修改
[✓] 上传目录已创建
[✓] 日志目录已创建
[✓] Nginx配置完成
[✓] HTTPS证书已配置
[✓] Systemd服务已启用
[✓] 健康检查通过
```

健康检查：

```http
GET /health
```

返回：

```json
{
  "code": 0,
  "message": "ok"
}
```

表示系统已可投入生产运行。
