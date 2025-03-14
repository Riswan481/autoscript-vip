
# Konfigurasi warna
export NC='\e[0m'
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export yl='\033[0;33m'
export WH='\033[1;37m'
colornow=$(cat /etc/rmbl/theme/color.conf)
export COLOR1="$(grep -w "TEXT" /etc/rmbl/theme/$colornow | cut -d: -f2 | tr -d ' ')"
export COLBG1="$(grep -w "BG" /etc/rmbl/theme/$colornow | cut -d: -f2 | tr -d ' ')"

# Informasi sistem
MYIP=$(curl -s ifconfig.me)
tram=$(free -h | awk '/Mem:/ {print $2}')
uram=$(free -h | awk '/Mem:/ {print $3}')
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)

# Fungsi utama
check_license() {
    local data_ip="https://raw.githubusercontent.com/Riswan481/permission/main/ip"
    local exp_date=$(curl -sS $data_ip | grep $MYIP | awk '{print $3}')
    local server_date=$(date +%Y-%m-%d)
    
    if [[ $server_date > $exp_date ]]; then
        systemctl stop nginx
        clear
        echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}"
        echo -e "$COLOR1│${NC}${COLBG1} ${WH}• AUTOSCRIPT PREMIUM •${NC}                          $COLOR1│"
        echo -e "$COLOR1│${RED}           PERMISSION DENIED !${NC}                    │"
        echo -e "$COLOR1│   ${yl}IP:${NC} $MYIP \033[0;36mTelah Diblokir${NC}             │"
        echo -e "$COLOR1│        ${yl}Hubungi Admin untuk Akses${NC}              │"
        echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
        exit 1
    fi
}

init_directories() {
    local dirs=(
        /etc/per /etc/perlogin /etc/xray/sshx
        /etc/vmess /etc/vless /etc/trojan
        /etc/trojan-go /usr/bin
    )
    
    for dir in "${dirs[@]}"; do
        [[ ! -d $dir ]] && mkdir -p $dir
    done
    
    touch {/etc/per/id,/etc/per/token,/etc/perlogin/id,/etc/perlogin/token,/usr/bin/idchat}
}

get_network_stats() {
    local profile=$(vnstat | sed -n '3p' | awk '{print $1}')
    local today=$(vnstat -i $profile | awk '/today/{print $8" "$9}')
    local month=$(vnstat -i $profile | awk -v m=$(date +%b) '$0 ~ m {print $9" "$10}')
    
    echo -e " [${COLOR1}📊${NC}] Traffic Hari Ini: ${COLOR1}$today${NC}"
    echo -e " [${COLOR1}📈${NC}] Traffic Bulan Ini: ${COLOR1}$month${NC}"
}

service_status() {
    local service=$1
    local status=$(systemctl is-active $service)
    
    case $status in
        active) echo -e "${COLOR1}ON${NC}" ;;
        *) echo -e "${RED}OFF${NC}" ;;
    esac
}

# Eksekusi utama
clear
check_license
init_directories

# Status layanan
echo -e "\n [${COLOR1}🛠️${NC}] Status Layanan:"
echo -e " - NGINX    : $(service_status nginx)"
echo -e " - Xray     : $(service_status xray)"
echo -e " - Dropbear : $(service_status dropbear)"
echo -e " - Trojan-Go: $(service_status trojan-go)"

# Statistik pengguna
echo -e "\n [${COLOR1}👥${NC}] Statistik Pengguna:"
echo -e " - SSH    : ${COLOR1}$(grep -c '^### ' /etc/xray/ssh)${NC}"
echo -e " - VMess  : ${COLOR1}$(grep -c '^#vmg ' /etc/xray/config.json)${NC}"
echo -e " - VLess  : ${COLOR1}$(grep -c '^#vlg ' /etc/xray/config.json)${NC}"

get_network_stats
