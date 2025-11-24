#!/bin/bash

PI_USER="pi"
PI_HOST="192.168.1.50"
PROJECT_NAME="QtApp"
SERVICE_FILE="QtApp.service"

# Đường dẫn trên Pi
REMOTE_PROJECT_PATH="/home/${PI_USER}/sangank/${PROJECT_NAME}"
REMOTE_INSTALL_PATH="/usr/local/bin"
REMOTE_SERVICE_PATH="/etc/systemd/system"

set -e

# 1. Đồng bộ hóa mã nguồn sang Pi, loại trừ thư mục 'build'
echo ">>> [1/3] Syncing source code to Pi..."
rsync -avz --delete --exclude 'build' . "${PI_USER}@${PI_HOST}:${REMOTE_PROJECT_PATH}"

# 2. Xây dựng và cài đặt trên Pi
echo ">>> [2/3] Building and installing on Pi..."
ssh "${PI_USER}@${PI_HOST}" "
    set -e
    echo '>>> Changing directory to ${REMOTE_PROJECT_PATH}'
    cd \"${REMOTE_PROJECT_PATH}\"

    echo '>>> Installing service...'
    sudo systemctl stop ${SERVICE_FILE} || true
    sudo cp \"${SERVICE_FILE}\" \"${REMOTE_SERVICE_PATH}/${SERVICE_FILE}\"
    
    echo '>>> Building project on Pi...'
    make cross

"

# 3. Tải lại và khởi động lại dịch vụ trên Pi
echo ">>> [3/3] Reloading and restarting service on Pi..."
ssh "${PI_USER}@${PI_HOST}" "
    set -e
    sudo systemctl daemon-reload
    sudo systemctl enable ${SERVICE_FILE}
    sudo systemctl restart ${SERVICE_FILE}
    
    sleep 2
    sudo systemctl status ${SERVICE_FILE} --no-pager
"

echo ">>> Done! Deployment completed successfully."