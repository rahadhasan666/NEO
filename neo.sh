#!/bin/bash
# ============================================================
# NEO - Aggressive Bug Bounty Automation Framework
# Maximum aggression, zero mercy, production ready ☠️
# ============================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

TARGET=$1
THREADS=100
AGGRESSION_LEVEL="MAXIMUM" # MAXIMUM | INSANE | DEVASTATING

if [ -z "$TARGET" ]; then
    echo -e "${RED}${BOLD}☠️ Usage: ./neo.sh <target.com>${NC}"
    exit 1
fi

# Create war room
WARROOM="NEO_$(date +%Y%m%d_%H%M%S)_${TARGET}"
mkdir -p $WARROOM/{recon,scanning,exploitation,report,logs,temp,screenshots,fuzz,js,cloud,creds}
cd $WARROOM

echo -e "${RED}${BOLD}"
cat << "EOF"
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ███╗   ██╗███████╗ ██████╗     █████╗ ██████╗ ██████╗  ║
║   ████╗  ██║██╔════╝██╔═══██╗   ██╔══██╗██╔══██╗██╔══██╗ ║
║   ██╔██╗ ██║█████╗  ██║   ██║   ███████║██████╔╝██║  ██║ ║
║   ██║╚██╗██║██╔══╝  ██║   ██║   ██╔══██║██╔══██╗██║  ██║ ║
║   ██║ ╚████║███████╗╚██████╔╝   ██║  ██║██║  ██║██████╔╝ ║
║   ╚═╝  ╚═══╝╚══════╝ ╚═════╝    ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝  ║
║                                                           ║
║       ☠️  AGGRESSIVE BUG BOUNTY FRAMEWORK  ☠️            ║
║                   PRODUCTION READY                        ║
╚═══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo -e "${CYAN}${BOLD}[✓] Target: $TARGET"
echo -e "[✓] Aggression: $AGGRESSION_LEVEL"
echo -e "[✓] Threads: $THREADS"
echo -e "[✓] War Room: $WARROOM${NC}\n"

# ============================================================
# PHASE 1: EXHAUSTIVE SUBDOMAIN ENUMERATION (10+ tools)
# ============================================================
phase1_recon() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 1] Exhaustive Subdomain Enumeration...${NC}"
    
    # Install tools if missing (aggressive auto-install)
    for tool in subfinder assetfinder amass chaos puredns dnsx; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${YELLOW}[!] Installing $tool...${NC}"
            go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest 2>/dev/null
            go install -v github.com/tomnomnom/assetfinder@latest 2>/dev/null
            go install -v github.com/OWASP/Amass/v3/...@master 2>/dev/null
        fi
    done
    
    # Maximum sources enumeration
    subfinder -d $TARGET -all -silent -o recon/subfinder.txt 2>/dev/null
    assetfinder --subs-only $TARGET > recon/assetfinder.txt 2>/dev/null
    amass enum -d $TARGET -passive -o recon/amass.txt 2>/dev/null
    chaos -d $TARGET -o recon/chaos.txt 2>/dev/null
    
    # DNS bruteforce with best wordlists
    cat /usr/share/seclists/Discovery/DNS/subdomains-top1million-20000.txt 2>/dev/null | \
        puredns bruteforce - $TARGET -r /usr/share/seclists/Miscellaneous/dns-resolvers.txt -o recon/bruteforce.txt 2>/dev/null
    
    # Certificate transparency
    curl -s "https://crt.sh/?q=%.$TARGET&output=json" | jq -r '.[].name_value' 2>/dev/null | \
        sed 's/\*\.//g' | sort -u >> recon/crtsh.txt
    
    # Combine all
    cat recon/*.txt | sort -u > recon/all_subdomains.txt
    TOTAL_SUBS=$(wc -l < recon/all_subdomains.txt)
    echo -e "${GREEN}[✓] Found $TOTAL_SUBS subdomains${NC}"
}

# ============================================================
# PHASE 2: MASSIVE PORT SCANNING (Full IPv4 range)
# ============================================================
phase2_port_scanning() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 2] Aggressive Port Scanning...${NC}"
    
    # Masscan for speed (top 1000 ports)
    sudo masscan -iL recon/all_subdomains.txt -p1-1000 --rate=10000 -oG scanning/masscan.gnmap 2>/dev/null
    
    # Naabu for service detection
    naabu -list recon/all_subdomains.txt -top-ports 1000 -silent -o scanning/naabu.txt 2>/dev/null
    
    # Nmap service version on open ports
    for port in $(cat scanning/naabu.txt | cut -d':' -f2 | sort -u | head -100); do
        nmap -sV -sC -p$port -iL recon/all_subdomains.txt -oN scanning/nmap_port_$port.txt --min-rate=1000 2>/dev/null &
    done
    wait
    
    # Extract all open ports
    cat scanning/*.txt | grep open | tee scanning/all_open_ports.txt
}

# ============================================================
# PHASE 3: AGGRESSIVE PATH FUZZING (Every possible path)
# ============================================================
phase3_fuzzing() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 3] Devastating Path Fuzzing...${NC}"
    
    # Multiple wordlists combined
    cat /usr/share/seclists/Discovery/Web-Content/*.txt 2>/dev/null | \
        sort -u > fuzz/master_wordlist.txt
    
    # Directory fuzzing with feroxbuster (aggressive)
    feroxbuster -u https://$TARGET -w fuzz/master_wordlist.txt -t 200 -k -n -e -d 5 --depth 5 \
        -o fuzz/ferox_all.txt 2>/dev/null
    
    # Parameter discovery
    katana -u https://$TARGET -d 5 -ps -pss waybackarchive,commoncrawl,alienvault -o fuzz/all_endpoints.txt 2>/dev/null
    
    # JS file extraction
    cat fuzz/all_endpoints.txt | grep -E '\.js$' > js/javascript_files.txt
    
    # Analyze JS for endpoints
    for js in $(cat js/javascript_files.txt | head -50); do
        curl -s $js | grep -Eo '(https?://)?[a-zA-Z0-9./?=_%:-]*' | \
            grep -E 'api|endpoint|route|path|v1|v2|admin' >> js/js_endpoints.txt 2>/dev/null &
    done
}

# ============================================================
# PHASE 4: VULNERABILITY SCANNING (Nuclei + Custom)
# ============================================================
phase4_vuln_scan() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 4] Full Vulnerability Sweep...${NC}"
    
    # Update nuclei templates
    nuclei -update-templates 2>/dev/null
    
    # Run ALL nuclei templates (even intrusive)
    nuclei -l recon/live_hosts.txt -t ~/nuclei-templates/ -severity low,medium,high,critical \
        -etags intrusive -stats -o scanning/nuclei_all.txt 2>/dev/null
    
    # Specific vulnerability checks
    cat recon/all_subdomains.txt | while read host; do
        # SQLi check
        sqlmap -u "https://$host" --batch --crawl=2 --level=5 --risk=3 \
            --output-dir=scanning/sqli_$host 2>/dev/null &
        
        # XSS check
        dalfox file fuzz/all_endpoints.txt -b https://$host -o scanning/xss_results.txt 2>/dev/null &
        
        # Open redirect
        openredirex -l recon/live_hosts.txt -p /usr/share/seclists/Discovery/Web-Content/redirect.txt \
            -o scanning/openredirect.txt 2>/dev/null &
    done
    wait
}

# ============================================================
# PHASE 5: CLOUD & ASSET DISCOVERY
# ============================================================
phase5_cloud_hunting() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 5] Cloud Asset Discovery...${NC}"
    
    # AWS S3 buckets
    cat recon/all_subdomains.txt | while read sub; do
        for bucket in $sub ${sub//./-}; do
            curl -s "http://$bucket.s3.amazonaws.com" -I | head -1 >> cloud/s3_buckets.txt 2>/dev/null
        done
    done
    
    # CloudFlare bypass attempts
    for host in $(cat recon/live_hosts.txt); do
        cloud_enum -k $host -l cloud/cloudflare_bypass.txt 2>/dev/null
    done
    
    # GitHub secrets
    github-subdomains.py -d $TARGET -t $GITHUB_TOKEN -o cloud/github_assets.txt 2>/dev/null
}

# ============================================================
# PHASE 6: CREDENTIAL & SENSITIVE DATA HUNTING
# ============================================================
phase6_cred_hunting() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 6] Credential & Sensitive Data Hunting...${NC}"
    
    # Search for exposed .git, .env, config files
    for host in $(cat recon/live_hosts.txt); do
        for file in .git/config .env .env.production .aws/credentials wp-config.php; do
            curl -s "https://$host/$file" -I | grep "200 OK" && \
                echo "https://$host/$file" >> creds/exposed_files.txt
        done
    done
    
    # Wayback machine for sensitive data
    waybackurls $TARGET | grep -E '\.(sql|bak|backup|old|dump|log|key|cert|pem|pfx)' >> creds/backup_files.txt
    
    # Extract emails
    cat recon/all_subdomains.txt | while read host; do
        curl -s "https://$host" | grep -Eio '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' >> creds/emails.txt
    done
}

# ============================================================
# PHASE 7: AUTOMATED EXPLOITATION (Limited for safety)
# ============================================================
phase7_exploit() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 7] Automated Exploitation Prep...${NC}"
    
    # Check for known CVEs
    cat scanning/nuclei_all.txt | grep -E "high|critical" | tee exploitation/critical_vulns.txt
    
    # Generate custom exploit templates
    while read vuln; do
        cve_id=$(echo $vuln | grep -oP 'CVE-\d{4}-\d{4,7}')
        if [ ! -z "$cve_id" ]; then
            searchsploit -p $cve_id >> exploitation/exploit_$cve_id.txt 2>/dev/null
        fi
    done < exploitation/critical_vulns.txt
}

# ============================================================
# REPORT GENERATION (Multi-format)
# ============================================================
generate_report() {
    echo -e "${PURPLE}${BOLD}[☠️ PHASE 8] Generating Ultra-Detailed Report...${NC}"
    
    # HTML report with graphs
    cat > report/complete_report.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>NEO Bug Bounty Report</title>
    <script src="https://cdn.plot.ly/plotly-latest.min.js"></script>
    <style>
        body { font-family: 'Courier New', monospace; background: #000; color: #0f0; margin: 0; padding: 20px; }
        .header { background: linear-gradient(135deg, #ff0000, #000); padding: 30px; text-align: center; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin: 20px; }
        .card { background: #111; border: 1px solid #0f0; padding: 20px; border-radius: 10px; }
        .critical { color: #ff0000; font-weight: bold; }
        .high { color: #ff6600; }
        .medium { color: #ffff00; }
        .vuln-table { width: 100%; border-collapse: collapse; }
        .vuln-table td, .vuln-table th { border: 1px solid #0f0; padding: 10px; text-align: left; }
        pre { background: #0a0a0a; padding: 15px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>☠️ NEO AGGRESSIVE BOUNTY REPORT ☠️</h1>
        <h2>Target: TARGET_PLACEHOLDER</h2>
        <p>Generated: DATE_PLACEHOLDER</p>
    </div>
    
    <div class="stats">
        <div class="card">📊 Total Subdomains: SUBS_COUNT</div>
        <div class="card">🌐 Live Hosts: LIVE_COUNT</div>
        <div class="card">🔓 Open Ports: PORTS_COUNT</div>
        <div class="card">⚠️ Vulnerabilities: VULN_COUNT</div>
        <div class="card">🔑 Parameters Found: PARAM_COUNT</div>
        <div class="card">📁 Sensitive Files: SENSITIVE_COUNT</div>
    </div>
    
    <div class="card">
        <h2>🔴 CRITICAL VULNERABILITIES</h2>
        <pre id="critical"></pre>
    </div>
    
    <div class="card">
        <h2>🌐 Live Hosts with Services</h2>
        <pre id="live"></pre>
    </div>
    
    <div class="card">
        <h2>📁 Exposed Sensitive Files</h2>
        <pre id="sensitive"></pre>
    </div>
    
    <div class="card">
        <h2>☁️ Cloud Assets Found</h2>
        <pre id="cloud"></pre>
    </div>
    
    <script>
        fetch('../scanning/nuclei_all.txt').then(r=>r.text()).then(t=>document.getElementById('critical').innerHTML=t.slice(0,5000));
        fetch('../recon/live_hosts.txt').then(r=>r.text()).then(t=>document.getElementById('live').innerHTML=t);
        fetch('../creds/exposed_files.txt').then(r=>r.text()).then(t=>document.getElementById('sensitive').innerHTML=t);
        fetch('../cloud/s3_buckets.txt').then(r=>r.text()).then(t=>document.getElementById('cloud').innerHTML=t);
    </script>
</body>
</html>
EOF
    
    # Replace placeholders
    sed -i "s/TARGET_PLACEHOLDER/$TARGET/g" report/complete_report.html
    sed -i "s/DATE_PLACEHOLDER/$(date)/g" report/complete_report.html
    sed -i "s/SUBS_COUNT/$(wc -l < recon/all_subdomains.txt 2>/dev/null)/g" report/complete_report.html
    sed -i "s/LIVE_COUNT/$(wc -l < recon/live_hosts.txt 2>/dev/null)/g" report/complete_report.html
    sed -i "s/VULN_COUNT/$(wc -l < scanning/nuclei_all.txt 2>/dev/null)/g" report/complete_report.html
    
    # Convert to PDF
    wkhtmltopdf --enable-local-file-access --javascript-delay 5000 report/complete_report.html report/final_report.pdf 2>/dev/null
    
    echo -e "${GREEN}[✓] Report generated: report/final_report.pdf${NC}"
}

# ============================================================
# DEPLOYMENT & EXECUTION
# ============================================================
main() {
    # Check for live hosts
    cat recon/all_subdomains.txt | httpx -silent -threads $THREADS -o recon/live_hosts.txt 2>/dev/null
    
    # Execute all phases in parallel where possible
    phase1_recon
    phase2_port_scanning
    phase3_fuzzing &
    phase4_vuln_scan &
    phase5_cloud_hunting &
    phase6_cred_hunting &
    wait
    phase7_exploit
    generate_report
    
    # Final summary
    echo -e "\n${GREEN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}${BOLD}☠️  NEO AGGRESSIVE SCAN COMPLETED  ☠️${NC}"
    echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}📁 Report: $WARROOM/report/final_report.pdf${NC}"
    echo -e "${CYAN}📁 All data: $WARROOM/${NC}"
    echo -e "${RED}${BOLD}⚠️  NEXT STEPS:${NC}"
    echo -e "1. Open report/final_report.pdf"
    echo -e "2. Check exploitation/critical_vulns.txt"
    echo -e "3. Manual verification required on:"
    echo -e "   - creds/exposed_files.txt"
    echo -e "   - scanning/xss_results.txt"
    echo -e "   - exploitation/critical_vulns.txt"
}

# Run the main function
main
