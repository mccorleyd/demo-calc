# Setting Up SSL/HTTPS for the Mortgage Calculator

This guide explains how to set up SSL certificates for secure HTTPS communication.

## Option 1: Using Let's Encrypt (Recommended for Production)

Let's Encrypt provides free SSL certificates that are trusted by browsers. This is the recommended approach for production environments.

### Prerequisites

1. A domain name pointing to your Linode server (e.g., `mortgage.yourdomain.com`)
2. SSH access to your Linode server

### Steps to Set Up Let's Encrypt

1. SSH into your Linode server:
   ```bash
   ssh root@139.162.198.94
   ```

2. Install Certbot (Let's Encrypt client):
   ```bash
   apt-get update
   apt-get install -y certbot
   ```

3. Stop the Nginx service if it's running:
   ```bash
   cd /root/mortgage-calculator
   docker-compose -f docker-compose.prod.yml down
   ```

4. Obtain SSL certificate (replace `mortgage.yourdomain.com` with your actual domain):
   ```bash
   certbot certonly --standalone --agree-tos --email your-email@example.com -d mortgage.yourdomain.com
   ```

5. Copy the certificates to the appropriate location:
   ```bash
   mkdir -p /root/mortgage-calculator/ssl
   cp /etc/letsencrypt/live/mortgage.yourdomain.com/fullchain.pem /root/mortgage-calculator/ssl/
   cp /etc/letsencrypt/live/mortgage.yourdomain.com/privkey.pem /root/mortgage-calculator/ssl/
   chmod 644 /root/mortgage-calculator/ssl/fullchain.pem
   chmod 600 /root/mortgage-calculator/ssl/privkey.pem
   ```

6. Update the Nginx configuration:
   ```bash
   # Edit the nginx.conf file
   nano /root/mortgage-calculator/nginx.conf
   ```
   
   Change the `server_name` to your actual domain.

7. Restart the services:
   ```bash
   cd /root/mortgage-calculator
   docker-compose -f docker-compose.prod.yml up -d
   ```

### Automatic Certificate Renewal

Let's Encrypt certificates expire after 90 days. Set up automatic renewal with a cron job:

1. Create a renewal script:
   ```bash
   cat > /root/renew-cert.sh << 'EOF'
   #!/bin/bash
   certbot renew --quiet
   
   # Only copy if renewal was successful
   if [ -d "/etc/letsencrypt/live/mortgage.yourdomain.com" ]; then
     cp /etc/letsencrypt/live/mortgage.yourdomain.com/fullchain.pem /root/mortgage-calculator/ssl/
     cp /etc/letsencrypt/live/mortgage.yourdomain.com/privkey.pem /root/mortgage-calculator/ssl/
     chmod 644 /root/mortgage-calculator/ssl/fullchain.pem
     chmod 600 /root/mortgage-calculator/ssl/privkey.pem
     cd /root/mortgage-calculator && docker-compose -f docker-compose.prod.yml restart nginx
   fi
   EOF
   
   chmod +x /root/renew-cert.sh
   ```

2. Add a cron job to run the script twice a day:
   ```bash
   (crontab -l 2>/dev/null; echo "0 0,12 * * * /root/renew-cert.sh") | crontab -
   ```

## Option 2: Self-Signed Certificates (Development Only)

The deployment script automatically generates self-signed certificates if no certificates exist. These are suitable for development but will trigger browser warnings in production.

If you're using self-signed certificates, you'll need to add a security exception in your browser or use the `-k` flag with curl commands to bypass SSL verification:

```bash
curl -k -X POST https://139.162.198.94/calculate_mortgage_affordability \
-H "Content-Type: application/json" \
-d '{
  "annualIncome": 60000,
  "monthlyExpenses": 1800,
  "depositAmount": 25000,
  "mortgageTermYears": 20
}'
```

## Verifying HTTPS Setup

After setup, verify your HTTPS configuration:

```bash
# Check if Nginx is running
docker ps | grep nginx

# Test HTTPS endpoint
curl -k https://139.162.198.94/calculate_mortgage_affordability \
-H "Content-Type: application/json" \
-d '{
  "annualIncome": 60000,
  "monthlyExpenses": 1800,
  "depositAmount": 25000,
  "mortgageTermYears": 20
}'
```

For additional security:
- Configure HTTP Strict Transport Security (HSTS)
- Set up a firewall to restrict access to port 22 (SSH)
- Consider using a Web Application Firewall (WAF) 