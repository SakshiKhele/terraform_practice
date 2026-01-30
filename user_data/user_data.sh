#!/bin/bash
apt update -y
apt install -y nginx
systemctl start nginx
systemctl enable nginx

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>Terraform Website</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      background-color: #f4f6f8;
      text-align: center;
      padding-top: 100px;
    }
    h1 {
      color: #2c3e50;
    }
    p {
      font-size: 18px;
      color: #555;
    }
    footer {
      margin-top: 40px;
      font-size: 14px;
      color: #777;
    }
  </style>
</head>
<body>
  <h1>Welcome to My Terraform Website</h1>
  <p>This page is deployed automatically using Terraform.</p>
  <p>Nginx web server is running successfully 🚀</p>

  <footer>
    <p>Created by Pratiksha | Terraform Practice</p>
  </footer>
</body>
</html>
EOF
