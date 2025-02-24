#!/bin/bash

detect_os() {
    if grep -qi "ubuntu" /etc/os-release; then
        OS="debian"
        print_yellow "Detected OS: Ubuntu/Debian-based"
    elif grep -qi "debian" /etc/os-release; then
        OS="debian"
        print_yellow "Detected OS: Debian"
    elif grep -qi "centos" /etc/os-release; then
        OS="rhel"
        print_yellow "Detected OS: CentOS"
    elif grep -qi "fedora" /etc/os-release; then
        OS="rhel"
        print_yellow "Detected OS: Fedora"
    else
        print_red "Unknown OS. Some features may not work correctly."
        OS="unknown"
    fi
    echo
}