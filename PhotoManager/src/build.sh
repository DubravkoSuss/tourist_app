#!/bin/bash

# Photo Manager Application Build Script

echo "================================"
echo "Photo Manager - Build Script"
echo "================================"
echo ""

# Check if Java is installed
if ! command -v javac &> /dev/null; then
    echo "Error: Java JDK is not installed or not in PATH"
    echo "Please install Java JDK 8 or higher"
    exit 1
fi

echo "Java version:"
java -version
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
rm -f *.class
echo "Done."
echo ""

# Compile all Java files
echo "Compiling Java files..."
javac *.java

if [ $? -eq 0 ]; then
    echo "Compilation successful!"
    echo ""
    
    # Ask user if they want to run the application
    read -p "Do you want to run the application now? (y/n): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Starting Photo Manager Application..."
        echo "================================"
        echo ""
        java PhotoManagerApp
    else
        echo "To run the application later, use: java PhotoManagerApp"
    fi
else
    echo "Compilation failed. Please check the errors above."
    exit 1
fi
