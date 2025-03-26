# Automated HTTPS Setup for Mortgage Calculator Microservice

This project includes automated HTTPS setup for the mortgage calculator microservice, allowing it to be securely accessed over SSL/TLS.

## How HTTPS is Implemented

The HTTPS implementation uses:
- Nginx as a reverse proxy to handle SSL/TLS termination
- Let's Encrypt for free, trusted SSL certificates
- Automatic certificate renewal via cron

## Configuration Files

- `nginx.conf`: Nginx configuration that sets up HTTP to HTTPS redirection and SSL parameters
- `docker-compose.prod.yml`: Includes Nginx container with proper volume mounts for SSL certificates
- `deploy.sh`: Automated script that handles Let's Encrypt certificate acquisition and renewal setup
- `Jenkinsfile`: CI/CD pipeline that passes required environment variables

## Automated Deployment Process

When you push to the repository, the Jenkins pipeline automatically:

1. Builds and tests the application
2. Builds and pushes Docker images
3. Deploys to the Linode server with HTTPS configuration
4. Verifies the deployment is working

The `deploy.sh` script on the server automatically:

1. Installs Certbot if needed
2. Obtains Let's Encrypt certificates for your domain
3. Sets up automatic certificate renewal
4. Configures Nginx with the certificates
5. Starts all services with HTTPS enabled

## Environment Variables

The following environment variables control the HTTPS setup:

- `DOMAIN`: The domain name for the SSL certificate (default: 139-162-198-94.ip.linodeusercontent.com)
- `EMAIL`: Email address for Let's Encrypt notifications
- `USE_LETSENCRYPT`: Set to 'true' to use Let's Encrypt, 'false' for self-signed certificates

## URLs

After deployment, the service will be available at:

- HTTPS: `https://139-162-198-94.ip.linodeusercontent.com/calculate_mortgage_affordability`
- HTTP: `http://139-162-198-94.ip.linodeusercontent.com/calculate_mortgage_affordability` (redirects to HTTPS)

## Manual Testing

You can test the HTTPS endpoint using:

```bash
curl -X POST https://139-162-198-94.ip.linodeusercontent.com/calculate_mortgage_affordability \
-H "Content-Type: application/json" \
-d '{
  "annualIncome": 60000,
  "monthlyExpenses": 1800,
  "depositAmount": 25000,
  "mortgageTermYears": 20
}'
```

## Troubleshooting

If HTTPS is not working:

1. SSH into the Linode server
2. Check Nginx logs: `docker-compose -f /root/mortgage-calculator/docker-compose.prod.yml logs nginx`
3. Verify certificates exist: `ls -la /root/mortgage-calculator/ssl/`
4. Check if certificates were successfully obtained: `certbot certificates`
5. Manually restart the deployment: `cd /root/mortgage-calculator && ./deploy.sh`

## Security Considerations

This setup provides:
- TLS 1.2 and 1.3 support (older protocols disabled)
- Strong cipher suite configuration
- HTTP to HTTPS redirection
- Automatic certificate renewal

For production environments, consider adding:
- HTTP Strict Transport Security (HSTS)
- Content Security Policy (CSP)
- Server-side request forgery (SSRF) protection
- Additional firewall rules 