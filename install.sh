#!/bin/bash

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

echo <<EOF
This is a post-install script for Arch Linux. It sets up the system for my personal use. 
DO NOT RUN THIS SCRIPT IF YOU DO NOT KNOW WHAT IT DOES.
OR IF YOUR SYSTEM IS NOT A FRESH INSTALL.
EOF

$confirm = read -p "Do you want to continue? [y/N]" -n 1 -r

if [[ ! $confirm =~ ^[Yy]$ ]]; then
	exit
fi

echo "Install yay"
pacman -S --noconfirm --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si
rm -rf yay

echo "Installing fonts"
yay -S --noconfirm ttf-ms-win11-auto otf-san-francisco oft-san-francisco-mono ttf-jetbrains-mono-nerd

echo "Installing Dependencies"
pacman -S --noconfirm git zsh stow zoxide tmux sddm pacman-contrib

echo "Enabling sddm"
sudo systemctl enable sddm

echo "Installing ohmyzsh"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Installing zsh plugins"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

echo "Setup Hyprland"
yay -S --noconfirm anyrun pam_autologin firefox-nightly-bin nwg-look \
	hyprshot-git hyprland-git hyprpaper-git hyprlock-git hypridle-git alacritty swaync \
	xdg-desktop-portal-hyprland-git polkit-kde-agent qt6-wayland \
	plasma-framework5 waybar qt6ct kvantum gnome-keyring brightnessctl libreoffice-fresh

echo "Adding required pam modules"
cat <<EOF >>/etc/pam.d/login
auth required pam_autologin.so always
auth optional pam_gnome_keyring.so
session optional pam_gnome_keyring.so auto_start
EOF

echo "Fixing hyprlock module"
rm /etc/pam.d/hyprlock
cat <<EOF >>/etc/pam.d/hyprlock
auth include system-auth
EOF

echo "Linking dotfiles"
stow .

echo "Installing Docker"
pacman -S --noconfirm docker docker-buildx
systemctl enable docker
systemctl start docker

echo "Adding user to docker group"
usermod -aG docker $USER

echo "Setup Tmux"
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "Setup Neovim"
pacman -S --noconfirm neovim lazygit ripgrep fzf fd lazydocker

echo "Installing Rust"
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

echo "Installing Javascript"
sudo pacman -S nodejs npm

echo "Attempting to rice Firefox"
curl -s -o- https://raw.githubusercontent.com/PROxZIMA/Sweet-Pop/master/programs/install-curl.sh | bash

$confirm = read -p "Do you want to install nvidia drivers? [y/N]" -n 1 -r

if [[ $confirm =~ ^[Yy]$ ]]; then
	echo "Installing Nvidia Drivers"
	pacman -S --noconfirm nvidia nvidia-utils nvidia-settings lib32-nvidia-utils egl-wayland libva-nvidia-driver
	echo "Adding nvidia modules to mkinitcpio"
	sed -i 's/^MODULES=()/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
	echo "Adding systemd to mkinitcpio"
	yay -S --noconfirm nvidia-pacman-hook
	echo "Create nvidia config"
	echo "options nvidia_drm modeset=1 fbdev=1" >/etc/modprobe.d/nvidia.conf

	echo "Rebuilding initramfs"
	mkinitcpio -P

	echo "Enabling nvidia services"
	systemctl enable nvidia-suspend
	systemctl enable nvidia-resume
	systemctl enable nvidia-hibernate
fi

$confirm = read -p "Do you want to install Steam? [y/N]" -n 1 -r

if [[ $confirm =~ ^[Yy]$ ]]; then
	echo "Installing Steam"
	pacman -S --noconfirm steam
fi

echo "Setting up security services"
sudo pacman -S --noconfirm ufw fail2ban apparmor

echo "Ufw setup"
sudo ufw limit 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw enable

echo "Fail2ban setup"
cat <<EOF >>/etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
EOF
echo "Enabling fail2ban"
sudo systemctl enable fail2ban

echo "Adding security options to all boot entries"

for entry in /boot/loader/entries/*.conf; do
	echo "Updating $entry"
	if grep -q "^options" "$entry"; then
		sed -i '/^options/ s/$/ lsm=landlock,lockdown,yama,integrity,apparmor,bpf/' "$entry"
	else
		echo "options lsm=landlock,lockdown,yama,integrity,apparmor,bpf" >>"$entry"
	fi
done

echo "Kernel parameters added to all boot entries"

echo "Enabling apparmor"
sudo systemctl enable apparmor

echo "Cleaning up"
pacman -Rns --noconfirm $(pacman -Qtdq)
paccache -rk0
