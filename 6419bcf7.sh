#!/usr/bin/env bash
# -------------------------------------------------------------------------------
# Filename:    6419bcf7.sh
# Revision:    1.3
# Date:        2022/05/25
# Author:      A7T
# Email:       a7t#4rt.top
# Website:     https://a7t.ink/6419bcf7.sh
# Description: openEuler清除GRUB密码脚本
# Notes:       适用于新重装的openEuler系统，在22.03-LTS测试通过。
# -------------------------------------------------------------------------------
# MIT License
#
# Copyright (c) 2019 管子工具箱
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# -------------------------------------------------------------------------------
# Version 1.0

if [[ ${UID} != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo "查找GRUB默认密码配置："
sudo grep -oPz "cat <<EOF\nset superusers=root\npassword_pbkdf2 root grub.pbkdf2.sha512.10000.5A45748D892672FDA02DD3B6F7AE390AC6E6D532A600D4AC477D25C7D087644697D8A0894DFED9D86DC2A27F4E01D925C46417A225FC099C12DBD3D7D49A7425.2BD2F5BF4907DCC389CC5D165DB85CC3E2C94C8F9A30B01DACAA9CD552B731BA1DD3B7CC2C765704D55B8CD962D2AEF19A753CBE9B8464E2B1EB39A3BB4EAB08\nEOF" /etc/grub.d/00_header

if [[ $? != 0 ]]; then
    echo "未找到GRUB默认密码配置，程序退出。"
    exit 1
else
    BAK="/tmp/00_header.$(head -c 6 /dev/random |base64)"
    echo -n "正在备份 /etc/grub.d/00_header > ${BAK}"
    cp /etc/grub.d/00_header "${BAK}"
    if [[ $? != 0 ]]; then
        echo "备份失败，程序退出。"
        exit 1
    fi
    LN=$(cat /etc/grub.d/00_header |wc -l)
    echo "正在清除GRUB默认密码…"
    sed -i '/cat <<EOF/{N;/set superusers=root/{N;/password_pbkdf2 root grub.pbkdf2.sha512.10000.5A45748D892672FDA02DD3B6F7AE390AC6E6D532A600D4AC477D25C7D087644697D8A0894DFED9D86DC2A27F4E01D925C46417A225FC099C12DBD3D7D49A7425.2BD2F5BF4907DCC389CC5D165DB85CC3E2C94C8F9A30B01DACAA9CD552B731BA1DD3B7CC2C765704D55B8CD962D2AEF19A753CBE9B8464E2B1EB39A3BB4EAB08/{N;/EOF/d}}}' /etc/grub.d/00_header
    if (( LN != $(cat /etc/grub.d/00_header |wc -l) + 4 )); then
        echo "执行出错，回滚配置。"
        cp -r "${BAK}" /etc/grub.d/00_header
        exit 1
    fi
    echo "正在更新GRUB配置…"
    if [ -f "/etc/grub2.cfg" ]; then
        grub2-mkconfig -o "$(readlink -e /etc/grub2.conf)"
        if [[ $? != 0 ]]; then
            echo "GRUB配置更新失败，程序退出。"
            exit 1
        fi
    fi
    if [ -f "/etc/grub2-efi.cfg"]; then
        grub2-mkconfig -o "$(readlink -e /etc/grub2-efi.cfg)"
        if [[ $? != 0 ]]; then
            echo "GRUB配置更新失败，程序退出。"
            exit 1
        fi
    fi
    echo "GRUB配置更新成功。"
    rm "${BAK}"
fi
