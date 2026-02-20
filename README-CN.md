# cf-workers-doh

## **一个具有 "自动 ECS" 功能的 DNS-over-HTTPS 代理**

在 Cloudflare Workers 上部署具有"自动 ECS"（EDNS 客户端子网）功能的 DoH（DNS-over-HTTPS）代理。

- **`ECS:`** 带有 ECS 的 DNS DoH 请求会 根据 ECS 中指定的子网 生成 DNS 响应，为域名查找提供准确的、最接近该子网地理位置的解析结果。更多关于ECS，请参阅 [https://developers.google.com/speed/public-dns/docs/ecs?hl=zh-cn](https://developers.google.com/speed/public-dns/docs/ecs?hl=zh-cn)。

  > ECS 对于 DNS 代理 特别有用，因为通常 DNS 代理 会生成一个地理位置接近 _**DNS 代理 IP**_ 的 DNS 响应，而不是接近 实际发送 DNS 查询请求（到DNS代理）的 _**实际客户端的 IP**_。

- **`自动 ECS:`** 将 DoH 请求代理发送到上游 DoH 服务时，自动将*终端用户的 IP* 附加到 ECS

**通过"自动 ECS"功能，DNS 代理将能够生成地理位置接近 _实际客户端 IP_ 的 DNS 响应。**

**警告：** 设计为完全支持 [Google 公共 DNS](https://developers.google.com/speed/public-dns/docs/secure-transports?hl=zh-cn) 作为上游服务。使用其他 DNS 服务作为上游时，结果可能会变化。

## 功能：

- 将 DoH 请求发送到上游 DoH 服务时，自动附加 EDNS 客户端子网（ECS）信息。使用实际终端用户客户端的 IP（即向 DNS 代理发送 DoH 请求的客户端 IP）作为子网的基础。
  - 子网掩码：IPv4 /24 IPv6 /56，最后几位数会被置为零。
  - 如果代理的 DoH 请求已包含 ECS 字段，则不会添加或更改 ECS 字段。
  - 请注意，并非所有公共 DNS 服务都支持 ECS。Google DoH 支持 ECS，因此为默认设置。请查看 [公共 DNS 服务](https://github.com/curl/curl/wiki/DNS-over-HTTPS) 以了解其他公共 DNS 服务。
- 支持的 DoH 方法：
  - [GET /dns-query](https://developers.google.com/speed/public-dns/docs/doh?hl=zh-cn#methods)
  - [POST /dns-query](https://developers.google.com/speed/public-dns/docs/doh?hl=zh-cn#methods)
  - [GET /resolve (Google JSON API)](https://developers.google.com/speed/public-dns/docs/doh/json?hl=zh-cn)

## 安装

- 一键部署到 Cloudflare Workers：

[![Deploy to Cloudflare](https://deploy.workers.cloudflare.com/button)](https://deploy.workers.cloudflare.com/?url=https://github.com/Grinch27/cf-workers-doh-ecs)

- 或使用 Wrangler 命令行部署：
  1. `npm i -g wrangler`
  2. `wrangler login`
  3. 修改 `wrangler.toml` 中的变量
  4. `wrangler deploy`

- 变量化配置（无需改代码）：

| 变量名                 | 默认值                         | 说明                                          |
| ---------------------- | ------------------------------ | --------------------------------------------- |
| `UPSTREAM_DNS_QUERY`   | `https://dns.google/dns-query` | 查询请求使用的上游 DoH 二进制接口             |
| `UPSTREAM_RESOLVE`     | `https://dns.google/resolve`   | resolve 请求使用的上游 JSON 接口              |
| `REQ_QUERY_PATHNAME`   | `/dns-query`                   | 对外 query 路径（可改为 `/masked-dns-query`） |
| `REQ_RESOLVE_PATHNAME` | `/resolve`                     | 对外 resolve 路径（可改为 `/masked-resolve`） |

- 同时兼容旧变量名：`URL_UPSTREAM_DNS_QUERY`、`URL_UPSTREAM_RESOLVE`。
- 对于中国大陆用户：
  - 你可能需要一个自定义域名来绕过 GFW。Cloudflare Workers 的默认域名在你所在的地区可能会被封锁。
  - **高度建议：** 修改 DNS 请求路径以降低嗅探封锁风险，例如设置 `REQ_QUERY_PATHNAME=/masked-dns-query` 与 `REQ_RESOLVE_PATHNAME=/masked-resolve`。

## 限制：

- 由于 DNS 代理部署在 Cloudflare Workers 上（以及可能其他无服务器服务），它只能通过域名访问。在这种部署方式下，无法通过 "https://ip" 访问 DNS 代理。

## 致谢

- **代码基础**：
  - [https://github.com/tina-hello/doh-cf-workers](https://github.com/tina-hello/doh-cf-workers)
  - [https://github.com/GangZhuo/cf-doh](https://github.com/GangZhuo/cf-doh)
