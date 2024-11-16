![Python](https://img.shields.io/badge/python-v3.8+-blue.svg)
![Node.js](https://img.shields.io/badge/node.js-v14+-green.svg)
![Platform](https://img.shields.io/badge/platform-linux-lightgrey)
![SystemD](https://img.shields.io/badge/SystemD-Compatible-blue)
![Flask](https://img.shields.io/badge/flask-v2.0+-lightgrey.svg)
![React](https://img.shields.io/badge/React-18+-61DAFB?logo=react&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-Latest-646CFF?logo=vite&logoColor=white)
![Services](https://img.shields.io/badge/Services-Automated-green)
![Hot Reload](https://img.shields.io/badge/Hot_Reload-Enabled-ff69b4)
![Proxy](https://img.shields.io/badge/Proxy-Configured-orange)
![Error Handling](https://img.shields.io/badge/Error_Handling-Normal-yellow)
![Logs](https://img.shields.io/badge/Logging-Automated-blue)

# Flask-React-SystemD Project Generator

A project generator and management system that creates a Flask backend with React frontend, complete with SystemD service integration. This tool automates the entire setup process from development to production deployment.

## Overview

This project generator creates a complete full-stack application environment with:

- **Flask Backend**: A Python Flask server with CORS support.
- **React Frontend**: A Vite-powered React application with development server and production build setup
- **SystemD Integration**: Automatic service creation and management for production deployment
- **Development Tools**: Hot-reloading development servers for both frontend and backend
- **Service Management**: A service manager for controlling the application in production

### Key Features

- Automated project scaffolding
- Development and production environments
- SystemD service integration
- Built-in error handling and logging
- Proxy configuration for development
- Service monitoring and management tools
- Logging system

### Project Structure

```
your-project/
├── .env                 # Environment configuration
├── .venv/              # Python virtual environment
├── app.py              # Flask application
├── requirements.txt    # Python dependencies
├── service_manager.sh  # Service management script
├── install_service.sh  # Service installation script
├── start_dev.sh       # Development server script
├── frontend/          # React application
│   ├── src/           # React source code
│   ├── dist/          # Production build
│   └── package.json   # Node.js dependencies
└── README.md          # Project documentation
```

## Built With

This project integrates several excellent open-source tools and frameworks:

### Core Frameworks
- [Flask](https://flask.palletsprojects.com/) - Lightweight WSGI web application framework by Pallets
- [React](https://reactjs.org/) - JavaScript library for building user interfaces by Meta
- [Vite](https://vitejs.dev/) - Next generation frontend tooling by Evan You

### Development Tools
- [python-dotenv](https://github.com/theskumar/python-dotenv) - Environment variable management
- [flask-cors](https://flask-cors.readthedocs.io/) - CORS handling for Flask
- [SystemD](https://systemd.io/) - System and service manager for Linux

### Acknowledgments
This project is built upon these powerful tools, serving as a simple integration layer to help developers quickly set up a development environment. All credit for the core functionality goes to the original framework creators and maintainers.

The scripts in this project mainly focus on automating the setup and configuration process, while the actual heavy lifting is done by these well-established frameworks.

## Why This Project?

This project aims to simplify the process of setting up a Flask-React application with SystemD integration. While tools like Create React App and Vite handle frontend setup well, and Flask makes backend creation straightforward, combining these with SystemD services involves several manual steps that can be automated.

### 🎯 What This Tool Helps With

1. **Basic Service Integration**
   - Automates the creation of SystemD service files
   - Provides a simple interface for common service operations
   - Sets up basic logging and error handling
   - Includes reasonable default resource limits

2. **Development Setup**
   - Combines Flask and React setup in one step
   - Configures basic proxy settings for development
   - Sets up a development environment with hot reloading
   - Manages environment variables

3. **Service Management**
   - Offers a simple menu-driven interface for common tasks
   - Centralizes service commands in one script
   - Provides basic monitoring capabilities
   - Handles typical service operations

### 👥 Who Might Find This Useful?

- Developers learning to work with SystemD services
- Those who want to automate repetitive setup steps
- Anyone looking for a starting point for Flask-React projects
- Developers who prefer script-based service management

### 💡 Important Notes

- This is a helper tool, not a production-grade framework
- The configurations provided are starting points and may need adjustment
- Security settings should be reviewed before production use
- The tool aims to simplify common tasks but doesn't replace understanding the underlying technologies

### 📋 Limitations

- Basic default configurations that may need customization
- Limited error handling capabilities
- May not suit complex deployment requirements
- Should be reviewed and adjusted for specific security needs

## Prerequisites & Installation

### System Requirements

- Python 3.8 or higher
- Node.js 14 or higher
- npm 6 or higher
- Linux system with SystemD (for production deployment)
- sudo privileges (for service installation)

### Dependencies

#### Python Packages
- Flask
- Flask-CORS
- python-dotenv

#### Node.js Packages
- React
- Vite
- Additional dependencies will be installed automatically via package.json

### Installation

1. **Download the Generator**
   ```bash
   curl -O https://raw.githubusercontent.com/yourusername/flask-react-systemd/main/generator.sh
   chmod +x generator.sh
   ```

2. **Run the Generator**
   ```bash
   ./generator.sh
   ```

3. **Configure Project**
   - Enter your project name when prompted
   - Specify the desired port for the Flask backend (default: 5000)
   - The script will automatically create the project structure

4. **Verify Installation**
   ```bash
   cd your-project-name
   ls -la
   ```
   You should see all the project files and directories listed in the Project Structure section.

### First-Time Setup

After installation, the generator will:
1. Create a Python virtual environment
2. Install all Python dependencies
3. Set up the React project with Vite
4. Install all Node.js dependencies
5. Create necessary configuration files
6. Set up development scripts
7. Configure the SystemD service files

The installation process is fully automated and includes error handling. If any step fails:
- Check the log file at `/tmp/flask_react_setup.log`
- Ensure all prerequisites are properly installed
- Verify you have necessary permissions

## Development Guide

### Starting Development Servers

The project includes a convenient development script that starts both the Flask backend and React frontend servers:

```bash
./start_dev.sh
```

This script will:
1. Activate the Python virtual environment
2. Start the Flask development server
3. Launch the Vite development server for React
4. Set up hot-reloading for both servers
5. Configure the development proxy

### Development Environment

#### Backend Development (Flask)

The Flask backend is configured for development with:
- Hot-reloading enabled
- Debug mode active
- CORS configured for the frontend
- Proxy settings for API requests

To modify the Flask application:
1. Edit `app.py` in your project root
2. The server will automatically reload changes
3. Default API endpoint at `/api/test` for verification

#### Frontend Development (React)

The React frontend uses Vite for rapid development:
- Fast hot module replacement (HMR)
- Automatic proxy to Flask backend
- ES modules for instant updates
- Development server with HTTPS support

To work on the frontend:
1. Navigate to `frontend/src/`
2. Edit React components and assets
3. Changes appear instantly in browser
4. API calls automatically proxied to Flask

### Environment Variables

Development environment variables are stored in `.env`:
```bash
FLASK_PORT=5000      # Backend port
PROJECT_NAME=myapp   # Project identifier
```

Additional environment variables can be added as needed.

### Development Tools

#### API Testing
- Backend endpoints available at `http://localhost:5000/api/`
- Frontend dev server typically runs on `http://localhost:5173`
- Use the `/api/test` endpoint to verify connectivity

#### Logging
Development logs are available:
- Flask backend: Console output
- React frontend: Browser console
- System logs: `/tmp/flask_react_setup.log`

#### Development Proxy
The Vite development server is configured to proxy API requests:
- All `/api/*` requests forwarded to Flask
- WebSocket support enabled
- CORS handled automatically

[Previous sections remain the same...]

## Production Deployment

### Service Installation

The project includes basic SystemD service management scripts:

1. **Build the Frontend**
   ```bash
   ./service_manager.sh
   # Select option 9: Build React frontend
   ```
   This creates an optimized production build in `frontend/dist/`

2. **Install the Service**
   ```bash
   ./service_manager.sh
   # Select option 1: Install service
   ```
   This will:
   - Create a SystemD service unit
   - Configure the service for your user
   - Set up automatic restarts
   - Enable the service to start on boot

### Service Configuration

The SystemD service is configured with these settings:

```ini
[Unit]
Description=Your Flask-React Application
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
User=<your-user>
WorkingDirectory=/path/to/your/project
Environment="FLASK_ENV=production"
ExecStart=/path/to/venv/bin/python app.py
Restart=always
RestartSec=3
Nice=10
CPUQuota=50%
MemoryLimit=256M

[Install]
WantedBy=multi-user.target
```

### Resource Management

The service includes built-in resource limits:
- CPU usage capped at 50%
- Memory limited to 256MB
- Process priority set to nice 10
- Automatic restart on failure
- 3-second cooldown between restarts

### Service Management

Use the service manager script to control your application:

```bash
./service_manager.sh
```

Available operations:
1. Install service
2. Start service
3. Stop service
4. Restart service
5. Check service status
6. View logs
7. Remove service
8. Start development servers
9. Build React frontend
10. Exit

### Production Monitoring

#### Viewing Logs
```bash
./service_manager.sh
# Select option 6: View logs
```
This shows real-time service logs using journalctl.

#### Checking Status
```bash
./service_manager.sh
# Select option 5: Check service status
```
Displays:
- Service state
- Last logs
- Resource usage
- Uptime information

#### Health Checks

The service is configured with:
- Automatic restart on failure
- Network dependency checks
- Process monitoring
- Resource usage tracking

### Backup and Maintenance

Before updates or maintenance:
1. Stop the service:
   ```bash
   ./service_manager.sh
   # Select option 3: Stop service
   ```

2. Backup your data:
   ```bash
   # Example backup command
   tar -czf backup.tar.gz app.py frontend/dist/ .env
   ```

3. Perform maintenance

4. Restart the service:
   ```bash
   ./service_manager.sh
   # Select option 4: Restart service
   ```
[Previous sections remain the same...]

## Script Reference & Configuration

### Script Overview

#### `service_manager.sh`
The main interface for managing your application service.

```bash
Usage: ./service_manager.sh
Interactive menu provides all management options
```

Features:
- Service installation and removal
- Start/stop/restart operations
- Status monitoring
- Log viewing
- Frontend build management
- Development server launching

#### `start_dev.sh`
Development environment launcher.

```bash
Usage: ./start_dev.sh
```

Functions:
- Activates Python virtual environment
- Verifies port availability
- Starts Flask development server
- Launches Vite dev server
- Sets up proxy configuration
- Enables hot reloading
- Handles graceful shutdown

#### `install_service.sh`
SystemD service installer (usually called via service_manager.sh).

```bash
Usage: ./install_service.sh
```

Operations:
- Creates SystemD service unit
- Sets appropriate permissions
- Enables service autostart
- Configures resource limits
- Sets up environment variables

### Configuration Files

#### `.env`
Environment configuration file:

```bash
# Required Settings
FLASK_PORT=5000          # Backend server port
PROJECT_NAME=myapp       # Project identifier

# Optional Settings
FLASK_ENV=development    # development/production
FLASK_DEBUG=1           # Enable/disable debug mode
```

#### `vite.config.js`
Frontend build and development configuration:

```javascript
export default defineConfig({
  plugins: [react()],
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:5000',
        changeOrigin: true,
        secure: false,
        ws: true
      }
    },
    watch: {
      usePolling: true
    }
  }
})
```

#### `requirements.txt`
Python dependencies:

```text
flask
flask-cors
python-dotenv
```

### Error Handling

The scripts include error handling:

#### Log Files
- Main setup log: `/tmp/flask_react_setup.log`
- Service logs: Available through `service_manager.sh`
- Development server logs: Console output

#### Error Recovery
The scripts handle various error conditions:
- Port conflicts
- Missing dependencies
- Permission issues
- Network problems
- Resource constraints

#### Cleanup Operations
On failure, the scripts will:
1. Stop running services
2. Remove incomplete installations
3. Clean up temporary files
4. Log error details
5. Provide recovery instructions

### Script Customization

#### Modifying Service Settings
Edit `install_service.sh` to customize:
```bash
# Resource Limits
CPUQuota=50%
MemoryLimit=256M
Nice=10

# Restart Policy
Restart=always
RestartSec=3
```

#### Development Server Configuration
Modify `start_dev.sh` to adjust:
- Port numbers
- Proxy settings
- Hot reload configuration
- Environment variables

#### Service Manager Features
Extend `service_manager.sh` by:
1. Adding new menu options
2. Modifying existing commands
3. Adjusting resource limits
4. Changing logging behavior
5. Adding custom maintenance tasks

[Previous sections remain the same...]

## Troubleshooting & FAQ

### Common Issues

#### Service Won't Start

**Symptom:** Service fails to start or crashes immediately
```bash
./service_manager.sh
# Status shows "Active: failed"
```

**Solutions:**
1. Check logs for errors:
   ```bash
   ./service_manager.sh
   # Select option 6: View logs
   ```
2. Verify port availability:
   ```bash
   lsof -i :5000
   ```
3. Check permissions:
   ```bash
   ls -l /etc/systemd/system/your_project_flask_react.service
   ```
4. Verify environment:
   ```bash
   source .venv/bin/activate
   python app.py
   ```

#### Development Server Issues

**Symptom:** `start_dev.sh` fails to launch servers

**Solutions:**
1. Check virtual environment:
   ```bash
   rm -rf .venv
   python3 -m venv .venv
   source .venv/bin/activate
   pip install -r requirements.txt
   ```

2. Verify Node.js dependencies:
   ```bash
   cd frontend
   rm -rf node_modules
   npm install
   ```

3. Check port conflicts:
   ```bash
   pkill -f "flask run"
   pkill -f "vite"
   ```

#### Build Failures

**Symptom:** React build fails during service installation

**Solutions:**
1. Clean and rebuild:
   ```bash
   cd frontend
   rm -rf dist
   npm run build
   ```

2. Check Node.js version:
   ```bash
   node -v  # Should be 14 or higher
   ```

3. Verify dependencies:
   ```bash
   npm install
   npm audit fix
   ```

### FAQ

#### General Questions

**Q: Can I change the port after installation?**
A: Yes, update the port in:
1. `.env` file
2. SystemD service file
3. Restart the service using service_manager.sh

**Q: How do I update the application?**
A: 
1. Stop the service
2. Pull new changes
3. Build frontend
4. Restart service
```bash
./service_manager.sh
# Stop service -> Build frontend -> Start service
```

**Q: Can I run multiple instances?**
A: Yes, by:
1. Creating new project with different name
2. Assigning different ports
3. Installing as separate service

#### Development Questions

**Q: How do I add new Python dependencies?**
A:
1. Activate virtual environment
2. Install package with pip
3. Update requirements.txt:
   ```bash
   pip freeze > requirements.txt
   ```

**Q: How do I modify the API proxy?**
A: Edit `frontend/vite.config.js`:
```javascript
proxy: {
  '/api': {
    target: 'http://localhost:5000'
  }
}
```

#### Production Questions

**Q: How do I rotate logs?**
A: SystemD handles log rotation automatically. View old logs:
```bash
journalctl -u your_project_flask_react.service
```

**Q: How do I monitor resource usage?**
A: Use service_manager.sh status or:
```bash
systemctl status your_project_flask_react.service
```

### Quick Reference

#### Common Commands
```bash
# Start development
./start_dev.sh

# Manage service
./service_manager.sh

# View logs
journalctl -u your_project_flask_react.service -f

# Check status
systemctl status your_project_flask_react.service
```

#### Important Files
```
.env                 # Environment configuration
app.py              # Flask application
frontend/           # React application
service_manager.sh  # Service management
```

#### Default Ports
- Flask Backend: 5000
- Development Frontend: 5173
- Production: Configured in service

### Getting Help

If these troubleshooting steps don't resolve your issue:

1. Check the full logs:
   ```bash
   cat /tmp/flask_react_setup.log
   ```

2. Verify system requirements:
   ```bash
   python3 --version
   node --version
   npm --version
   ```

3. Try a clean installation:
   ```bash
   rm -rf your_project
   ./generator.sh
   ```
