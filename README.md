# Azure Terraform Lab

Ez a repó a Terraform segítségével az Azure felhőben létrehozott infrastruktúra-fejlesztési projektjeimet és laborjaimat tartalmazza.

---

## 1. Projekt: Windows 10 Multi-VM tesztkörnyezet (`gepek.tf`)

Az első feladat során 3 darab Windows 10-es virtuális gép egyidejű kiépítését automatizáltam a `count = 3` paraméter segítségével.

### Konfigurációs részletek (`gepek.tf`):
- **Resource Group**: `rg-windows-demok` az `West Europe` régióban.
- **Hálózat (VNet & Subnet)**: 
  - `windows-vnet` (Cím tartomány: `10.0.0.0/16`)
  - `windows-subnet` (Alhálózati tartomány: `10.0.1.0/24`)
- **Hálózati kártyák (NIC)**: Dynamic belső IP-címmel ellátott kártyák dinamikusan generálva mind a 3 géphez (`win-nic-1`, `win-nic-2`, `win-nic-3`).
- **Virtuális gépek (`azurerm_windows_virtual_machine`)**:
  - **Darabszám**: 3 db (`winvm-1`, `winvm-2`, `winvm-3`)
  - **Méret**: `Standard_B1s` (költséghatékony tesztméret)
  - **OS Kép**: Windows 10 Pro (`MicrosoftWindowsDesktop` / `windows-10` / `win10-22h2-pro`)

---

## 2. Projekt: Ubuntu Linux GUI & RDP Munkakörnyezet (`ubuntu-gui-vm/`)

A második feladatban egy grafikus felülettel ellátott Ubuntu Linux virtuális gépet hoztam létre automatizált post-installation szkript segítségével.

### Konfigurációs részletek (`ubuntu-gui-vm/`):
- **Resource Group & Régió**: `teszgep-csoport` az `eastus` régióban.
- **Virtuális gép**: Ubuntu 24.04 LTS (`Standard_D2s_v3` gépmeret).
- **Grafikus felület és Távoli Elérés**: 
  - Automatikus XFCE4 desktop környezet (`xfce4`, `xfce4-goodies`) telepítés.
  - `xrdp` szerver konfiguráció a biztonságos RDP (`mstsc`) kapcsolathoz.
- **Hálózati Biztonság (NSG)**: Szigorúan korlátozott portszintű szabályok RDP (3389) és SSH (22) eléréshez.
