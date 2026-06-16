#!/bin/bash

# ============================================================
# Project Factory Script
# Automates creation of the attendance_tracker_{input}/ workspace,
# allows dynamic config editing, handles SIGINT gracefully,
# and validates the environment.
# ============================================================

# ---------- 1. Get project name from user ----------
read -p "Enter a name for your project (e.g., v1, v2): " PROJECT_SUFFIX

if [ -z "$PROJECT_SUFFIX" ]; then
    echo "Error: Project name cannot be empty."
    exit 1
fi

PROJECT_DIR="attendance_tracker_${PROJECT_SUFFIX}"
ARCHIVE_NAME="attendance_tracker_${PROJECT_SUFFIX}_archive"

# ---------- 3. Signal Trap (defined early so it covers the whole script) ----------
cleanup() {
    echo ""
    echo "Signal received (SIGINT). Cleaning up..."

    if [ -d "$PROJECT_DIR" ]; then
        echo "Archiving current state of '$PROJECT_DIR' into '${ARCHIVE_NAME}.tar.gz'..."
        tar -czf "${ARCHIVE_NAME}.tar.gz" "$PROJECT_DIR"

        echo "Removing incomplete directory '$PROJECT_DIR'..."
        rm -rf "$PROJECT_DIR"

        echo "Archive created: ${ARCHIVE_NAME}.tar.gz"
        echo "Workspace cleaned up."
    else
        echo "No project directory found to clean up."
    fi

    exit 1
}

trap cleanup SIGINT

# ---------- 1. Directory Architecture ----------
echo "Creating directory structure for '$PROJECT_DIR'..."

mkdir -p "$PROJECT_DIR/Helpers"
mkdir -p "$PROJECT_DIR/reports"

touch "$PROJECT_DIR/attendance_checker.py"
touch "$PROJECT_DIR/Helpers/assets.csv"
touch "$PROJECT_DIR/reports/reports.log"

# Create initial config.json with default thresholds
cat > "$PROJECT_DIR/Helpers/config.json" << 'EOF'
{
    "warning_threshold": 75,
    "failure_threshold": 50
}
EOF

echo "Directory structure created successfully:"
echo "$PROJECT_DIR/"
echo "├── attendance_checker.py"
echo "├── Helpers/"
echo "│   ├── assets.csv"
echo "│   └── config.json"
echo "└── reports/"
echo "    └── reports.log"
echo ""

# ---------- 2. Dynamic Configuration (Stream Editing) ----------
read -p "Do you want to update the attendance thresholds? (y/n): " UPDATE_CONFIG

if [ "$UPDATE_CONFIG" = "y" ] || [ "$UPDATE_CONFIG" = "Y" ]; then

    read -p "Enter new Warning threshold (default 75): " WARNING_VAL
    read -p "Enter new Failure threshold (default 50): " FAILURE_VAL

    # Use defaults if input is empty
    WARNING_VAL=${WARNING_VAL:-75}
    FAILURE_VAL=${FAILURE_VAL:-50}

    # Validate numeric input
    if ! [[ "$WARNING_VAL" =~ ^[0-9]+$ ]] || ! [[ "$FAILURE_VAL" =~ ^[0-9]+$ ]]; then
        echo "Error: Thresholds must be numeric. Skipping config update."
    else
        CONFIG_FILE="$PROJECT_DIR/Helpers/config.json"

        # Use sed for in-place editing of config.json
        sed -i "s/\"warning_threshold\": [0-9]*/\"warning_threshold\": $WARNING_VAL/" "$CONFIG_FILE"
        sed -i "s/\"failure_threshold\": [0-9]*/\"failure_threshold\": $FAILURE_VAL/" "$CONFIG_FILE"

        echo "config.json updated:"
        cat "$CONFIG_FILE"
    fi
else
    echo "Keeping default thresholds (Warning: 75, Failure: 50)."
fi

echo ""

# ---------- 4. Environment Validation (Health Check) ----------
echo "Running Health Check..."

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    echo "Success: python3 is installed ($PYTHON_VERSION)."
else
    echo "Warning: python3 is not installed on this system."
fi

if [ -d "$PROJECT_DIR/Helpers" ] && [ -d "$PROJECT_DIR/reports" ] && [ -f "$PROJECT_DIR/attendance_checker.py" ]; then
    echo "Success: Application directory structure is correctly set up."
else
    echo "Warning: Application directory structure is incomplete."
fi

echo ""
echo "Project setup complete. Workspace ready at: $PROJECT_DIR"
