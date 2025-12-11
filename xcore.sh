#!/usr/bin/env bash

###################################
### GLOBAL CONSTANTS AND VARIABLES
###################################

DIR_XCORE="/opt/xcore"

###################################
### INITIALIZATION AND DECLARATIONS
###################################
declare -A defaults
declare -A args
declare -A regex
declare -A generate

###################################
### REGEX PATTERNS FOR VALIDATION
###################################
regex[domain]="^([a-zA-Z0-9-]+)\.([a-zA-Z0-9-]+\.[a-zA-Z]{2,})$"
regex[port]="^[1-9][0-9]*$"
regex[username]="^[a-zA-Z0-9]+$"
regex[ipv4]="^([0-9]{1,3}\.){3}[0-9]{1,3}$"
regex[tgbot_token]="^[0-9]{8,10}:[a-zA-Z0-9_-]{35}$"
regex[tgbot_admins]="^[a-zA-Z][a-zA-Z0-9_]{4,31}(,[a-zA-Z][a-zA-Z0-9_]{4,31})*$"
regex[domain_port]="^[a-zA-Z0-9]+([-.][a-zA-Z0-9]+)*\.[a-zA-Z]{2,}(:[1-9][0-9]*)?$"
regex[file_path]="^[a-zA-Z0-9_/.-]+$"
regex[url]="^(http|https)://([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})(:[0-9]{1,5})?(/.*)?$"
generate[path]="tr -dc 'A-Za-z0-9' < /dev/urandom | head -c 30"

###################################
### OUTPUT FORMATTING FUNCTIONS
###################################
out_data()   { echo -e "\e[1;33m$1\033[0m \033[1;37m$2\033[0m"; }
tilda()      { echo -e "\033[31m\033[38;5;214m$*\033[0m"; }
warning()    { echo -e "\033[31m [!]\033[38;5;214m$*\033[0m"; }
error()      { echo -e "\033[31m\033[01m$*\033[0m"; exit 1; }
info()       { echo -e "\033[32m\033[01m$*\033[0m"; }
question()   { echo -e "\033[32m[?]\e[1;33m$*\033[0m"; }
hint()       { echo -e "\033[33m\033[01m$*\033[0m"; }
reading()    { read -rp " $(question "$1")" "$2"; }
text()       { eval echo "\${${LANGUAGE}[$*]}"; }
text_eval()  { eval echo "\$(eval echo "\${${LANGUAGE}[$*]}")"; }

###################################
### LANGUAGE STRINGS
###################################
EU[1]="Choose an action:"
RU[1]="Выбери действие:"
EU[3]="Unable to determine IP address."
RU[3]="Не удалось определить IP-адрес."
EU[4]="Reinstalling script..."
RU[4]="Повторная установка скрипта..."
EU[5]="WARNING!"
RU[5]="ВНИМАНИЕ!"
EU[6]="It is recommended to perform the following actions before running the script"
RU[6]="Перед запуском скрипта рекомендуется выполнить следующие действия"

EU[9]="CANCEL"
RU[9]="ОТМЕНА"
EU[10]="\n|--------------------------------------------------------------------------|\n"
RU[10]="\n|--------------------------------------------------------------------------|\n"
EU[11]="Enter username:"
RU[11]="Введите имя пользователя:"
EU[12]="Enter user password:"
RU[12]="Введите пароль пользователя:"

EU[21]="Access link to node exporter:"
RU[21]="Доступ по ссылке к node exporter:"
EU[22]="Access link to shell in a box:"
RU[22]="Доступ по ссылке к shell in a box:"
EU[24]="Enter Node Exporter path:"
RU[24]="Введите путь к Node Exporter:"

EU[33]="Error: invalid choice, please try again."
RU[33]="Ошибка: неверный выбор, попробуйте снова."

EU[36]="Updating system and installing necessary packages."
RU[36]="Обновление системы и установка необходимых пакетов."
EU[38]="Download failed, retrying..."
RU[38]="Скачивание не удалось, пробуем снова..."
EU[41]="Enabling BBR."
RU[41]="Включение BBR."
EU[42]="Disabling IPv6."
RU[42]="Отключение IPv6."
EU[47]="Configuring UFW."
RU[47]="Настройка UFW."
EU[48]="Configuring SSH."
RU[48]="Настройка SSH."
EU[49]="Generate a key for your OS (ssh-keygen)."
RU[49]="Сгенерируйте ключ для своей ОС (ssh-keygen)."
EU[50]="In Windows, install the openSSH package and enter the command in PowerShell (recommended to research key generation online)."
RU[50]="В Windows нужно установить пакет openSSH и ввести команду в PowerShell (рекомендуется изучить генерацию ключей в интернете)."
EU[51]="If you are on Linux, you probably know what to do C:"
RU[51]="Если у вас Linux, то вы сами все умеете C:"
EU[52]="Command for Windows:"
RU[52]="Команда для Windows:"
EU[53]="Command for Linux:"
RU[53]="Команда для Linux:"
EU[54]="Configure SSH (optional step)? [y/N]:"
RU[54]="Настроить SSH (необязательный шаг)? [y/N]:"
EU[55]="Error: Keys not found. Please add them to the server before retrying..."
RU[55]="Ошибка: ключи не найдены, добавьте его на сервер, прежде чем повторить..."
EU[56]="Key found, proceeding with SSH setup."
RU[56]="Ключ найден, настройка SSH."
EU[57]="Client-side configuration."
RU[57]="Настройка клиентской части."
EU[58]="SAVE THIS SCREEN!"
RU[58]="СОХРАНИ ЭТОТ ЭКРАН!"
EU[59]="Subscription page link:"
RU[59]="Ссылка на страницу подписки:"

EU[62]="SSH connection:"
RU[62]="Подключение по SSH:"
EU[63]="Username:"
RU[63]="Имя пользователя:"
EU[64]="Password:"
RU[64]="Пароль:"
EU[65]="Log file path:"
RU[65]="Путь к лог файлу:"
EU[66]="Prometheus monitor."
RU[66]="Мониторинг Prometheus."

EU[71]="Current operating system is \$SYS.\\\n The system lower than \$SYSTEM \${MAJOR[int]} is not supported. Feedback: [https://github.com/cortez24rus/xcore/issues]"
RU[71]="Текущая операционная система: \$SYS.\\\n Система с версией ниже, чем \$SYSTEM \${MAJOR[int]}, не поддерживается. Обратная связь: [https://github.com/cortez24rus/xcore/issues]"
EU[72]="Install dependence-list:"
RU[72]="Список зависимостей для установки:"
EU[73]="All dependencies already exist and do not need to be installed additionally."
RU[73]="Все зависимости уже установлены и не требуют дополнительной установки."
EU[74]="OS - $SYS"
RU[74]="OS - $SYS"
EU[75]="Invalid option for --$key: $value. Use 'true' or 'false'."
RU[75]="Неверная опция для --$key: $value. Используйте 'true' или 'false'."
EU[76]="Unknown option: $1"
RU[76]="Неверная опция: $1"
EU[77]="List of dependencies for installation:"
RU[77]="Список зависимостей для установки:"
EU[78]="All dependencies are already installed and do not require additional installation."
RU[78]="Все зависимости уже установлены и не требуют дополнительной установки."
EU[79]="Configuring site template."
RU[79]="Настройка шаблона сайта."
EU[80]="Random template name:"
RU[80]="Случайное имя шаблона:"
EU[81]="Enter your domain CNAME record:"
RU[81]="Введите доменную запись типа CNAME:"
EU[82]="Enter Shell in a box path:"
RU[82]="Введите путь к Shell in a box:"
EU[83]="Terminal emulator Shell in a box."
RU[83]="Эмулятор терминала Shell in a box."

EU[84]="0. Previous menu"
RU[84]="0. Предыдущее меню"
EU[85]="Press Enter to return to the menu..."
RU[85]="Нажмите Enter, чтобы вернуться в меню..."
EU[86]="X Core $VERSION_MANAGER"
RU[86]="X Core $VERSION_MANAGER"
EU[87]="1. Perform standard installation"
RU[87]="1. Выполнить стандартную установку"
EU[91]="5. Copy website to server"
RU[91]="5. Скопировать веб-сайт на сервер"

EU[117]="1. Add server chain for routing"
RU[117]="1. Добавить цепочку серверов для маршрутизации"
EU[118]="2. Remove server chain from configuration"
RU[118]="2. Удалить цепочку серверов из конфигурации"
EU[119]="Error adding server chain. Configuration update skipped."
RU[119]="Ошибка при добавлении цепочки серверов. Обновление конфигурации пропущено."

EU[129]="10. Synchronize client subscription configurations"
RU[129]="10. Синхронизировать конфигурации клиентских подписок"
EU[130]="11. Configure server chain"
RU[130]="11. Настроить цепочку серверов"
EU[131]="Enter 0 to exit (updates every 10 seconds): "
RU[131]="Введите 0 для выхода (обновление каждые 10 секунд): "

###################################
### HELP MESSAGE DISPLAY
###################################
display_help_message() {
  echo
  echo "Usage: xcore [-b|--bbr <true|false>] [-i|--ipv6 <true|false>] [-m|--mon <true|false>]"
  echo "         [-l|--shell <true|false>] [-f|--firewall <true|false>] [-s|--ssh <true|false>] [-h|--help]"
  echo
  echo "  -b, --bbr <true|false>         BBR (TCP Congestion Control)                     (default: ${defaults[bbr]})"
  echo "                                 BBR (управление перегрузкой TCP)"
  echo "  -i, --ipv6 <true|false>        Disable IPv6 support                             (default: ${defaults[ipv6]})"
  echo "                                 Отключить поддержку IPv6 "
  echo "  -m, --mon <true|false>         Monitoring services (node_exporter)              (default: ${defaults[mon]})"
  echo "                                 Сервисы мониторинга (node_exporter)"
  echo "  -l, --shell <true|false>       Shell In A Box installation                      (default: ${defaults[shell]})"
  echo "                                 Установка Shell In A Box"
  echo "  -f, --firewall <true|false>    Firewall configuration                           (default: ${defaults[firewall]})"
  echo "                                 Настройка файрвола"
  echo "  -s, --ssh <true|false>         SSH access                                       (default: ${defaults[ssh]})"
  echo "                                 SSH доступ"
  echo "  -h, --help                     Display this help message"
  echo "                                 Показать это сообщение помощи"
  echo
  exit 0
}

###################################
### LOAD DEFAULTS FROM CONFIG FILE
###################################
load_defaults_from_config() {
  if [[ -f "${DIR_XCORE}/default.conf" ]]; then
    # Чтение и выполнение строк из файла
    while IFS= read -r line; do
      # Пропускаем пустые строки и комментарии
      [[ -z "$line" || "$line" =~ ^# ]] && continue
      eval "$line"
    done < "${DIR_XCORE}/default.conf"
  else
    # Если файл не найден, используем значения по умолчанию
    defaults[bbr]=true
    defaults[ipv6]=true
    defaults[mon]=true
    defaults[shell]=true
    defaults[firewall]=true
    defaults[ssh]=true
  fi
}

###################################
### SAVE DEFAULTS TO CONFIG FILE
###################################
save_defaults_to_config() {
  cat > "${DIR_XCORE}/default.conf"<<EOF
defaults[bbr]=false
defaults[ipv6]=false
defaults[mon]=false
defaults[shell]=false
defaults[firewall]=false
defaults[ssh]=false
EOF
}

###################################
### NORMALIZE CASE FOR ARGUMENTS
###################################
normalize_argument_case() {
  local key=$1
  args[$key]="${args[$key],,}"
}

###################################
### VALIDATE BOOLEAN VALUES
###################################
validate_boolean_value() {
  local key=$1
  local value=$2
  case ${value} in
    true)
      args[$key]=true
      ;;
    false)
      args[$key]=false
      ;;
    *)
      warning " $(text 75) "
      return 1
      ;;
  esac
}

###################################
### PARSE COMMAND-LINE ARGUMENTS
###################################
declare -A arg_map=(
  [-b]=bbr        [--bbr]=bbr
  [-i]=ipv6       [--ipv6]=ipv6
  [-m]=mon        [--mon]=mon
  [-l]=shell      [--shell]=shell
  [-f]=firewall   [--firewall]=firewall
  [-s]=ssh        [--ssh]=ssh
)

parse_command_line_args() {
  local opts
  opts=$(getopt -o b:i:m:l:f:s: --long bbr:,ipv6:,mon:,shell:,firewall:,ssh:,help -- "$@")

  if [[ $? -ne 0 ]]; then
    return 1
  fi

  eval set -- "$opts"
  while true; do
    case $1 in
      -h|--help)
        return 1
        ;;
      --)
        shift
        break
        ;;
      *)
        if [[ -n "${arg_map[$1]}" ]]; then
          local key="${arg_map[$1]}"
          args[$key]="$2"
          normalize_argument_case "$key"
          validate_boolean_value "$key" "$2" || return 1
          shift 2
          continue
        fi
        warning " $(text 76) "
        return 1
        ;;
    esac
  done

  for key in "${!defaults[@]}"; do
    if [[ -z "${args[$key]}" ]]; then
      args[$key]=${defaults[$key]}
    fi
  done
}

###################################
### OPERATING SYSTEM DETECTION
###################################
detect_operating_system() {
  if [ -s /etc/os-release ]; then
    SYS="$(grep -i pretty_name /etc/os-release | cut -d \" -f2)"
  elif [ -x "$(type -p hostnamectl)" ]; then
    SYS="$(hostnamectl | grep -i system | cut -d : -f2)"
  elif [ -x "$(type -p lsb_release)" ]; then
    SYS="$(lsb_release -sd)"
  elif [ -s /etc/lsb-release ]; then
    SYS="$(grep -i description /etc/lsb-release | cut -d \" -f2)"
  elif [ -s /etc/redhat-release ]; then
    SYS="$(grep . /etc/redhat-release)"
  elif [ -s /etc/issue ]; then
    SYS="$(grep . /etc/issue | cut -d '\' -f1 | sed '/^[ ]*$/d')"
  fi

  REGEX=("debian" "ubuntu" "centos|red hat|kernel|alma|rocky")
  RELEASE=("Debian" "Ubuntu" "CentOS")
  EXCLUDE=("---")
  MAJOR=("10" "20" "7")
  PACKAGE_UPDATE=("apt -y update" "apt -y update" "yum -y update --skip-broken")
  PACKAGE_INSTALL=("apt -y install" "apt -y install" "yum -y install")
  PACKAGE_UNINSTALL=("apt -y autoremove" "apt -y autoremove" "yum -y autoremove")

  for int in "${!REGEX[@]}"; do
    [[ "${SYS,,}" =~ ${REGEX[int]} ]] && SYSTEM="${RELEASE[int]}" && break
  done

  # Проверка на кастомизированные системы от различных производителей
  if [ -z "$SYSTEM" ]; then
    [ -x "$(type -p yum)" ] && int=2 && SYSTEM='CentOS' || error " $(text 5) "
  fi

  # Определение основной версии Linux
  MAJOR_VERSION=$(sed "s/[^0-9.]//g" <<< "$SYS" | cut -d. -f1)

  # Сначала исключаем системы, указанные в EXCLUDE, затем для оставшихся делаем сравнение по основной версии
  for ex in "${EXCLUDE[@]}"; do [[ ! "${SYS,,}" =~ $ex ]]; done &&
  [[ "$MAJOR_VERSION" -lt "${MAJOR[int]}" ]] && error " $(text 71) "
}

###################################
### DEPENDENCY CHECK AND INSTALLATION
###################################
install_dependencies() {
  # Зависимости, необходимые для трех основных систем
  [ "${SYSTEM}" = 'CentOS' ] && ${PACKAGE_INSTALL[int]} vim-common epel-release
  DEPS_CHECK=("ping" "wget" "curl" "systemctl" "ip" "sudo")
  DEPS_INSTALL=("iputils-ping" "wget" "curl" "systemctl" "iproute2" "sudo")

  for g in "${!DEPS_CHECK[@]}"; do
    [ ! -x "$(type -p ${DEPS_CHECK[g]})" ] && [[ ! "${DEPS[@]}" =~ "${DEPS_INSTALL[g]}" ]] && DEPS+=(${DEPS_INSTALL[g]})
  done

  if [ "${#DEPS[@]}" -ge 1 ]; then
    info "\n $(text 72) ${DEPS[@]} \n"
    ${PACKAGE_UPDATE[int]}
    ${PACKAGE_INSTALL[int]} ${DEPS[@]}
  else
    info "\n $(text 73) \n"
  fi
}

###################################
### EXTERNAL IP ADDRESS DETECTION
###################################
detect_external_ip() {
  IP4=$(curl -s https://cloudflare.com/cdn-cgi/trace | grep "ip" | cut -d "=" -f 2)

  if [[ ! $IP4 =~ ${regex[ipv4]} ]]; then
    IP4=$(curl -s ipinfo.io/ip)
  fi

  if [[ ! $IP4 =~ ${regex[ipv4]} ]]; then
    IP4=$(curl -s 2ip.io)
  fi

  if [[ ! $IP4 =~ ${regex[ipv4]} ]]; then
    echo "Не удалось получить внешний IP."
    return 1
  fi
}

###################################
### PATH VALIDATION AND PROCESSING
###################################
validate_and_process_path() {
  local VARIABLE_NAME="$1"
  local PATH_VALUE

  # Проверка на пустое значение
  while true; do
    case "$VARIABLE_NAME" in
      METRICS)
        reading " $(text 24) " PATH_VALUE
        ;;
      SHELLBOX)
        reading " $(text 24) " PATH_VALUE
        ;;
    esac

    if [[ -z "$PATH_VALUE" ]]; then
      warning " $(text 29) "
      echo
    elif [[ $PATH_VALUE =~ ['{}\$/\\'] ]]; then
      warning " $(text 30) "
      echo
    else
      break
    fi
  done

  # Экранируем пробелы в пути
  local ESCAPED_PATH=$(echo "$PATH_VALUE" | sed 's/ /\\ /g')

  # Присваиваем значение переменной
  case "$VARIABLE_NAME" in
    METRICS)
      export METRICS="$ESCAPED_PATH"
      ;;
    SHELLBOX)
      export SHELLBOX="$ESCAPED_PATH"
      ;;
  esac
}

###################################
### USER DATA INPUT COLLECTION
###################################
collect_user_data() {
  tilda "$(text 10)"

  reading " $(text 11) " USERNAME
  echo
  reading " $(text 12) " PASSWORD

  tilda "$(text 10)"

  if [[ ${args[generate]} == "true" ]]; then
    SUB_JSON_PATH=$(eval ${generate[path]})
  else
    echo
    validate_and_process_path SUB_JSON_PATH
  fi
  if [[ ${args[mon]} == "true" ]]; then
    if [[ ${args[generate]} == "true" ]]; then
      METRICS=$(eval ${generate[path]})
    else
      echo
      validate_and_process_path METRICS
    fi
  fi
  if [[ ${args[shell]} == "true" ]]; then
    if [[ ${args[generate]} == "true" ]]; then
      SHELLBOX=$(eval ${generate[path]})
    else
      echo
      validate_and_process_path SHELLBOX
    fi
  fi

  if [[ ${args[ssh]} == "true" ]]; then
    tilda "$(text 10)"
    reading " $(text 54) " ANSWER_SSH
    if [[ "${ANSWER_SSH,,}" == "y" ]]; then
      info " $(text 48) "
      out_data " $(text 49) "
      echo
      out_data " $(text 50) "
      out_data " $(text 51) "
      echo
      out_data " $(text 52)" "type \$env:USERPROFILE\.ssh\id_rsa.pub | ssh -p 22 ${USERNAME}@${IP4} \"cat >> ~/.ssh/authorized_keys\""
      out_data " $(text 53)" "ssh-copy-id -p 22 ${USERNAME}@${IP4}"
      echo
      # Цикл проверки наличия ключей
      while true; do
        if [[ -s "/home/${USERNAME}/.ssh/authorized_keys" || -s "/root/.ssh/authorized_keys" ]]; then
          info " $(text 56) " # Ключи найдены
          SSH_OK=true
          break
        else
          warning " $(text 55) " # Ключи отсутствуют
          echo
          reading " $(text 54) " ANSWER_SSH
          if [[ "${ANSWER_SSH,,}" != "y" ]]; then
            warning " $(text 9) " # Настройка отменена
            SSH_OK=false
            break
          fi
        fi
      done
    else
      warning " $(text 9) " # Настройка пропущена
      SSH_OK=false
    fi
  fi

  tilda "$(text 10)"
}

###################################
### UTILITY PACKAGE INSTALLATION
###################################
install_utility_packages() {
  info " $(text 36) "
  case "$SYSTEM" in
    Debian|Ubuntu)
      DEPS_CHECK=(
        jq                      jq
        git                     git
        ufw                     ufw
        zip                     zip
        wget                    wget
        cron                    cron
        nano                    nano
        unzip                   unzip
        rsync                   rsync
        gpg                     gnupg2
        vnstat                  vnstat
        certbot                 certbot
        openssl                 openssl
        netstat                 net-tools
        htpasswd                apache2-utils
        update-ca-certificates  ca-certificates
        unattended-upgrades     unattended-upgrades
        add-apt-repository      software-properties-common
        certbot-dns-cloudflare  python3-certbot-dns-cloudflare
      )
      ;;

    CentOS|Fedora)
      DEPS_CHECK=(
        jq                      jq
        git                     git
        ufw                     ufw
        zip                     zip
        tar                     tar
        wget                    wget
        cron                    cron
        nano                    nano
        unzip                   unzip
        rsync                   rsync
        gpg                     gnupg2
        vnstat                  vnstat
        crontab                 cronie
        certbot                 certbot
        openssl                 openssl
        netstat                 net-tools
        nslookup                bind-utils
        htpasswd                httpd-tools
        update-ca-certificates  ca-certificates
        unattended-upgrades     unattended-upgrades
        add-apt-repository      software-properties-common
        certbot-dns-cloudflare  python3-certbot-dns-cloudflare
      )
      ;;
  esac

  for ((i=0; i<${#DEPS_CHECK[@]}; i+=2)); do
    bin="${DEPS_CHECK[i]}"
    pkg="${DEPS_CHECK[i+1]}"

    if command -v "$bin" >/dev/null 2>&1 || dpkg -s "$pkg" >/dev/null 2>&1; then
      continue
    fi

    DEPS_PACK+=("$pkg")
  done

  if [ "${#DEPS_PACK[@]}" -gt 0 ]; then
    info " $(text 77) ": ${DEPS_PACK[@]}
    ${PACKAGE_UPDATE[int]}
    ${PACKAGE_INSTALL[int]} ${DEPS_PACK[@]}
  else
    info " $(text 78) "
  fi

  tilda "$(text 10)"
}

###################################
### AUTOMATIC UPDATES CONFIGURATION
###################################
configure_auto_updates() {
  info " $(text 40) "

  case "$SYSTEM" in
    Debian|Ubuntu)
      echo 'Unattended-Upgrade::Mail "root";' >> /etc/apt/apt.conf.d/50unattended-upgrades
      echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
      dpkg-reconfigure -f noninteractive unattended-upgrades
      systemctl restart unattended-upgrades
      ;;

    CentOS|Fedora)
      cat > /etc/dnf/automatic.conf <<EOF
[commands]
upgrade_type = security
random_sleep = 0
download_updates = yes
apply_updates = yes

[email]
email_from = root@localhost
email_to = root
email_host = localhost
EOF
      systemctl enable --now dnf-automatic.timer
      systemctl status dnf-automatic.timer
      ;;
  esac

  tilda "$(text 10)"
}

###################################
### BBR OPTIMIZATION
###################################
enable_bbr_optimization() {
  info " $(text 41) "

  if ! grep -q "net.core.default_qdisc = fq" /etc/sysctl.conf; then
      echo "net.core.default_qdisc = fq" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv4.tcp_congestion_control = bbr" /etc/sysctl.conf; then
      echo "net.ipv4.tcp_congestion_control = bbr" >> /etc/sysctl.conf
  fi

  sysctl -p
}

###################################
### IPV6 DISABLING
###################################
disable_ipv6_support() {
  info " $(text 42) "
  interface_name=$(ifconfig -s | awk 'NR==2 {print $1}')

  if ! grep -q "net.ipv6.conf.all.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.default.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.lo.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi
  if ! grep -q "net.ipv6.conf.$interface_name.disable_ipv6 = 1" /etc/sysctl.conf; then
      echo "net.ipv6.conf.$interface_name.disable_ipv6 = 1" >> /etc/sysctl.conf
  fi

  sysctl -p
  tilda "$(text 10)"
}

###################################
### Swapfile
###################################
swapfile() {
  echo
  echo "Setting up swapfile and restarting the WARP service if necessary"
  swapoff /swapfile*
  dd if=/dev/zero of=/swapfile bs=1M count=512
  chmod 600 /swapfile
  mkswap /swapfile
  swapon /swapfile
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  swapon -a
  swapon --show
}


###################################
### SETUP MONITORING WITH NODE EXPORTER
###################################
setup_node_exporter() {
  info " $(text 66) "
  mkdir -p /etc/nginx/locations/
  bash <(curl -Ls https://github.com/cortez24rus/grafana-prometheus/raw/refs/heads/main/prometheus_node_exporter.sh)

  cat > /etc/nginx/locations/monitoring.conf <<EOF
location /${METRICS}/ {
  proxy_pass http://127.0.0.1:9100/metrics;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;

  auth_basic "Restricted Content";
  auth_basic_user_file /etc/nginx/.htpasswd;

  access_log off;
  break;
}
EOF

  tilda "$(text 10)"
}

###################################
### SETUP SHELL IN A BOX TERMINAL EMULATOR
###################################
setup_shell_in_a_box() {
  info " $(text 83) "
  apt-get install shellinabox
  mkdir -p /etc/nginx/locations/

  cat > /etc/default/shellinabox <<EOF
SHELLINABOX_DAEMON_START=1
SHELLINABOX_ARGS="--no-beep --localhost-only --disable-ssl"
EOF

  cat > /etc/nginx/locations/shellinabox.conf <<EOF
location /${SHELLBOX}/ {
  proxy_pass http://127.0.0.1:4200;
  proxy_set_header Host \$host;
  proxy_set_header X-Real-IP \$remote_addr;
  proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Proto \$scheme;

  auth_basic "Restricted Content";
  auth_basic_user_file /etc/nginx/.htpasswd;

  access_log off;
  break;
}
EOF

  systemctl restart shellinabox
  tilda "$(text 10)"
}

###################################
### SELECT AND APPLY RANDOM WEBSITE TEMPLATE
###################################
apply_random_website_template() {
  info " $(text 79) "
  mkdir -p /var/www/html/ ${DIR_XCORE}/

  cd ${DIR_XCORE}/

  if [[ ! -d "simple-web-templates-main" ]]; then
      while ! wget -q --progress=dot:mega --timeout=30 --tries=10 --retry-connrefused "https://github.com/cortez24rus/simple-web-templates/archive/refs/heads/main.zip"; do
        warning " $(text 38) "
        sleep 3
      done
      unzip -q main.zip &>/dev/null && rm -f main.zip
  fi

  cd simple-web-templates-main
  rm -rf assets ".gitattributes" "README.md" "_config.yml"

  RandomHTML=$(ls -d */ | shuf -n1)  # Обновил для выбора случайного подкаталога
  info " $(text 80) ${RandomHTML}"

  # Если шаблон существует, копируем его в /var/www/html
  if [[ -d "${RandomHTML}" && -d "/var/www/html/" ]]; then
      echo "Копируем шаблон в /var/www/html/..."
      rm -rf /var/www/html/*  # Очищаем старую папку
      cp -a "${RandomHTML}/." /var/www/html/
  else
      echo "Ошибка при извлечении шаблона!"
  fi

  cd ~
  tilda "$(text 10)"
}


###################################
### CONFIGURE NGINX GEOIP CHECK ENDPOINT
###################################
configure_nginx_geoip_check() {
  cat > /etc/nginx/locations/geoip.conf <<EOF
# Geo check
location = /geoip-check {
  default_type text/plain;
  return 200 "Your IP: \$remote_addr\nCountry: \$geoip2_country_code - \$geoip2_country_name\nCity: \$geoip2_city_name\nASN: \$geoip2_asn\nOrg: \$geoip2_organization\n";
}
EOF
}

###################################
### CONFIGURE FIREWALL FOR SECURITY
###################################
configure_firewall() {
  info " $(text 47) "

  chmod +x "${DIR_XCORE}/repo/security/f2b.sh"
  bash ${DIR_XCORE}/repo/security/f2b.sh

  BLOCK_ZONE_IP=$(echo ${IP4} | cut -d '.' -f 1-3).0/22

  case "$SYSTEM" in
    Debian|Ubuntu)
      ufw --force reset
      ufw deny from "$BLOCK_ZONE_IP" comment 'Protection from my own subnet (reality of degenerates)'
      ufw deny from 95.161.76.0/24 comment 'TGBOT NL'
      ufw deny from 149.154.161.0/24 comment 'TGBOT NL'
      ufw limit 22/tcp comment 'SSH'
      # ufw allow 80/tcp comment 'WEB over HTTP'
      ufw allow 443/tcp comment 'WEB over HTTPS'
      ufw --force enable
      ;;

    CentOS|Fedora)
      systemctl enable --now firewalld
      firewall-cmd --permanent --zone=public --add-port=22/tcp
      firewall-cmd --permanent --zone=public --add-port=443/tcp
      firewall-cmd --permanent --zone=public --add-rich-rule="rule family='ipv4' source address='$BLOCK_ZONE_IP' reject"
      firewall-cmd --reload
      ;;
  esac

  tilda "$(text 10)"
}

###################################
### CONFIGURE SSH SECURITY SETTINGS
###################################
configure_ssh_security() {
  if [[ "${ANSWER_SSH,,}" == "y" ]]; then
    info " $(text 48) "
    bash <(curl -Ls https://raw.githubusercontent.com/cortez24rus/motd/refs/heads/X/install.sh)

    sed -i -e "
      s/#Port/Port/g;
      s/Port 22/Port 22/g;
      s/#PermitRootLogin/PermitRootLogin/g;
      s/PermitRootLogin yes/PermitRootLogin prohibit-password/g;
      s/#PubkeyAuthentication/PubkeyAuthentication/g;
      s/PubkeyAuthentication no/PubkeyAuthentication yes/g;
      s/#PasswordAuthentication/PasswordAuthentication/g;
      s/PasswordAuthentication yes/PasswordAuthentication no/g;
      s/#PermitEmptyPasswords/PermitEmptyPasswords/g;
      s/PermitEmptyPasswords yes/PermitEmptyPasswords no/g;
    " /etc/ssh/sshd_config

    systemctl restart ssh
    tilda "$(text 10)"
  fi
}

###################################
### DISPLAY FINAL CONFIGURATION OUTPUT
###################################
display_configuration_output() {
  info " $(text 58) "
  echo
  out_data " $(text 59) " "https://${DOMAIN}/${SUB_JSON_PATH}/sub.html?name=${USERNAME}"
  echo
  if [[ ${args[mon]} == "true" ]]; then
    out_data " $(text 21) " "https://${DOMAIN}/${METRICS}/"
    echo
  fi
  if [[ ${args[shell]} == "true" ]]; then
    out_data " $(text 22) " "https://${DOMAIN}/${SHELLBOX}/"
    echo
  fi
  out_data " $(text 62) " "ssh -p 22 ${USERNAME}@${IP4}"
  echo
  out_data " $(text 63) " "$USERNAME"
  out_data " $(text 64) " "$PASSWORD"
  tilda "$(text 10)"
}

###################################
### DOWNLOAD AND MIRROR WEBSITE
###################################
mirror_website() {
  reading " $(text 13) " sitelink
  local NGINX_CONFIG_L="/etc/nginx/locations/root.conf"
  wget -P /var/www --mirror --convert-links --adjust-extension --page-requisites --no-parent https://${sitelink}

  mkdir -p ./testdir
  wget -q -P ./testdir https://${sitelink}
  index=$(ls ./testdir)
  rm -rf ./testdir

  if [[ "$sitelink" =~ "/" ]]
  then
    sitedir=$(echo "${sitelink}" | cut -d "/" -f 1)
  else
    sitedir="${sitelink}"
  fi

  chmod -R 755 /var/www/${sitedir}
  filelist=$(find /var/www/${sitedir} -name ${index})
  slashnum=1000

  for k in $(seq 1 $(echo "$filelist" | wc -l))
  do
    testfile=$(echo "$filelist" | sed -n "${k}p")
    if [ $(echo "${testfile}" | tr -cd '/' | wc -c) -lt ${slashnum} ]
    then
      resultfile="${testfile}"
      slashnum=$(echo "${testfile}" | tr -cd '/' | wc -c)
    fi
  done

  sitedir=${resultfile#"/var/www/"}
  sitedir=${sitedir%"/${index}"}

  NEW_ROOT="  root /var/www/${sitedir};"
  NEW_INDEX="  index ${index};"

  sed -i '/^\s*root\s.*/c\ '"$NEW_ROOT" $NGINX_CONFIG_L
  sed -i '/^\s*index\s.*/c\ '"$NEW_INDEX" $NGINX_CONFIG_L

  systemctl restart nginx.service
}

###################################
### MANAGE XRAY CHAIN MENU
###################################
manage_xray_chain_menu() {
  while true; do
    clear
    tilda "|--------------------------------------------------------------------------|"
    info " $(text 117) "    # 1. Add server chain for routing
    info " $(text 118) "    # 2. Remove server chain from configuration
    echo
    warning " $(text 84) "  # 0. Previous menu
    tilda "|--------------------------------------------------------------------------|"
    echo
    reading " $(text 1) " CHOICE_MENU
    tilda "$(text 10)"
    case $CHOICE_MENU in
      1)
        add_xray_config_chain
        if [[ $? -eq 0 ]]; then
          systemctl restart xray
          sed -i "s/^CHAIN=.*/CHAIN=true/" "${DIR_XCORE}/xcore.conf"
          source "${DIR_XCORE}/xcore.conf"
          sync_client_configs
        else
          warning " $(text 119) "
          sleep 3
        fi
        ;;
      2) 
        remove_xray_config_chain
        if [[ $? -eq 0 ]]; then
          systemctl restart xray
          sed -i "s/^CHAIN=.*/CHAIN=false/" "${DIR_XCORE}/xcore.conf"
          source "${DIR_XCORE}/xcore.conf"
          sync_client_configs
        else
          warning " $(text 119) "
          sleep 3
        fi
        ;;
      0) manage_xray_core ;;
      *) warning " $(text 76) " ;;
    esac
  done
}

###################################
### XRAY CORE MANAGEMENT MENU
###################################
manage_xray_core() {
  while true; do
    clear
    extract_data
    tilda "|--------------------------------------------------------------------------|"
    info " $(text 129) "    # 10. Synchronize client subscription configurations
    info " $(text 130) "    # 11. Configure server chain
    echo
    warning " $(text 84) "  # 0. Previous menu
    tilda "|--------------------------------------------------------------------------|"
    echo
    reading " $(text 1) " CHOICE_MENU
    tilda "$(text 10)"
    case $CHOICE_MENU in
      10) sync_client_configs ;;
      11) manage_xray_chain_menu ;;
      0) manage_xcore ;;
      *) warning " $(text 76) " ;;
    esac
  done
}

###################################
### XCORE MANAGEMENT MENU
###################################
manage_xcore() {
  while true; do
    clear
    tilda "|--------------------------------------------------------------------------|"
    info " $(text 87) "    # 1. Perform standard installation
    echo
    info " $(text 88) "    # 2. Restore from backup
    info " $(text 89) "    # 3. Change proxy domain name
    info " $(text 90) "    # 4. Reissue SSL certificates
    echo
    info " $(text 91) "    # 5. Copy website to server
    info " $(text 92) "    # 6. Show directory size
    info " $(text 93) "    # 7. Show traffic statistics
    echo
    info " $(text 94) "    # 8. Update Xray core
    info " $(text 95) "    # X. Manage Xray core
    echo
    warning " $(text 84) " # 0. Previous menu
    tilda "|--------------------------------------------------------------------------|"
    echo
    reading " $(text 1) " CHOICE_MENU        # Choise
    tilda "$(text 10)"
    case $CHOICE_MENU in
      1)
        clear
        install_dependencies
        collect_user_data
        install_utility_packages
        configure_auto_updates
        [[ ${args[bbr]} == "true" ]] && enable_bbr_optimization
        [[ ${args[ipv6]} == "true" ]] && disable_ipv6_support
		swapfile
        [[ ${args[mon]} == "true" ]] && setup_node_exporter
        [[ ${args[shell]} == "true" ]] && setup_shell_in_a_box
        apply_random_website_template
        save_defaults_to_config
        [[ ${args[firewall]} == "true" ]] && configure_firewall
        [[ ${args[ssh]} == "true" ]] && configure_ssh_security
        display_configuration_output
        ;;
      5) mirror_website ;;
      6) 
        free -h
        echo
        show_directory_size ;;
      0)
        clear
        exit 0
        ;;
      *) warning " $(text 76) " ;;
    esac
    info " $(text 85) "
    read -r dummy
  done
}

###################################
### FUNCTION INITIALIZE CONFIG
###################################
init_file() {
  if [ ! -f "${DIR_XCORE}/xcore.conf" ]; then
    mkdir -p ${DIR_XCORE}
    cat > "${DIR_XCORE}/xcore.conf" << EOF
CHAIN=false
EOF
  fi
}

###################################
### MAIN FUNCTION
###################################
main() {
  init_file
  source "${DIR_XCORE}/xcore.conf"
  load_defaults_from_config
  parse_command_line_args "$@" || display_help_message
  detect_external_ip
  detect_operating_system
  echo
  manage_xcore
}

main "$@"
