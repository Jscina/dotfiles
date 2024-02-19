# Setup

## Minimal Requirements

```bash
sudo pacman -S git zsh stow zoxide
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

## Neovim Setup

Base packages:

```bash
sudo pacman -S neovim lazygit ripgrep fzf fd lazydocker docker
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

## Link Dotfiles

```bash
cd dotfiles && stow .
```
