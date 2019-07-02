#!/usr/bin/env bash
# -------------------------------------------------------------------------------
# Filename:    init-t667-vps.sh
# Revision:    1.1
# Date:        2019/07/02
# Author:      A7T
# Email:       a7t#4rt.top
# Website:     https://a7t.ink/init-t667-vps.sh
# Description: 都市丽人服务器初始化脚本
# Notes:       适用于新重装的干净Debian9系统，未经测试。
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
# Version 1.1
# 修改时区为 Asia/Shanghai
#
# Version 1.0
# 最初的版本，存在好几处硬编码
# 用于初始化都市丽人服务器

# 重置 locales
# 我也不知道怎么搞比较优雅，不过目前这种写法凑合能跑也就是了
sed -i "s/^\(# \)\?/# /g" /etc/locale.gen
sed -i "s/^# \(en_US ISO-8859-1\)/\1/" /etc/locale.gen
sed -i "s/^# \(en_US.UTF-8 UTF-8\)/\1/" /etc/locale.gen
sed -i "s/^# \(zh_CN GB2312\)/\1/" /etc/locale.gen
sed -i "s/^# \(zh_CN.UTF-8 UTF-8\)/\1/" /etc/locale.gen
dpkg-reconfigure --frontend noninteractive locales

# 修改 locales
export LANG=en_US.UTF-8
export LANGUAGE=en_US:en
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US:en
locale

# 修改 timezone
# 同上，先这么凑合
ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
dpkg-reconfigure -f noninteractive tzdata

# 避免 ssh 超时断线
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sed -i 's/#\(ClientAliveInterval\) 0/\1 30/g' /etc/ssh/sshd_config
sed -i 's/#\(ClientAliveCountMax\) 3/\1 3/g' /etc/ssh/sshd_config
systemctl reload ssh.service

# 增加 swap
mkdir /www
dd if=/dev/zero of=/www/swap bs=1M count=$(awk '($1=="MemTotal:"){mem=$2/1048576; print (mem==int(mem)?mem:int(mem+1))*1024+1}' /proc/meminfo)
chmod 600 /www/swap
mkswap /www/swap
swapon /www/swap
echo -e "#swap\n/www/swap\tswap\tswap\tdefaults\t0 0" >> /etc/fstab

# 添加 backports 源
cat >> /etc/apt/sources.list <<EOF

# stretch-backports
deb http://ftp.debian.org/debian stretch-backports main
deb-src http://ftp.debian.org/debian stretch-backports main
EOF

# 更新源
apt update

# 安装一些常用的软件包
apt install -y wget curl git screen screenfetch vim nano mtr nmap dnsutils traceroute iftop iotop htop ntp netcat-openbsd openssl xz-utils
apt -t stretch-backports install -y shadowsocks-libev nginx-full

# 更新系统
screen -S upgrade \
  apt dist-upgrade -y
