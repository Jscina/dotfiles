#!/usr/bin/env bash

set -e

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit 1
fi

confirm() {
	read -p "$1 [y/N] " -n 1 -r
	echo
	[[ $REPLY =~ ^[Yy]$ ]]
}

install_yay() {
	echo "Installing yay"
	pacman -S --noconfirm --needed git base-devel
	git clone https://aur.archlinux.org/yay.git
	cd yay
	makepkg -si
	cd ..
	rm -rf yay
}

install_fonts() {
	echo "Installing fonts"
	yay -S --noconfirm ttf-ms-win11-auto otf-san-francisco oft-san-francisco-mono ttf-jetbrains-mono-nerd
}

install_dependencies() {
	echo "Installing dependencies"
	pacman -S --noconfirm git zsh stow zoxide tmux sddm pacman-contrib
}

enable_sddm() {
	echo "Enabling sddm"
	systemctl enable sddm
}

install_ohmyzsh() {
	echo "Installing ohmyzsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins() {
	echo "Installing zsh plugins"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
}

setup_hyprland() {
	echo "Setting up Hyprland"
	yay -S --noconfirm anyrun pam_autologin firefox-nightly-bin nwg-look \
		hyprshot-git hyprland-git hyprpaper-git hyprlock-git hypridle-git alacritty swaync \
		xdg-desktop-portal-hyprland-git polkit-kde-agent qt6-wayland \
		plasma-framework5 waybar qt6ct kvantum gnome-keyring brightnessctl libreoffice-fresh
}

add_pam_modules() {
	echo "Adding required pam modules"
	cat <<EOF >>/etc/pam.d/login
auth required pam_autologin.so always
auth optional pam_gnome_keyring.so
session optional pam_gnome_keyring.so auto_start
EOF
}

fix_hyprlock_module() {
	echo "Fixing hyprlock module"
	rm /etc/pam.d/hyprlock
	cat <<EOF >>/etc/pam.d/hyprlock
auth include system-auth
EOF
}

link_dotfiles() {
	echo "Linking dotfiles"
	stow .
}

install_docker() {
	echo "Installing Docker"
	pacman -S --noconfirm docker docker-buildx
	systemctl enable docker
	systemctl start docker
	usermod -aG docker $USER
}

setup_tmux() {
	echo "Setting up Tmux"
	git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

setup_neovim() {
	echo "Setting up Neovim"
	pacman -S --noconfirm neovim lazygit ripgrep fzf fd lazydocker
}

install_rust() {
	echo "Installing Rust"
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
}

install_javascript() {
	echo "Installing Javascript"
	pacman -S --noconfirm nodejs npm
}

rice_firefox() {
	echo "Attempting to rice Firefox"
	curl -s -o- https://raw.githubusercontent.com/PROxZIMA/Sweet-Pop/master/programs/install-curl.sh | bash
}

install_nvidia_drivers() {
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
}

install_steam() {
	echo "Installing Steam"
	pacman -S --noconfirm steam
}

setup_security_services() {
	echo "Setting up security services"
	pacman -S --noconfirm ufw fail2ban apparmor
}

setup_ufw() {
	echo "Setting up UFW"
	ufw limit 22/tcp
	ufw allow 80/tcp
	ufw allow 443/tcp
	ufw default deny incoming
	ufw default allow outgoing
	ufw enable
}

setup_fail2ban() {
	echo "Setting up Fail2ban"
	cat <<EOF >>/etc/fail2ban/jail.local
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 3600
findtime = 600
maxretry = 5

[sshd]
enabled = true
EOF
	systemctl enable fail2ban
}

add_kernel_params() {
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
}

enable_apparmor() {
	echo "Enabling AppArmor"
	systemctl enable apparmor
}

cleanup() {
	echo "Cleaning up"
	pacman -Rns --noconfirm $(pacman -Qtdq)
	paccache -rk0
}

main() {
	echo "This is a post-install script for Arch Linux. It sets up the system for my personal use."
	echo "DO NOT RUN THIS SCRIPT IF YOU DO NOT KNOW WHAT IT DOES OR IF YOUR SYSTEM IS NOT A FRESH INSTALL."

	if ! confirm "Do you want to continue?"; then
		exit 1
	fi

	install_yay
	install_fonts
	install_dependencies
	enable_sddm
	install_ohmyzsh
	install_zsh_plugins
	setup_hyprland
	add_pam_modules
	fix_hyprlock_module
	link_dotfiles
	install_docker
	setup_tmux
	setup_neovim
	install_rust
	install_javascript
	rice_firefox

	if confirm "Do you want to install Nvidia drivers?"; then
		install_nvidia_drivers
	fi

	if confirm "Do you want to install Steam?"; then
		install_steam
	fi

	setup_security_services
	setup_ufw
	setup_fail2ban
	add_kernel_params
	enable_apparmor
	cleanup
}

main "$@"
