
# install ssmtp
apt install ssmtp

# change mailhub
sed -i 's/mailhub=mail/#mailhub=mail/' /etc/ssmtp/ssmtp.conf

# Configure ssmtp settings
echo "mailhub=smtp.customer_domain.com:587
useSTARTTLS=YES
AuthUser=test_email_account
AuthPass=test_password
TLS_CA_File=/etc/pki/tls/certs/ca-bundle.crt" >> /etc/ssmtp/ssmtp.conf

# Configure revaliases
# This configures the From account
echo "root:user@domain.com:smtp.server.com" >> /etc/ssmtp/revaliases

# Test line
echo "Test message from Linux server using ssmtp" | sudo ssmtp -vvv user@domain.com
