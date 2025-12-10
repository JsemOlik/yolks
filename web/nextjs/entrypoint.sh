#!/bin/ash

cd /home/container || exit

if [ ! -f "package.json" ]; then
    echo "No package.json found. Please ensure your server files are uploaded."
    exit 1
fi

# Set default NODE_ENV if not provided
export NODE_ENV=${NODE_ENV:-production}

# Set PORT - use PORT variable if set, otherwise use SERVER_PORT from Pterodactyl, default to 3000
export PORT=${PORT:-${SERVER_PORT:-3000}}

# Install dependencies if node_modules doesn't exist or package.json is newer
if [ ! -d "node_modules" ] || [ "package.json" -nt "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Build the Next.js application
if [ -f "package.json" ] && grep -q "\"build\"" package.json; then
    echo "Building Next.js application..."
    npm run build
fi

# Start the Next.js application
echo "Starting Next.js application..."
echo "NODE_ENV: ${NODE_ENV}"
echo "PORT: ${PORT}"
exec npm start

