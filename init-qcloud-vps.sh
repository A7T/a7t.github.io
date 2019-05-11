#!/usr/bin/env bash
# -------------------------------------------------------------------------------
# Filename:    init-qcloud-vps.sh
# Revision:    1.1
# Date:        2019/05/10
# Author:      A7T
# Email:       a7t#4rt.top
# Website:     https://a7t.ink/init-qcloud-vps.sh
# Description: 腾讯云服务器初始化脚本
# Notes:       适用于新重装的干净系统，在腾讯云CentOS7测试通过。
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
# 自动重载 sshd_config
# epel-release
# git2u-all → git2u
#
# Version 1.0
# 最初的版本，存在好几处硬编码
# 用于初始化腾讯云服务器

echo "修改 /etc/hosts 文件："
sudo sed -i 's/VM_[0-9]\+_\([0-9]\+\)_centos/ArgWK-\1/g' /etc/hosts
sudo cat /etc/hosts

echo "设置主机名："
sudo hostnamectl set-hostname $(grep -oE 'ArgWK-[0-9]+' /etc/hosts |tail -1)
sudo hostnamectl

echo "修改 /etc/ssh/sshd_config 文件："
sudo sed -i 's/#ClientAliveCountMax 3/ClientAliveCountMax 3/g' /etc/ssh/sshd_config
sudo sed -i 's/#ClientAliveInterval 0/ClientAliveInterval 30/g' /etc/ssh/sshd_config
sudo cat /etc/ssh/sshd_config |grep 'Client'

echo "重载 sshd 服务："
sudo systemctl reload sshd.service
sudo systemctk status sshd.service

echo "增加虚拟内存："
sudo mkdir /www
sudo dd if=/dev/zero of=/www/swap bs=1M count=$(awk '($1=="MemTotal:"){mem=$2/1048576; print (mem==int(mem)?mem:int(mem+1))*2048+1}' /proc/meminfo)
sudo chmod 600 /www/swap
sudo mkswap /www/swap
sudo swapon /www/swap
echo -e "#swap\n/www/swap\tswap\tswap\tdefaults\t0 0" |sudo tee /etc/fstab -a
sudo free -m

echo "更新软件包："
sudo yum update -y
sudo yum install -y epel-release
sudo yum install -y https://centos7.iuscommunity.org/ius-release.rpm
sudo yum install -y wget curl git2u screen htop
