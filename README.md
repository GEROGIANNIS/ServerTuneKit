# 🚀 ServerTuneKit

[![GitHub Repo](https://img.shields.io/badge/GitHub-Repo-blue?style=flat&logo=github)](https://github.com/GEROGIANNIS/ServerTuneKit.git)  
A powerful and automated shell script to optimize and secure your Linux server.  

---

## 📌 Features
ServerTuneKit applies essential optimizations for performance, security, and stability:
- ✅ **System Updates & Essential Packages** (htop, curl, git, ufw, fail2ban, etc.)
- ✅ **Firewall Hardening (UFW)**
- ✅ **Fail2Ban Intrusion Prevention**
- ✅ **Automated Timezone Detection & Syncing**
- ✅ **Kernel Parameter Tuning for Better Performance**
- ✅ **Automatic Fix for /etc/hosts File**
- ✅ **Supports Ubuntu, Debian, CentOS, and Fedora**  

---

## 🛠️ Installation & Usage
### 1️⃣ Clone the Repository
```bash
git clone https://github.com/GEROGIANNIS/ServerTuneKit.git
cd ServerTuneKit
```

### 2️⃣ Make the Script Executable
```bash
chmod +x tune.sh
```

### 3️⃣ Run the Script
```bash
sudo ./tune.sh
```

---

## ⚙️ How It Works
ServerTuneKit is an interactive script that allows you to:
1. Update and upgrade system packages  
2. Install essential networking and system tools  
3. Optimize the firewall (UFW) for common ports  
4. Configure Fail2Ban to prevent brute-force attacks  
5. Sync system time using NTP  
6. Apply kernel optimizations for better performance  

Each step provides a **Yes/No** prompt, giving you control over the tuning process.

---

## 💡 Supported Operating Systems
| Distro | Supported |
|--------|----------|
| ✅ Ubuntu (20.04, 22.04) | ✔️ |
| ✅ Debian (10, 11) | ✔️ |
| ✅ CentOS (7, 8) | ✔️ |
| ✅ Fedora (36, 37) | ✔️ |


---

## 🛡️ Security & Warnings
- This script modifies system settings—**test on a non-production system first!**  
- Ensure you have a backup before applying system-wide changes.  
- Kernel tuning settings should be reviewed before applying.  

---
