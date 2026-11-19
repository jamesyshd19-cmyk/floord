#!/usr/bin/env sh
set -eu

RELEASE_BIN="https://github.com/polete-bermejo/floord/releases/latest/download/floord-linux"
BINARY="floord"
BINARY_PATH="/usr/local/bin/$BINARY"
SERVICE_PATH="$HOME/.config/systemd/user"
CONFIG_PATH="$HOME/.config/floord"
CONFIG_FILE="$CONFIG_PATH/config.toml"
SERVICE_FILE="$SERVICE_PATH/floor-daemon.service"

TMP="$(mktemp)"
trap 'rm -f "$TMP"' EXIT

# DOWNLOAD BINARY
echo "Downloading latest Floord release..."
curl -fsSL "$RELEASE_BIN" -o "$TMP"

# STOP PREVIOUS SERVICE
if systemctl --user is-active --quiet floor-daemon.service; then
    echo "Stopping existing Floord service..."
    systemctl --user stop floor-daemon.service
fi

# INSTALL BINARY
echo "Installing Floord..."
sudo install -m 755 "$TMP" "$BINARY_PATH"

if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$CONFIG_PATH"
    
    # CREATE CONFIG FILE
    cat > "$CONFIG_FILE" <<EOF
# Floor Daemon configuration

# General settings
daemon = true

# ==========================================
# ORGANIZER
# ==========================================

# Enable Inbox organizer service and its parameters
organizer = true
notify = true

# If not specified the program will try to find the default users downloads path
# inbox = "/home/user/Downloads"
delay = 300


# ==========================================
# CLEANUP
# ==========================================

# Enable Cleanup service and its parameters
cleanup = true

# Directories to clean
# If not specified the program will try to find the default users folders (Documents, Pictures, Videos and Music)
paths = []

# Time in days before moving files to SoonDeleted
span = 30

# Additional days before permanent deletion
grace = 7

# Allow permanent deletion
allow_deletion = false
EOF

fi

# CREATE SYSTEMD DIRECTORY
mkdir -p "$SERVICE_PATH"

# CREATE SYSTEMD SERVICE
echo "Creating Floord systemd service..."

cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Floord file organizer
After=default.target

[Service]
ExecStart=$BINARY_PATH --config $CONFIG_FILE
Restart=on-failure
RestartSec=10

[Install]
WantedBy=default.target
EOF

# INITIALIZE SYSTEMD
echo "Initializing systemd service..."

systemctl --user daemon-reload
systemctl --user enable --now floor-daemon.service

echo ""
echo "Floord installed and initialized successfully!"
echo "Version: $($BINARY_PATH -V)"
echo "Config: $CONFIG_FILE"
echo "Binary: $BINARY_PATH"
echo "Service: floor-daemon.service"
echo ""
echo "Floord will automatically start when you log in."