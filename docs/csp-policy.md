# Content Security Policy (CSP) for VibeScale

This document contains the Content Security Policy configuration for the VibeScale web application.

## Recommended CSP Header

For production deployment, use the following Content Security Policy header:

```
Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data:; style-src 'self' 'unsafe-inline' data:; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' blob: data: ws: wss: https:; worker-src 'self' blob:; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;
```

## CSP Meta Tag (Alternative)

If you cannot set HTTP headers, you can add the CSP as a meta tag in `web/index.html`:

```html
<meta http-equiv="Content-Security-Policy" content="default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data:; style-src 'self' 'unsafe-inline' data:; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' blob: data: ws: wss: https:; worker-src 'self' blob:; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;">
```

## Policy Breakdown

- **default-src 'self'**: Only allow resources from the same origin by default
- **script-src**: Allow scripts from same origin, inline scripts (required by Flutter), eval (required by Flutter), blob and data URIs
- **style-src**: Allow styles from same origin and inline styles
- **img-src**: Allow images from same origin, data URIs, and blob URIs
- **font-src**: Allow fonts from same origin and data URIs
- **connect-src**: Allow connections to same origin, blob/data URIs, WebSocket connections, and HTTPS URLs
- **worker-src**: Allow web workers from same origin and blob URIs
- **frame-src**: Allow frames from same origin only
- **object-src 'none'**: Block all plugins (improves security)
- **base-uri 'self'**: Restrict base tag to same origin
- **form-action 'self'**: Restrict form submissions to same origin
- **upgrade-insecure-requests**: Upgrade HTTP requests to HTTPS

## Platform-Specific Configurations

### Netlify

Create a `public/_headers` file (if deploying to `public` directory):

```
/*
  Content-Security-Policy: default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data:; style-src 'self' 'unsafe-inline' data:; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' blob: data: ws: wss: https:; worker-src 'self' blob:; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;
```

### GitHub Pages

GitHub Pages doesn't support custom headers. Use the meta tag approach in `index.html` instead.

### Vercel

Create a `vercel.json` file:

```json
{
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        {
          "key": "Content-Security-Policy",
          "value": "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data:; style-src 'self' 'unsafe-inline' data:; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' blob: data: ws: wss: https:; worker-src 'self' blob:; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;"
        }
      ]
    }
  ]
}
```

### Apache (.htaccess)

Add to `.htaccess` in your web root:

```apache
<IfModule mod_headers.c>
  Header set Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data:; style-src 'self' 'unsafe-inline' data:; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' blob: data: ws: wss: https:; worker-src 'self' blob:; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;"
</IfModule>
```

### Nginx

Add to your nginx configuration:

```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' blob: data:; style-src 'self' 'unsafe-inline' data:; img-src 'self' data: blob:; font-src 'self' data:; connect-src 'self' blob: data: ws: wss: https:; worker-src 'self' blob:; frame-src 'self'; object-src 'none'; base-uri 'self'; form-action 'self'; upgrade-insecure-requests;" always;
```

## Testing

After implementing the CSP, test your application thoroughly to ensure all features work correctly. Check the browser console for any CSP violation errors.

## Notes

- The `'unsafe-inline'` and `'unsafe-eval'` directives are required for Flutter web applications to function properly
- If you need to integrate external services (analytics, payment processors, etc.), you'll need to add their domains to the appropriate directives
- For production, consider using a CSP reporting endpoint to monitor violations

