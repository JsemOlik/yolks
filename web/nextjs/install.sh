#!/bin/ash
# Next.js Installation Script
#
# Server Files: /mnt/server

# Install git if not available (for alpine-based containers)
if ! command -v git > /dev/null 2>&1; then
    echo "Installing git..."
    apk add --no-cache git || {
        echo "Error: Failed to install git. Please ensure the installation container supports apk package manager."
        exit 1
    }
fi

# Change to server directory
cd /mnt/server || {
    echo "Error: Failed to change to /mnt/server directory."
    exit 1
}

if [ -z "${GIT_REPOSITORY}" ]; then
    echo "Error: GIT_REPOSITORY variable is not set."
    echo "Please provide a Git repository URL in the server variables."
    exit 1
fi

# Remove existing files if they exist (except node_modules to speed up reinstall)
if [ -d ".git" ]; then
    echo "Removing existing Git repository..."
    rm -rf .git
fi

if [ -f "package.json" ] && [ ! -d "node_modules" ]; then
    echo "Keeping existing package.json for fresh install..."
fi

# Clone the repository
echo "Cloning repository: ${GIT_REPOSITORY}"

# Extract branch if specified in GIT_BRANCH variable, default to main/master
GIT_BRANCH=${GIT_BRANCH:-main}

# Try main branch first, fallback to master if main doesn't exist
if git ls-remote --heads --exit-code ${GIT_REPOSITORY} main > /dev/null 2>&1; then
    DEFAULT_BRANCH="main"
elif git ls-remote --heads --exit-code ${GIT_REPOSITORY} master > /dev/null 2>&1; then
    DEFAULT_BRANCH="master"
else
    DEFAULT_BRANCH="main"
fi

# Use GIT_BRANCH if set, otherwise use default
BRANCH=${GIT_BRANCH:-${DEFAULT_BRANCH}}

echo "Cloning branch: ${BRANCH}"

# Clone with depth 1 for faster cloning
if ! git clone --depth 1 --branch ${BRANCH} ${GIT_REPOSITORY} . 2>&1; then
    echo "Failed to clone branch ${BRANCH}, trying default branch..."
    if ! git clone --depth 1 ${GIT_REPOSITORY} . 2>&1; then
        echo "Error: Failed to clone repository ${GIT_REPOSITORY}"
        exit 1
    fi
fi

if [ ! -f "package.json" ]; then
    echo "Error: package.json not found in repository."
    echo "Please ensure your repository contains a valid Next.js application."
    exit 1
fi

echo "Repository cloned successfully!"
echo "Next.js application is ready for building and starting."

