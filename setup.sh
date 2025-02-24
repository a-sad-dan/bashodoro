#!/bin/bash

# Define project structure
folders=("bin" "config" "logs" "tests")
files=(
    "bin/bashodoro.sh"
    "bin/timer.sh"
    "bin/notify.sh"
    "bin/session.sh"
    "config/settings.conf"
    "logs/bashodoro.log"
    "tests/test_timer.sh"
    "tests/test_notify.sh"
    "README.md"
    "setup.sh"
    "uninstall.sh"
    ".gitignore"
)

# Create folders
echo "📂 Creating folders..."
for folder in "${folders[@]}"; do
    mkdir -p "$folder"
    echo "✔️  Created $folder/"
done

# Create files with placeholders
echo "📄 Creating files..."
for file in "${files[@]}"; do
    if [[ ! -f "$file" ]]; then
        touch "$file"
        echo "✔️  Created $file"
    else
        echo "⚠️  $file already exists, skipping."
    fi
done

# Set executable permissions for scripts
echo "🔧 Setting executable permissions for scripts..."
chmod +x bin/*.sh setup.sh uninstall.sh

# Default content for README.md
cat << EOF > README.md
# Bashodoro

A Bash script implementing the Pomodoro Technique.

## 📌 Features
- Customizable work and break sessions
- Notifications and progress tracking
- Session logging

## 🚀 Usage
Run the main script:
\`\`\`bash
./bin/bashodoro.sh
\`\`\`
EOF

# Default content for .gitignore
cat << EOF > .gitignore
logs/*
EOF

echo "🎉 Setup complete! Your Bashodoro project is ready."
