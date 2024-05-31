# Setup

## Minimal Requirements

```bash
sudo pacman -S git zsh stow zoxide tmux
```

Install Oh My Zsh:

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Install Zsh plugins:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Docker Setup

Docker install:

```bash
sudo pacman -S docker docker-buildx
```

Docker desktop is available in the AUR. Install it with:

```bash
yay -S docker-desktop
```

Gnome terminal is required for non gnome desktops.

```bash
sudo pacman -S gnome-terminal
```

### Setup Pass

```bash
gpg --generate-key
pass init <gpg-id>
```

## Tmux Setup

```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

Use `prefix` + `I` to install plugins.

## Neovim Setup

Base packages:

```bash
sudo pacman -S neovim lazygit ripgrep fzf fd lazydocker
```

Needed for python support:

```bash
sudo pacman -S python-pynvim python-poetry python-prompt_toolkit
```

## Programming Languages

Arch includes the latest version of Python so no need to install it.

### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### JavaScript

```bash
sudo pacman -S nodejs npm
```

## Link dotfiles

```bash
cd dotfiles && stow .
```

## Hyprland Setup

### Dependencies

There's some changes that need to be added in the pam.d/login file.

```bash
  auth required pam_autologin.so always
  auth optional pam_gnome_keyring.so
  session optional pam_gnome_keyring.so auto_start
```

```bash
sudo pacman -S hyprland hyprpaper hyprlock hypridle alacritty dunst \
  xdg-desktop-portal-hyprland polkit-kde-agent qt6-wayland \
  plasma-framework5 waybar qt6ct gnome-keyring brightnessctl
```

```bash
yay -S anyrun pam_autologin hyprshot
```

## Nvidia

All nvidia things should be set already.
Check the [docs](https://wiki.hyprland.org/Nvidia/) for more information.
Nvidia specific config is in the nvidia branch.

Enable the nvidia services for suspend/wakeup

```bash
sudo systemctl enable nvidia-suspend
sudo systemctl enable nvidia-resume
sudo systemctl enable nvidia-hibernate
```

There's a kernel paremeter that needs to be set so check the [docs](https://wiki.hyprland.org/Nvidia/)
If it's not already set.
