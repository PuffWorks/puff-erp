# Deployment Notes

- Reverse proxy: Nginx
- App process: single Go API service
- Upload files: store outside the frontend web root and download through authenticated backend APIs only

Recommended flow:

1. Build binary with `scripts/build.ps1`
2. Apply MySQL migrations
3. Start Redis
4. Run API service behind Nginx

Migration order:

- Apply migrations before starting a newer API binary. The CRM customer operation
  upgrade adds columns to `customers`; running the API before migration can make
  customer queries fail on older databases.

Address configuration:

- `app.host: 127.0.0.1` is recommended when Nginx and the API run on the same host.
- `app.host: 0.0.0.0` is needed when the API runs in Docker and the container port is published.
- Keep `cors.allowed_origins` empty for same-origin Nginx deployment. Add the exact frontend origins only when the browser calls the API cross-origin.

Example Nginx layout:

```nginx
server {
    listen 80;
    server_name erp.example.com;
    root /data/www/hardware-erp-web;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080/api/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Request-ID $request_id;
    }

    client_max_body_size 50m;
}
```
