#!/bin/bash
set -e

RDS_HOST="${rds_endpoint}"
DB_USER="${db_user}"
DB_PASS="${db_pass}"
DB_NAME="formdb"

# Update packages
apt update -y

# Install Apache PHP, MySQL client
sudo apt update
sudo apt install -y apache2

# Enable Apache
systemctl enable apache2
systemctl start apache2

#Install MySQL
sudo apt install -y mysql-server

#install PHP
sudo apt install -y php
sudo apt install -y libapache2-mod-php

#give the permission to files
sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

cd /var/www/html

############################################
# CREATE BAT FORM
############################################

cat <<EOF > index.php
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>BAT Registration</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
* {
  box-sizing: border-box;
  font-family: 'Segoe UI', Tahoma, sans-serif;
}

body {
  margin: 0;
  min-height: 100vh;
  background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
  display: flex;
  align-items: center;
  justify-content: center;
}

.container {
  width: 100%;
  max-width: 460px;
  padding: 20px;
}

.card {
  background: #ffffff;
  border-radius: 18px;
  padding: 40px 35px;
  box-shadow: 0 25px 50px rgba(0,0,0,0.35);
}

.logo {
  text-align: center;
  font-size: 26px;
  font-weight: bold;
  color: #2c5364;
  margin-bottom: 8px;
}

.subtitle {
  text-align: center;
  font-size: 14px;
  color: #666;
  margin-bottom: 30px;
}

.field {
  margin-bottom: 20px;
}

.field label {
  display: block;
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 6px;
  color: #333;
}

.field input {
  width: 100%;
  padding: 13px;
  border-radius: 10px;
  border: 1px solid #ccc;
  font-size: 14px;
  transition: 0.3s;
}

.field input:focus {
  outline: none;
  border-color: #2c5364;
  box-shadow: 0 0 0 3px rgba(44,83,100,0.2);
}

button {
  width: 100%;
  padding: 15px;
  margin-top: 10px;
  border: none;
  border-radius: 12px;
  font-size: 16px;
  font-weight: bold;
  color: #fff;
  background: linear-gradient(135deg, #203a43, #2c5364);
  cursor: pointer;
  transition: 0.3s;
}

button:hover {
  transform: translateY(-2px);
  box-shadow: 0 12px 30px rgba(0,0,0,0.3);
}

.footer {
  text-align: center;
  font-size: 12px;
  color: #888;
  margin-top: 20px;
}
</style>
</head>

<body>

<div class="container">
  <div class="card">
    <div class="logo">BAT</div>
    <div class="subtitle">Employee Registration Portal</div>

    <form action="submit.php" method="post">
      <div class="field">
        <label>Full Name</label>
        <input type="text" name="name" required>
      </div>

      <div class="field">
        <label>Email Address</label>
        <input type="email" name="email" required>
      </div>

      <div class="field">
        <label>Phone Number</label>
        <input type="text"
               name="phone"
               pattern="[0-9]+"
               title="Digits only"
               required>
      </div>

      <button type="submit">Register</button>
    </form>

    <div class="footer">
      © BAT • Secure Registration
    </div>
  </div>
</div>

</body>
</html>
EOF

############################################
# THANK YOU PAGE
############################################

cat <<EOF > thankyou.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Thank You - BAT</title>
<meta name="viewport" content="width=device-width, initial-scale=1.0">

<style>
body {
  margin: 0;
  height: 100vh;
  font-family: 'Segoe UI', Tahoma, sans-serif;
  background: linear-gradient(135deg, #2c5364, #203a43);
  display: flex;
  align-items: center;
  justify-content: center;
}

.box {
  background: #ffffff;
  padding: 50px 40px;
  border-radius: 18px;
  text-align: center;
  box-shadow: 0 25px 50px rgba(0,0,0,0.35);
  max-width: 420px;
}

.box h1 {
  color: #2c5364;
  margin-bottom: 10px;
}

.box p {
  color: #555;
  font-size: 15px;
  margin-bottom: 25px;
}

.box a {
  text-decoration: none;
  padding: 12px 22px;
  border-radius: 10px;
  font-weight: bold;
  color: white;
  background: linear-gradient(135deg, #203a43, #2c5364);
  transition: 0.3s;
}

.box a:hover {
  box-shadow: 0 10px 25px rgba(0,0,0,0.3);
}
</style>
</head>

<body>

<div class="box">
  <h1>Thank You!</h1>
  <p>Your registration with <strong>BAT</strong> has been successfully completed.</p>
  <a href="index.php">Back to Registration</a>
</div>

</body>
</html>

EOF

############################################
# submit.php
############################################

cat <<EOF > submit.php
<?php
\$servername = "$RDS_HOST";
\$username   = "$DB_USER";
\$password   = "$DB_PASS";
\$dbname     = "$DB_NAME";

\$conn = new mysqli(\$servername, \$username, \$password, \$dbname);

if (\$conn->connect_error) {
    echo "Failed";
    exit();
}

\$name  = \$_POST['name'] ?? '';
\$email = \$_POST['email'] ?? '';
\$phone = \$_POST['phone'] ?? '';

if (empty(\$name) || empty(\$email) || empty(\$phone) ||
    !preg_match('/^[0-9]+$/', \$phone)) {
    echo "Failed";
    exit();
}

\$sql = "INSERT INTO users (name, email, phone)
        VALUES ('\$name', '\$email', '\$phone')";

if (\$conn->query(\$sql) === TRUE) {
    header("Location: thankyou.html");
    exit();
} else {
    echo "Failed";
}

\$conn->close();
?>
EOF

############################################
# WAIT FOR RDS
############################################

until mysql -h $RDS_HOST -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1
do
  sleep 10
done

mysql -h $RDS_HOST -u $DB_USER -p$DB_PASS <<EOSQL
CREATE DATABASE IF NOT EXISTS $DB_NAME;
USE $DB_NAME;

CREATE TABLE IF NOT EXISTS users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100),
  email VARCHAR(100),
  phone VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
EOSQL

#install mysql php
sudo apt update
sudo apt install php-mysql



systemctl restart apache2
