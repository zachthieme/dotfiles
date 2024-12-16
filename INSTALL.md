##
# PACKAGE MANAGER INSTALLS
##
tmux, btop, podman, python3-libtmux

##
# RUST INSTALLS
##
cargo install tlrc

##
# MANUAL INSTALLS
##
nvim
```
install here
```
rust
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```
firacode
```bash
wget https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/FiraCode.zip
mkdir -p $HOME/.fonts
unzip FiraCode.zip -d ~/.fonts
fc-cache -fv
```
go
```bash
wget https://go.dev/dl/go1.23.4.linux-arm64.tar.gz
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.23.4.linux-arm64.tar.gz 
```
cheat
```bash
go install github.com/cheat/cheat/cmd/cheat@latest
```
set editor
```bash
sudo update-alternatives --install /usr/bin/editor editor $(which nvim) 60
sudo update-alternatives --config editor
```
install lazygit
```bash
git clone https://github.com/jesseduffield/lazygit.git
cd lazygit
go install
```
install zoxide
```bash
curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
```
install ohmyposh
```bash
curl -s https://ohmyposh.dev/install.sh | bash -s
```
install tpm
```
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```
##
# MANUAL INSTALLS (NOT NEEDED AS THE CONFIG FILES WILL REINSTALL"
##
fzf, zim,

##
# POST INSTALL SETUP
##
