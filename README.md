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
sudo pacman -S python-pynvim python-poetry
```

Needed for Copilot Chat (Neovim):

```bash
sudo pacman -S python-requests python-dotenv
```

## Programming Languages

Arch includes the latest version of Python so no need to install it.

### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

### Node.js

```bash
sudo pacamn -S nodejs npm
```

## Link dotfiles

```bash
cd dotfiles && stow .
```
