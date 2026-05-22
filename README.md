# ☠️ NEO - Aggressive Bug Bounty Automation Framework

<p align="center">
  <img src="https://img.shields.io/badge/Version-3.0.0-red.svg">
  <img src="https://img.shields.io/badge/Kali-Linux-blue.svg">
  <img src="https://img.shields.io/badge/License-MIT-green.svg">
  <img src="https://img.shields.io/badge/Bug%20Bounty-Ready-brightgreen.svg">
  <img src="https://img.shields.io/badge/PRs-Welcome-orange.svg">
</p>

<p align="center">
  <b>🔥 The Most Aggressive Bug Bounty Automation Framework Ever Created 🔥</b><br>
  <i>Zero Mercy | Maximum Speed | Production Ready | World's Best</i>
</p>

---

# 📦 Installation + Setup + Run

## 🖥️ Virtual Environment Create (Recomended)

```bash
python3 -m venv bug
source bug/bin/activate
```

---

## 1️⃣ Clone Repository

```bash
git clone https://github.com/rahadhasan666/NEO.git
cd NEO
```

---

## 2️⃣ Update System

```bash
sudo apt update && sudo apt full-upgrade -y
```

---

## 3️⃣ Install System Dependencies

```bash
sudo apt install -y masscan feroxbuster jq wkhtmltopdf nmap curl wget git make gcc chromium dnsrecon dnsenum dirb whatweb seclists python3 python3-pip golang-go libpcap-dev build-essential
```

---

## 4️⃣ Install Go Tools

```bash
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

go install -v github.com/tomnomnom/assetfinder@latest

go install -v github.com/OWASP/Amass/v3/...@master

go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest

go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

go install -v github.com/tomnomnom/waybackurls@latest

go install -v github.com/hahwul/dalfox/v2@latest

go install -v github.com/projectdiscovery/katana/cmd/katana@latest

go install -v github.com/projectdiscovery/puredns@latest

go install -v github.com/tomnomnom/gf@latest

go install -v github.com/lc/gau/v2/cmd/gau@latest

go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
```

---

## 5️⃣ Install Python Tools

```bash
pip3 install cloud_enum github-subdomains truffleHog
```

---

## 6️⃣ Install Wordlists

```bash
sudo mkdir -p /usr/share/wordlists

sudo wget https://raw.githubusercontent.com/danielmiessler/SecLists/master/Discovery/DNS/subdomains-top1million-20000.txt \
-O /usr/share/wordlists/subdomains.txt
```

---

## 7️⃣ Configure PATH

```bash
echo 'export PATH=$PATH:~/go/bin' >> ~/.bashrc

source ~/.bashrc
```

---

## 8️⃣ Download Nuclei Templates

```bash
nuclei -update-templates
```

---

## 9️⃣ Create NEO Directory

```bash
sudo mkdir -p /opt/neo

cd /opt/neo
```

---

# 🚀 Add Script

## Create Script File

```bash
nano neo.sh
```

Paste your full `neo.sh` script inside nano editor.

Save using:

```bash
CTRL + X
Y
ENTER
```

---

# ⚡ Make Executable

```bash
chmod +x neo.sh
```

---

# ☠️ Run NEO

## Basic Scan

```bash
./neo.sh example.com
```

---

## Run With Root (Recommended)

```bash
sudo ./neo.sh example.com
```

---

# 📁 Example

```bash
sudo ./neo.sh target.com
```

Generated Output:

```text
NEO_20260522_120000_target.com/
```

---

# 📊 Output Structure

```text
NEO_YYYYMMDD_HHMMSS_target/

├── recon/
├── scanning/
├── exploitation/
├── report/
├── logs/
├── temp/
├── screenshots/
├── fuzz/
├── js/
├── cloud/
└── creds/
```

---

# 📄 Final Report

```text
report/final_report.pdf
```

---

# ⚠️ Legal Disclaimer

This framework is intended strictly for:

- Authorized penetration testing
- Bug bounty programs
- Personal lab environments
- Educational purposes

Unauthorized usage against systems without permission may violate laws and regulations.

Use responsibly.
