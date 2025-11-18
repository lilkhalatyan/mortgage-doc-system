#!/bin/bash
# user-data.sh - Save this in terraform folder

set -e

# Update system
yum update -y

# Install packages
yum install -y httpd php php-mysqlnd git

# Start and enable Apache
systemctl start httpd
systemctl enable httpd

# Create health check endpoint
cat > /var/www/html/health.html <<'EOF'
OK
EOF

# Create main page with document upload
cat > /var/www/html/index.php <<'MAINPAGE'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mortgage Document System</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        .card {
            background: white;
            border-radius: 10px;
            padding: 30px;
            box-shadow: 0 10px 30px rgba(0,0,0,0.3);
            margin-bottom: 20px;
        }
        h1 {
            color: #667eea;
            margin-bottom: 10px;
        }
        .info {
            background: #f8f9fa;
            padding: 15px;
            border-radius: 5px;
            margin: 20px 0;
            border-left: 4px solid #667eea;
        }
        .info-item {
            margin: 5px 0;
            font-size: 14px;
        }
        .status {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 12px;
            font-weight: bold;
        }
        .status.success {
            background: #d4edda;
            color: #155724;
        }
        .status.error {
            background: #f8d7da;
            color: #721c24;
        }
        .upload-area {
            border: 2px dashed #667eea;
            border-radius: 5px;
            padding: 40px;
            text-align: center;
            margin: 20px 0;
            cursor: pointer;
            transition: all 0.3s;
        }
        .upload-area:hover {
            background: #f8f9fa;
            border-color: #764ba2;
        }
        .btn {
            background: #667eea;
            color: white;
            padding: 12px 30px;
            border: none;
            border-radius: 5px;
            cursor: pointer;
            font-size: 16px;
            transition: all 0.3s;
        }
        .btn:hover {
            background: #764ba2;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(0,0,0,0.2);
        }
        input[type="file"] {
            display: none;
        }
        .document-list {
            margin-top: 20px;
        }
        .document-item {
            background: #f8f9fa;
            padding: 15px;
            margin: 10px 0;
            border-radius: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .alert {
            padding: 15px;
            border-radius: 5px;
            margin: 10px 0;
        }
        .alert.success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert.error {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="card">
            <h1>🏠 Mortgage Document System</h1>
            <p style="color: #666; margin-bottom: 20px;">Secure document management for mortgage applications</p>
            
            <div class="info">
                <div class="info-item"><strong>Instance ID:</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-id'); ?></div>
                <div class="info-item"><strong>Availability Zone:</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/placement/availability-zone'); ?></div>
                <div class="info-item"><strong>Instance Type:</strong> <?php echo file_get_contents('http://169.254.169.254/latest/meta-data/instance-type'); ?></div>
                <div class="info-item">
                    <strong>Database:</strong> 
                    <?php
                    $db_host = '${db_endpoint}';
                    $db_name = '${db_name}';
                    $db_user = '${db_username}';
                    $db_pass = '${db_password}';
                    
                    try {
                        $pdo = new PDO("mysql:host=$db_host;dbname=$db_name", $db_user, $db_pass);
                        echo '<span class="status success">✓ Connected</span>';
                    } catch(PDOException $e) {
                        echo '<span class="status error">✗ Error: ' . $e->getMessage() . '</span>';
                    }
                    ?>
                </div>
                <div class="info-item">
                    <strong>S3 Bucket:</strong> 
                    <?php
                    $bucket = '${s3_bucket}';
                    echo '<span class="status success">✓ ' . $bucket . '</span>';
                    ?>
                </div>
            </div>

            <h2 style="margin-top: 30px; color: #333;">📄 Upload Documents</h2>
            
            <?php
            if ($_SERVER['REQUEST_METHOD'] == 'POST' && isset($_FILES['document'])) {
                $file = $_FILES['document'];
                $applicant_name = $_POST['applicant_name'] ?? 'Unknown';
                $doc_type = $_POST['doc_type'] ?? 'Other';
                
                if ($file['error'] == 0) {
                    // Generate unique filename
                    $filename = time() . '_' . basename($file['name']);
                    $s3_key = "applications/{$applicant_name}/{$doc_type}/{$filename}";
                    
                    // Upload to S3 using AWS CLI (simple method)
                    $temp_file = $file['tmp_name'];
                    $command = "aws s3 cp {$temp_file} s3://{$bucket}/{$s3_key} 2>&1";
                    $output = shell_exec($command);
                    
                    if (strpos($output, 'upload:') !== false) {
                        // Save metadata to database
                        try {
                            $pdo->exec("CREATE TABLE IF NOT EXISTS documents (
                                id INT AUTO_INCREMENT PRIMARY KEY,
                                applicant_name VARCHAR(255),
                                doc_type VARCHAR(100),
                                filename VARCHAR(255),
                                s3_key VARCHAR(500),
                                upload_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                            )");
                            
                            $stmt = $pdo->prepare("INSERT INTO documents (applicant_name, doc_type, filename, s3_key) VALUES (?, ?, ?, ?)");
                            $stmt->execute([$applicant_name, $doc_type, $filename, $s3_key]);
                            
                            echo '<div class="alert success">✓ Document uploaded successfully!</div>';
                        } catch(PDOException $e) {
                            echo '<div class="alert error">✗ Database error: ' . $e->getMessage() . '</div>';
                        }
                    } else {
                        echo '<div class="alert error">✗ S3 upload failed: ' . $output . '</div>';
                    }
                } else {
                    echo '<div class="alert error">✗ File upload error: ' . $file['error'] . '</div>';
                }
            }
            ?>

            <form method="POST" enctype="multipart/form-data" id="uploadForm">
                <div style="margin: 15px 0;">
                    <input type="text" name="applicant_name" placeholder="Applicant Name" required 
                           style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px;">
                </div>
                
                <div style="margin: 15px 0;">
                    <select name="doc_type" required 
                            style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px;">
                        <option value="">Select Document Type</option>
                        <option value="W2">W-2 Form</option>
                        <option value="PayStub">Pay Stub</option>
                        <option value="BankStatement">Bank Statement</option>
                        <option value="TaxReturn">Tax Return</option>
                        <option value="Other">Other</option>
                    </select>
                </div>
                
                <div class="upload-area" onclick="document.getElementById('fileInput').click()">
                    <p style="font-size: 48px; margin-bottom: 10px;">📎</p>
                    <p style="color: #667eea; font-weight: bold;">Click to select document</p>
                    <p style="color: #999; font-size: 14px; margin-top: 5px;">PDF, JPG, PNG (Max 10MB)</p>
                </div>
                
                <input type="file" id="fileInput" name="document" accept=".pdf,.jpg,.jpeg,.png" required>
                
                <button type="submit" class="btn">Upload Document</button>
            </form>

            <h2 style="margin-top: 40px; color: #333;">📋 Recent Uploads</h2>
            <div class="document-list">
                <?php
                if (isset($pdo)) {
                    try {
                        $stmt = $pdo->query("SELECT * FROM documents ORDER BY upload_date DESC LIMIT 10");
                        $documents = $stmt->fetchAll(PDO::FETCH_ASSOC);
                        
                        if (count($documents) > 0) {
                            foreach ($documents as $doc) {
                                echo '<div class="document-item">';
                                echo '<div>';
                                echo '<strong>' . htmlspecialchars($doc['applicant_name']) . '</strong><br>';
                                echo '<small style="color: #666;">' . htmlspecialchars($doc['doc_type']) . ' - ' . htmlspecialchars($doc['filename']) . '</small><br>';
                                echo '<small style="color: #999;">' . $doc['upload_date'] . '</small>';
                                echo '</div>';
                                echo '<span class="status success">✓ Stored</span>';
                                echo '</div>';
                            }
                        } else {
                            echo '<p style="color: #999; text-align: center; padding: 20px;">No documents uploaded yet</p>';
                        }
                    } catch(PDOException $e) {
                        echo '<p style="color: #999;">Database not initialized yet</p>';
                    }
                }
                ?>
            </div>
        </div>

        <div class="card" style="background: #f8f9fa;">
            <h3 style="color: #333;">🎯 Learning Objectives</h3>
            <ul style="margin: 15px 0 0 20px; color: #666;">
                <li>✓ Multi-AZ VPC with public/private subnets</li>
                <li>✓ Application Load Balancer with Auto Scaling</li>
                <li>✓ RDS MySQL database (encrypted)</li>
                <li>✓ S3 document storage (versioned)</li>
                <li>✓ IAM roles and security groups</li>
                <li>✓ Infrastructure as Code with Terraform</li>
            </ul>
        </div>
    </div>

    <script>
        document.getElementById('fileInput').addEventListener('change', function(e) {
            const fileName = e.target.files[0]?.name;
            if (fileName) {
                document.querySelector('.upload-area p:nth-child(2)').textContent = '✓ ' + fileName;
            }
        });
    </script>
</body>
</html>
MAINPAGE

# Set permissions
chown -R apache:apache /var/www/html
chmod -R 755 /var/www/html

# Configure PHP
sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 10M/' /etc/php.ini
sed -i 's/post_max_size = 8M/post_max_size = 10M/' /etc/php.ini

# Restart Apache
systemctl restart httpd

# Install CloudWatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

echo "Setup complete!"