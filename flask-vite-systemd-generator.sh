#!/bin/bash

# Set up error handling and logging
set -e
LOG_FILE="/tmp/flask_react_setup.log"
exec 1> >(tee -a "$LOG_FILE")
exec 2> >(tee -a "$LOG_FILE" >&2)

# Error handling function
handle_error() {
    local line_num=$1
    local error_code=$2
    echo "Error occurred in script at line $line_num with exit code $error_code"
    echo "Check the log file at $LOG_FILE for details"
    
    # Clean up if needed
    if [ -n "$PROJECT_NAME" ] && [ -d "$PROJECT_NAME" ]; then
        echo "Cleaning up project directory..."
        rm -rf "$PROJECT_NAME"
    fi
    
    exit $error_code
}

trap 'handle_error ${LINENO} $?' ERR

echo "=== SystemD-Auto-Flask-Vite Project Generator ==="
echo "Log file: $LOG_FILE"

# Get script directory with error handling
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)" || {
    echo "Error: Cannot determine script directory"
    exit 1
}

# Create a base directory for all projects if it doesn't exist
BASE_DIR="$SCRIPT_DIR/projects"
mkdir -p "$BASE_DIR" || {
    echo "Error: Cannot create projects directory"
    exit 1
}

# Ensure we're in the base directory before proceeding
cd "$BASE_DIR" || {
    echo "Error: Cannot access projects directory"
    exit 1
}

# Project name validation function
validate_project_name() {
    local name=$1
    if [ -z "$name" ]; then
        echo "Error: Project name cannot be empty!"
        return 1
    fi
    
    if ! [[ $name =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "Error: Project name can only contain letters, numbers, and underscores"
        return 1
    fi
    
    if [ -d "$name" ]; then
        echo "Error: Directory $name already exists!"
        return 1
    fi   
    
    return 0
}

# Port validation function
validate_port() {
    local port=$1
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -lt 1024 ] || [ "$port" -gt 65535 ]; then
        echo "Error: Please enter a valid port number (1024-65535)"
        return 1
    fi
    return 0
}

# Get and validate project name with retry logic
get_project_name() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if [ -n "$1" ]; then
            PROJECT_NAME="$1"
        else
            read -p "Enter project name: " PROJECT_NAME
        fi
        
        if validate_project_name "$PROJECT_NAME"; then
            return 0
        fi
        
        if [ -n "$1" ]; then
            return 1  # Exit if project name was provided as argument
        fi
        
        echo "Attempt $attempt of $max_attempts"
        ((attempt++))
    done
    
    echo "Maximum attempts reached. Exiting."
    return 1
}

# Get and validate port number with retry logic
get_port_number() {
    local max_attempts=3
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        read -p "Enter port number for Flask backend (default: 5000): " PORT_NUMBER
        PORT_NUMBER=${PORT_NUMBER:-5000}
        
        if validate_port "$PORT_NUMBER"; then
            return 0
        fi
        
        echo "Attempt $attempt of $max_attempts"
        ((attempt++))
    done
    
    echo "Maximum attempts reached. Exiting."
    return 1
}

# System requirements check function
check_system_requirements() {
    local requirements_met=true
    
    # Check Python version
    if ! command -v python3 &> /dev/null; then
        echo "Error: Python 3 is not installed. Please install Python 3.8 or higher."
        requirements_met=false
    else
        if ! PYTHON_VERSION=$(python3 -c 'import sys; v=sys.version_info; print(f"{v.major}.{v.minor}")'); then
            echo "Error: Failed to determine Python version"
            return 1
        fi
        
        MAJOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f1)
        MINOR_VERSION=$(echo $PYTHON_VERSION | cut -d. -f2)
        
        if [ "$MAJOR_VERSION" -lt 3 ] || ([ "$MAJOR_VERSION" -eq 3 ] && [ "$MINOR_VERSION" -lt 8 ]); then
            echo "Error: Python 3.8 or higher is required. Found version: $PYTHON_VERSION"
            requirements_met=false
        fi
    fi
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        echo "Error: Node.js is not installed. Please install Node.js and npm."
        requirements_met=false
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        echo "Error: npm is not installed. Please install npm."
        requirements_met=false
    fi
    
    # Check if running as root
    if [ "$EUID" = 0 ]; then
        echo "Error: Please run this script as a regular user, not as root/sudo"
        requirements_met=false
    fi
    
    [ "$requirements_met" = true ]
    return $?
}

# Main execution
{
    # Check system requirements first
    echo "Checking system requirements..."
    if ! check_system_requirements; then
        exit 1
    fi
    
    # Get and validate project name
    if ! get_project_name "$1"; then
        exit 1
    fi
    
    # Get and validate port number
    if ! get_port_number; then
        exit 1
    fi
    
    # Create project directory and configuration
    echo "Creating project directory in: $BASE_DIR"
    if ! mkdir -p "$BASE_DIR/$PROJECT_NAME"; then
        echo "Error: Failed to create project directory"
        exit 1
    fi
    
    if ! cd "$BASE_DIR/$PROJECT_NAME"; then
        echo "Error: Failed to enter project directory"
        exit 1
    fi
    
    echo "Creating configuration..."
    if ! cat > .env << EOL
FLASK_PORT=$PORT_NUMBER
PROJECT_NAME=$PROJECT_NAME
EOL
    then
        echo "Error: Failed to create configuration file"
        exit 1
    fi
    
    echo "Initial setup completed successfully!"
} || {
    handle_error ${LINENO} $?
}

# Function to create and set up Flask backend
create_flask_backend() {
    echo "Creating Flask backend..."
    
    # Create requirements.txt
    if ! cat > requirements.txt << EOL
flask
flask-cors
python-dotenv
EOL
    then
        echo "Error: Failed to create requirements.txt"
        return 1
    fi

    # Create virtual environment
    if [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        if ! python3 -m venv .venv; then
            echo "Error: Failed to create virtual environment"
            return 1
        fi
    fi

    # Activate virtual environment
    echo "Activating virtual environment..."
    if ! source .venv/bin/activate; then
        echo "Error: Failed to activate virtual environment"
        return 1
    fi

    # Install requirements
    echo "Installing Python dependencies..."
    if ! pip install -r requirements.txt; then
        echo "Error: Failed to install Python dependencies"
        return 1
    fi

    # Create Flask application
    echo "Creating Flask application..."
    if ! cat > app.py << EOL
from flask import Flask, send_from_directory
from flask_cors import CORS
import os
from dotenv import load_dotenv

try:
    load_dotenv()
except Exception as e:
    print(f"Warning: Failed to load .env file: {e}")

app = Flask(__name__, 
    static_folder='frontend/dist',
    static_url_path='')
CORS(app)

@app.route('/api/test')
def test():
    return {'message': 'Backend is connected!'}

@app.route('/')
def serve():
    try:
        return send_from_directory(app.static_folder, 'index.html')
    except Exception as e:
        return {'error': str(e)}, 500

if __name__ == '__main__':
    try:
        port = int(os.getenv('FLASK_PORT', 5000))
        app.run(host='0.0.0.0', debug=True, port=port)
    except ValueError as e:
        print(f"Error: Invalid port configuration: {e}")
        exit(1)
    except Exception as e:
        print(f"Error starting server: {e}")
        exit(1)
EOL
    then
        echo "Error: Failed to create Flask application"
        return 1
    fi

    return 0
}

# Function to create and set up React frontend
create_react_frontend() {
    echo "Creating React frontend..."
    
    # Create frontend directory if it doesn't exist
    if [ -d "frontend" ]; then
        echo "Warning: Frontend directory already exists. Backing up..."
        if ! mv frontend "frontend_backup_$(date +%Y%m%d_%H%M%S)"; then
            echo "Error: Failed to backup existing frontend directory"
            return 1
        fi
    fi

    # Create React project with Vite
    echo "Initializing React project..."
    if ! npm create vite@latest frontend -- --template react; then
        echo "Error: Failed to create React project"
        return 1
    fi

    # Navigate to frontend directory
    if ! cd frontend; then
        echo "Error: Failed to enter frontend directory"
        return 1
    fi

    # Install dependencies
    echo "Installing frontend dependencies..."
    if ! npm install; then
        echo "Error: Failed to install frontend dependencies"
        cd ..
        return 1
    fi

    # Configure Vite
    echo "Configuring Vite..."
    if ! cat > vite.config.js << EOL
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:${PORT_NUMBER}',
        changeOrigin: true,
        secure: false,
        ws: true,
        configure: (proxy, _options) => {
          proxy.on('error', (err, _req, _res) => {
            console.log('proxy error', err);
          });
          proxy.on('proxyReq', (proxyReq, req, _res) => {
            console.log('Sending Request to the Target:', req.method, req.url);
          });
          proxy.on('proxyRes', (proxyRes, req, _res) => {
            console.log('Received Response from the Target:', proxyRes.statusCode, req.url);
          });
        },
      }
    },
    watch: {
      usePolling: true
    }
  }
})
EOL
    then
        echo "Error: Failed to create Vite configuration"
        cd ..
        return 1
    fi

    # Return to project root
    cd ..
    return 0
}

# Function to validate the setup
validate_setup() {
    local errors=0

    # Check Flask backend
    if [ ! -f "app.py" ]; then
        echo "Error: Flask application file is missing"
        ((errors++))
    fi

    if [ ! -f "requirements.txt" ]; then
        echo "Error: Python requirements file is missing"
        ((errors++))
    fi

    if [ ! -d ".venv" ]; then
        echo "Error: Virtual environment is missing"
        ((errors++))
    fi

    # Check React frontend
    if [ ! -d "frontend" ]; then
        echo "Error: Frontend directory is missing"
        ((errors++))
    fi

    if [ ! -f "frontend/package.json" ]; then
        echo "Error: Frontend package.json is missing"
        ((errors++))
    fi

    if [ ! -f "frontend/vite.config.js" ]; then
        echo "Error: Vite configuration is missing"
        ((errors++))
    fi

    return $errors
}

# Main setup execution
{
    echo "Starting backend and frontend setup..."

    # Create Flask backend
    if ! create_flask_backend; then
        echo "Error: Failed to set up Flask backend"
        exit 1
    fi

    # Create React frontend
    if ! create_react_frontend; then
        echo "Error: Failed to set up React frontend"
        exit 1
    fi

    # Validate the setup
    echo "Validating setup..."
    if ! validate_setup; then
        echo "Error: Setup validation failed"
        exit 1
    fi

    echo "Backend and frontend setup completed successfully!"

} || {
    handle_error ${LINENO} $?
}

# Function to create service manager script
create_service_manager() {
    echo "Creating service management script..."
    
    if ! cat > service_manager.sh << 'EOL'
#!/bin/bash

# Error handling
set -e
trap 'echo "Error occurred in service manager at line $LINENO"; exit 1' ERR

# Check if running as root
if [ "$EUID" = 0 ]; then
    echo "Please run this script as a regular user. Use sudo only when prompted."
    exit 1
fi

# Verify environment file exists and load it
if [ ! -f ".env" ]; then
    echo "Error: Configuration file .env not found!"
    exit 1
fi

source .env || { echo "Error: Failed to load configuration"; exit 1; }

# Verify required variables
if [ -z "$PROJECT_NAME" ] || [ -z "$FLASK_PORT" ]; then
    echo "Error: Missing required configuration variables"
    exit 1
fi

SERVICE_NAME="${PROJECT_NAME}_flask_react"

# Function to verify service exists
check_service_exists() {
    if ! systemctl list-unit-files | grep -q "$SERVICE_NAME"; then
        echo "Service $SERVICE_NAME is not installed"
        return 1
    fi
    return 0
}

show_menu() {
    clear
    echo "=== Service Manager for $PROJECT_NAME ==="
    echo "Current Status:"
    if check_service_exists; then
        systemctl is-active "$SERVICE_NAME" >/dev/null && \
            echo "Service is running" || echo "Service is stopped"
    else
        echo "Service is not installed"
    fi
    echo
    echo "1. Install service"
    echo "2. Start service"
    echo "3. Stop service"
    echo "4. Restart service"
    echo "5. Check service status"
    echo "6. View logs"
    echo "7. Remove service"
    echo "8. Start development servers"
    echo "9. Build React frontend"    # New option
    echo "10. Exit"                   # Changed from 9 to 10
}

# Add this new function
build_frontend() {
    echo "Building React frontend..."
    if [ ! -d "frontend" ]; then
        echo "Error: frontend directory not found!"
        return 1
    fi
    
    cd frontend || return 1
    if ! npm run build; then
        echo "Failed to build frontend"
        cd ..
        return 1
    fi
    cd ..
    echo "Frontend built successfully"
}

install_service() {
    # Build frontend first
    build_frontend || { echo "Failed to build frontend"; return 1; }
    
    # Then proceed with service installation
    ./install_service.sh || echo "Failed to install service"
}

start_service() {

    if ! check_service_exists; then return 1; fi

    echo "Starting service..."
    if ! sudo systemctl start "$SERVICE_NAME"; then
        echo "Failed to start service"
        return 1
    fi
    echo "Service started successfully"
}

stop_service() {
    if ! check_service_exists; then return 1; fi
    
    echo "Stopping service..."
    if ! sudo systemctl stop "$SERVICE_NAME"; then
        echo "Failed to stop service"
        return 1
    fi
    echo "Service stopped successfully"
}

restart_service() {
    if ! check_service_exists; then return 1; fi
    
    echo "Restarting service..."
    if ! sudo systemctl restart "$SERVICE_NAME"; then
        echo "Failed to restart service"
        return 1
    fi
    echo "Service restarted successfully"
}

check_status() {
    if ! check_service_exists; then return 1; fi
    
    echo "Service status:"
    if ! sudo systemctl status "$SERVICE_NAME"; then
        echo "Failed to get service status"
        return 1
    fi
}

view_logs() {
    if ! check_service_exists; then return 1; fi
    
    echo "Viewing logs (press Ctrl+C to exit)..."
    if ! sudo journalctl -u "$SERVICE_NAME" -f; then
        echo "Failed to retrieve logs"
        return 1
    fi
}

remove_service() {
    if ! check_service_exists; then return 1; fi
    
    read -p "Are you sure you want to remove the service? (y/N) " confirm
    if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
        echo "Operation cancelled"
        return 0
    fi
    
    echo "Removing service..."
    if ! sudo systemctl stop "$SERVICE_NAME"; then
        echo "Warning: Failed to stop service"
    fi
    
    if ! sudo systemctl disable "$SERVICE_NAME"; then
        echo "Warning: Failed to disable service"
    fi
    
    if ! sudo rm "/etc/systemd/system/$SERVICE_NAME.service"; then
        echo "Failed to remove service file"
        return 1
    fi
    
    if ! sudo systemctl daemon-reload; then
        echo "Warning: Failed to reload systemd daemon"
    fi
    
    echo "Service removed successfully"
}

start_dev() {
    # Verify development scripts exist
    if [ ! -f "./start_dev.sh" ]; then
        echo "Error: Development startup script not found"
        return 1
    fi
    
    # Start development servers
    ./start_dev.sh
}

# Main loop with error handling
while true; do
    show_menu
    read -p "Enter choice [1-10]: " choice    # Changed from [1-9] to [1-10]
    
    case $choice in
        1) install_service ;;
        2) start_service ;;
        3) stop_service ;;
        4) restart_service ;;
        5) check_status ;;
        6) view_logs ;;
        7) remove_service ;;
        8) start_dev ;;
        9) build_frontend ;;    # New option
        10) echo "Exiting..."; exit 0 ;;    # Changed from 9 to 10
        *)
            echo "Invalid option"
            ;;
    esac
    
    read -p "Press enter to continue..."
done
EOL
    then
        echo "Error: Failed to create service manager script"
        return 1
    fi

    # Make script executable
    if ! chmod +x service_manager.sh; then
        echo "Error: Failed to make service manager script executable"
        return 1
    fi

    return 0
}

# Function to create service installation script
create_install_service() {
    echo "Creating service installation script..."
    
    if ! cat > install_service.sh << 'EOL'
#!/bin/bash

set -e
trap 'echo "Error occurred during service installation at line $LINENO"; exit 1' ERR

# Load configuration
if [ ! -f ".env" ]; then
    echo "Error: Configuration file .env not found!"
    exit 1
fi

source .env || { echo "Error: Failed to load configuration"; exit 1; }

# Verify required variables
if [ -z "$PROJECT_NAME" ] || [ -z "$FLASK_PORT" ]; then
    echo "Error: Missing required configuration variables"
    exit 1
fi

# Check if running as root
if [ "$EUID" = 0 ]; then
    echo "Please run this script as a regular user with sudo privileges"
    exit 1
fi

# Verify sudo access
if ! sudo -v; then
    echo "Error: This script requires sudo privileges"
    exit 1
fi

SERVICE_NAME="${PROJECT_NAME}_flask_react"
INSTALL_DIR="$(pwd)"

echo "Creating systemd service..."
if ! sudo tee /etc/systemd/system/${SERVICE_NAME}.service > /dev/null << EOF
[Unit]
Description=${PROJECT_NAME} Flask-React Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=$USER
Group=$USER
WorkingDirectory=${INSTALL_DIR}
Environment="PATH=${INSTALL_DIR}/.venv/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
Environment="FLASK_APP=app.py"
Environment="FLASK_ENV=production"
Environment="FLASK_PORT=${FLASK_PORT}"
ExecStart=${INSTALL_DIR}/.venv/bin/python app.py
Restart=always
; RestartSec=3
; Nice=10
; CPUQuota=50%
; MemoryLimit=256M

[Install]
WantedBy=multi-user.target
EOF
then
    echo "Error: Failed to create service file"
    exit 1
fi

echo "Setting permissions..."
if ! sudo chmod 644 /etc/systemd/system/${SERVICE_NAME}.service; then
    echo "Error: Failed to set service file permissions"
    exit 1
fi

echo "Reloading systemd daemon..."
if ! sudo systemctl daemon-reload; then
    echo "Error: Failed to reload systemd daemon"
    exit 1
fi

echo "Enabling service..."
if ! sudo systemctl enable ${SERVICE_NAME}.service; then
    echo "Error: Failed to enable service"
    exit 1
fi

echo "Starting service..."
if ! sudo systemctl start ${SERVICE_NAME}.service; then
    echo "Error: Failed to start service"
    exit 1
fi

echo "Service installation completed successfully!"
EOL
    then
        echo "Error: Failed to create installation script"
        return 1
    fi

    # Make script executable
    if ! chmod +x install_service.sh; then
        echo "Error: Failed to make installation script executable"
        return 1
    fi

    return 0
}

# Main execution for service scripts creation
{
    echo "Creating service management scripts..."
    
    # Create service manager
    if ! create_service_manager; then
        echo "Error: Failed to create service manager"
        exit 1
    fi
    
    # Create installation script
    if ! create_install_service; then
        echo "Error: Failed to create installation script"
        exit 1
    fi
    
    echo "Service management scripts created successfully!"
    
} || {
    handle_error ${LINENO} $?
}

# Function to create development startup script
create_dev_script() {
    echo "Creating development startup script..."
    
    if ! cat > start_dev.sh << 'EOL'
#!/bin/bash

# Error handling
set -e
trap 'echo "Error occurred in development script at line $LINENO"; exit 1' ERR

# Load environment variables
if [ ! -f ".env" ]; then
    echo "Error: .env file not found"
    exit 1
fi

source .env || { echo "Error: Failed to load .env file"; exit 1; }

# Initialize variables for process management
FLASK_PID=""
REACT_PID=""

# Cleanup function
cleanup() {
    echo "Shutting down development servers..."
    if [ -n "$FLASK_PID" ]; then
        kill $FLASK_PID 2>/dev/null || true
    fi
    if [ -n "$REACT_PID" ]; then
        kill $REACT_PID 2>/dev/null || true
    fi
    exit 0
}

# Set up cleanup trap
trap cleanup SIGINT SIGTERM

# Function to check port availability
check_port() {
    local port=$1
    if lsof -i:$port > /dev/null 2>&1; then
        echo "Error: Port $port is already in use"
        return 1
    fi
    return 0
}

# Check and create virtual environment
setup_virtual_env() {
    if [ ! -d ".venv" ]; then
        echo "Creating virtual environment..."
        if ! python3 -m venv .venv; then
            echo "Error: Failed to create virtual environment"
            return 1
        fi
    fi

    echo "Activating virtual environment..."
    if ! source .venv/bin/activate; then
        echo "Error: Failed to activate virtual environment"
        return 1
    fi

    if [ ! -f "requirements.txt" ]; then
        echo "Error: requirements.txt not found"
        return 1
    fi

    echo "Installing Python dependencies..."
    if ! pip install -r requirements.txt; then
        echo "Error: Failed to install Python dependencies"
        return 1
    fi

    return 0
}

# Function to setup frontend
setup_frontend() {
    if [ ! -d "frontend" ]; then
        echo "Error: Frontend directory not found"
        return 1
    fi

    cd frontend || { echo "Error: Failed to enter frontend directory"; return 1; }

    if [ ! -d "node_modules" ]; then
        echo "Installing frontend dependencies..."
        if ! npm install; then
            echo "Error: Failed to install frontend dependencies"
            cd ..
            return 1
        fi
    fi

    cd ..
    return 0
}

# Main execution
echo "Starting development environment..."

# Verify port availability
if ! check_port ${FLASK_PORT:-5000}; then
    exit 1
fi

# Set up virtual environment
if ! setup_virtual_env; then
    exit 1
fi

# Set up frontend
if ! setup_frontend; then
    exit 1
fi

# Start Flask backend
echo "Starting Flask backend on port ${FLASK_PORT}..."
FLASK_APP=app.py \
FLASK_ENV=development \
FLASK_DEBUG=1 \
flask run -p ${FLASK_PORT} &
FLASK_PID=$!

# Verify Flask server started
sleep 2
if ! kill -0 $FLASK_PID 2>/dev/null; then
    echo "Error: Flask server failed to start"
    cleanup
    exit 1
fi

# Start React frontend
echo "Starting React frontend..."
cd frontend || { echo "Error: Failed to enter frontend directory"; cleanup; exit 1; }
npm run dev &
REACT_PID=$!

# Verify React server started
sleep 2
if ! kill -0 $REACT_PID 2>/dev/null; then
    echo "Error: React development server failed to start"
    cleanup
    exit 1
fi

cd ..

echo "Development servers started successfully!"
echo "Flask backend running on port ${FLASK_PORT}"
echo "React frontend running (check console for port)"
echo "Press Ctrl+C to stop both servers"

# Wait for either process to exit
wait $FLASK_PID $REACT_PID
EOL
    then
        echo "Error: Failed to create development script"
        return 1
    fi

    # Make script executable
    if ! chmod +x start_dev.sh; then
        echo "Error: Failed to make development script executable"
        return 1
    fi

    return 0
}

# Function to create final configuration files
create_final_config() {
    echo "Creating final configuration files..."

    # Create .gitignore
    if ! cat > .gitignore << 'EOL'
# Python
.venv/
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
*.py[cod]
*$py.class

# Node
node_modules/
/frontend/dist/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Environment
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# IDE
.idea/
.vscode/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db
EOL
    then
        echo "Error: Failed to create .gitignore"
        return 1
    fi

    # Create README.md
    if ! cat > README.md << EOL
# ${PROJECT_NAME}

Flask-React application with systemd service management.

## Setup

1. Ensure Python 3.8+ and Node.js are installed
2. Clone this repository
3. Run the development server:
   \`\`\`bash
   ./start_dev.sh
   \`\`\`

## Service Management

Use the service manager script:
\`\`\`bash
./service_manager.sh
\`\`\`

## Configuration

- Flask backend port: ${FLASK_PORT}
- Environment variables: See .env file

## Development

- Flask backend: \`app.py\`
- React frontend: \`frontend/\` directory

## Production

To install as a service:
\`\`\`bash
./service_manager.sh
\`\`\`
Then select "Install service" from the menu.
EOL
    then
        echo "Error: Failed to create README.md"
        return 1
    fi

    return 0
}

# Function to validate final setup
validate_final_setup() {
    local errors=0

    echo "Validating final setup..."

    # Check all required files exist
    local required_files=(".env" "app.py" "requirements.txt" "start_dev.sh" 
                         "service_manager.sh" "install_service.sh" ".gitignore" "README.md")
    
    for file in "${required_files[@]}"; do
        if [ ! -f "$file" ]; then
            echo "Error: Required file $file is missing"
            ((errors++))
        fi
    done

    # Check all scripts are executable
    local executable_files=("start_dev.sh" "service_manager.sh" "install_service.sh")
    
    for file in "${executable_files[@]}"; do
        if [ ! -x "$file" ]; then
            echo "Error: Script $file is not executable"
            ((errors++))
        fi
    done

    # Verify frontend setup
    if [ ! -d "frontend" ]; then
        echo "Error: Frontend directory is missing"
        ((errors++))
    elif [ ! -f "frontend/package.json" ] || [ ! -f "frontend/vite.config.js" ]; then
        echo "Error: Frontend configuration is incomplete"
        ((errors++))
    fi

    return $errors
}

# Main execution for final setup
{
    # Create development script
    if ! create_dev_script; then
        echo "Error: Failed to create development script"
        exit 1
    fi

    # Create final configuration
    if ! create_final_config; then
        echo "Error: Failed to create final configuration"
        exit 1
    fi

    # Validate final setup
    if ! validate_final_setup; then
        echo "Error: Final setup validation failed"
        exit 1
    fi

    echo "Final setup completed successfully!"
    echo "Your project is ready to use:"
    echo "1. For development: ./start_dev.sh"
    echo "2. For service management: ./service_manager.sh"
    echo
    echo "Project structure is ready at: $(pwd)/$PROJECT_NAME"

} || {
    handle_error ${LINENO} $?
}

handle_error() {
    local line_num=$1
    local error_code=$2
    echo "Error occurred in script at line $line_num with exit code $error_code"
    echo "Check the log file at $LOG_FILE for details"
    
    # Clean up if needed
    if [ -n "$PROJECT_NAME" ] && [ -d "$BASE_DIR/$PROJECT_NAME" ]; then
        echo "Cleaning up project directory..."
        rm -rf "$BASE_DIR/$PROJECT_NAME"
    fi
    
    exit $error_code
}
