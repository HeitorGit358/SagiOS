#!/bin/bash
# build.sh — monta e builda a ISO do SagiOS
# Baseado no perfil oficial "releng" do archiso + overlay de customização (KDE Plasma, branding).
set -euo pipefail

echo "==> [1/6] Atualizando sistema e instalando archiso..."
pacman -Sy --noconfirm archiso

echo "==> [2/6] Copiando perfil base oficial (releng) do archiso..."
rm -rf sagios-build
cp -r /usr/share/archiso/configs/releng ./sagios-build
cd sagios-build

echo "==> [3/6] Adicionando pacotes do KDE Plasma e apps do SagiOS..."
cat ../overlay/packages-extra.txt >> packages.x86_64
# remove duplicados mantendo ordem
awk '!seen[$0]++' packages.x86_64 > packages.x86_64.tmp && mv packages.x86_64.tmp packages.x86_64

echo "==> [4/6] Aplicando overlay de arquivos (branding, SDDM, os-release)..."
cp -rT ../overlay/airootfs airootfs/

echo "==> [5/6] Renomeando o perfil para SagiOS..."
sed -i 's/^iso_name=.*/iso_name="sagios"/' profiledef.sh
sed -i 's/^iso_label=.*/iso_label="SAGIOS_$(date +%Y%m)"/' profiledef.sh
sed -i 's/^iso_publisher=.*/iso_publisher="SagiOS <https:\/\/example.org>"/' profiledef.sh
sed -i 's/^iso_application=.*/iso_application="SagiOS Live\/Rescue CD"/' profiledef.sh
sed -i 's/^install_dir=.*/install_dir="sagios"/' profiledef.sh

echo "==> [6/6] Gerando a ISO (isso demora ~15-25 min)..."
mkdir -p ../out
mkarchiso -v -o ../out .

echo "==> Concluído! ISO gerada em out/"
ls -lh ../out
