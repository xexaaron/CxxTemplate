#!/usr/bin/env bash

set -e

PROJECT_NAME="CxxTemplate"
NAMESPACE="aby"
DIR="cxx_template"

usage() {
    echo "usage: $0 [-ns|--namespace <namespace>] [-d|--dir <project directory name>] [-pn|--project-name <name>] [-h|--help]"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -ns|--namespace)
            NAMESPACE="$2"
            shift 2
            ;;
        -d|--dir)
            DIR="$2"
            shift 2
            ;;
        -pn|--project-name)
            PROJECT_NAME="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# -----------------------------------------------------------------------------
# Project name
# -----------------------------------------------------------------------------

if [[ "$PROJECT_NAME" != "CxxTemplate" ]]; then
    sed -i \
        "s/project(CxxTemplate LANGUAGES CXX)/project(${PROJECT_NAME} LANGUAGES CXX)/" \
        CMakeLists.txt
fi

# -----------------------------------------------------------------------------
# Directory name
# -----------------------------------------------------------------------------

if [[ "$DIR" != "cxx_template" ]]; then
    mv cxx_template "$DIR"

    sed -i \
        "s/project(cxx_template)/project(${DIR})/" \
        "$DIR/CMakeLists.txt"

    if [[ -e ".vscode/c_cpp_properties.json" ]]; then
        sed -i \
            "s|\${workspaceFolder}/cxx_template/include|\${workspaceFolder}/${DIR}/include|g" \
            ".vscode/c_cpp_properties.json"
    fi

    sed -i \
        "s|add_subdirectory(\${CMAKE_CURRENT_SOURCE_DIR}/cxx_template)|add_subdirectory(\${CMAKE_CURRENT_SOURCE_DIR}/${DIR})|" \
        CMakeLists.txt
fi

# -----------------------------------------------------------------------------
# Namespace
# -----------------------------------------------------------------------------

if [[ "$NAMESPACE" != "aby" ]]; then
    find "$DIR" -type f \( \
        -name "*.hpp" -o \
        -name "*.h"   -o \
        -name "*.cpp" -o \
        -name "*.cc"  -o \
        -name "*.cxx" -o \
        -name "*.ipp" \
    \) -print0 | while IFS= read -r -d '' file; do
        sed -i \
            -e "s/\bnamespace[[:space:]]\+aby\b/namespace ${NAMESPACE}/g" \
            -e "s/\baby::/${NAMESPACE}::/g" \
            "$file"
    done
fi

echo "Template configured successfully."

rm -rf .git

if command -v git >/dev/null 2>&1; then
    git init
    git add .
    git commit -m "Initial commit"
fi

if command -v gh >/dev/null 2>&1; then
    read -rp "Would you like to create a new GitHub repository? (y/n): " prompt
    prompt=${prompt,,}

    if [[ "$prompt" == "y" || "$prompt" == "yes" ]]; then
        gh repo create "$PROJECT_NAME" --source=. --push
    fi
fi

rm "$0"



