#!/data/data/com.termux/files/usr/bin/bash
clear

# Variables
domain=""
host=""
output_dir=""

function banner() {
    echo "  #####################"
    echo " ##### FAIRY BUG #####"
    echo "#####################"
    echo ""
    echo "Domain  : $domain"
    echo "Host    : $host"
    echo "Output  : $output_dir"
    echo ""
}

function init() {
    clear

    mkdir ./result

    apt update
    apt install golang -y
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    go install -v github.com/aztecrabbit/bugscanner-go@latest

    menu
}

function input_domain() {
    clear
    banner

    read -p "Masukkan domain: " domain
    output_dir=./result/$domain/$domain

    menu
}

function input_host() {
    clear
    banner

    echo "Host harus memberikan status respon 101"
    read -p "Masukkan host: " host

    menu
}

function subdomain_finder() {
    clear
    ~/go/bin/subfinder -d $domain -o $output_dir.lst -all

    echo ""
    echo "========="
    echo "Hasil disimpan di $output_dir.lst "
    echo ""
    read -p "Tekan enter untuk kembali ke menu utama"

    menu
}

function direct_scan() {
    clear
    ~/go/bin/bugscanner-go scan direct -f $output_dir.lst -o $output_dir.bug

    echo ""
    echo "========="
    echo "Hasil disimpan di $output_dir.bug"
    echo ""
    read -p "Tekan enter untuk kembali ke menu utama"

    menu
}

function cdn_ssl_scan() {
    clear
    ~/go/bin/bugscanner-go scan cdn-ssl --proxy-filename $output_dir.bug --target $host -o $output_dir.cdn

    echo ""
    echo "========="
    echo "Hasil disimpan di $output_dir.cdn"
    echo ""
    read -p "Tekan enter untuk kembali ke menu utama"

    menu
}

function sni_scan() {
    clear
    ~/go/bin/bugscanner-go scan sni -f $output_dir.lst --threads 16

    echo ""
    echo "========="
    read -p "Tekan enter untuk kembali ke menu utama"

    menu
}

function menu() {
    clear
    banner

    echo "Pilih salah satu dari menu berikut"
    echo "[0] Install dependencies"
    echo "[1] Input domain"
    echo "[2] Input host"
    echo "[3] Find subdomain"
    echo "[4] Scan direct <- [3]"
    echo "[5] Scan cdn-ssl <- [4]"
    echo "[6] Scan sni <- [3]"
    echo "[7-9] Exit"
    echo "Untuk menu yang memiliki panah dan angka setelahnya"
    echo "Itu menandakan bahwa menu tersebut bergantung pada menu di belakang panah."
    echo "Contoh: Menu [4] bergantung pada menu [3]"
    echo "Yang berarti menu [3] harus dijalankan terlebih dahulu sebelum menu [4]"
    echo ""
    read -p "Pilihan anda: " input

    if [[ $input -eq 0 ]]; then
        init
    elif [[ $input -eq 1 ]]; then
        input_domain
    elif [[ $input -eq 2 ]]; then
        input_host
    elif [[ $input -eq 3 ]]; then
        subdomain_finder
    elif [[ $input -eq 4 ]]; then
        direct_scan
    elif [[ $input -eq 5 ]]; then
        cdn_ssl_scan
    elif [[ $input -eq 6 ]]; then
        sni_scan
    else
        exit
    fi;
}

menu