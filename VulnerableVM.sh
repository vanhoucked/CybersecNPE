#!/bin/bash

mkdir "/baseVulnerableVM"
VBoxManage createvm --name "VulnerableVM" --ostype "Linux26_64" --register --basefolder "/baseVulnerableVM"

VBoxManage modifyvm "VulnerableVM" --memory "2048"
VBoxManage modifyvm "VulnerableVM" --cpus "1"

VBoxManage modifyvm "VulnerableVM" --nic1 intnet
VBoxManage modifyvm "VulnerableVM" --nic2 nat

VBoxManage startvm "VulnerableVM"