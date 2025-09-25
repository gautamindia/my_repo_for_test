 #!/bin/bash
    sudo apt update -y
    sudo apt install -y openjdk-21-jdk
    sudo apt install -y git
    sudo git clone ${var.repo_url} app
    cd app
    nohup sudo java -jar target/hellomvc-0.0.1-SNAPSHOT.jar --server.port=${var.my_app_port} > app.log 2>&1 &
    BUCKET_NAME="${bucket_name}"
    INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)

    # Copy logs on shutdown
    cat << 'EOF' > /etc/systemd/system/upload-logs.service
    [Unit]
    Description=Upload logs to S3 on shutdown
    DefaultDependencies=no
    Before=shutdown.target

    [Service]
    Type=oneshot
    ExecStart=/bin/true
    ExecStop=/usr/bin/aws s3 cp /var/log/cloud-init.log s3://${BUCKET_NAME}/${INSTANCE_ID}/cloud-init.log
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
    EOF
    systemctl enable upload-logs.service
    aws s3 cp /opt/app/logs s3://${BUCKET_NAME}/app/logs --recursive