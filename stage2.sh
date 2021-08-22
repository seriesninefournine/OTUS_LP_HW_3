#!/bin/bash
#Переносим / на другой диск
#https://habr.com/ru/post/352400/

#Создаем тома под новый раздел
pvcreate /dev/sdb
vgcreate VG_root /dev/sdb
lvcreate -L8G -n LV_root VG_root

#Форматируем
mkfs.xfs /dev/VG_root/LV_root

#Переносим корень
mount /dev/VG_root/LV_root /mnt/
xfsdump -l0 -J - / | xfsrestore -J - /mnt

#Прописываем новые настройки загрузки
sed -i -e "s/VolGroup00-LogVol00/VG_root-LV_root/g" /etc/fstab
sed -i -e "s/VolGroup00-LogVol00/VG_root-LV_root/g" /boot/grub2/grub.cfg
sed -i -e "s/rd.lvm.lv=VolGroup00\/LogVol00/rd.lvm.lv=VG_root\/LV_root rd.lvm.lv=VolGroup00\/LogVol00/g" /boot/grub2/grub.cfg

shutdown -r now