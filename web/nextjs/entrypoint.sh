#!/bin/ash

cd /mnt/server || exit

if [ ! -f "package.json" ]; then
    echo "No package.json found. Please ensure your server files are uploaded."
    exit 1
fi

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
exec npm start

