#!/bin/bash

set -e

GOVERSION=1.25.5
GREEN='\e[32m'
YELLOW='\e[33m'
BOLD='\e[1m'
RESET='\e[0m'

repos=(
    debugging-sucks/agent-wrapper
    debugging-sucks/compute-infra
    debugging-sucks/concurrency
    debugging-sucks/ecies
    debugging-sucks/ecr-infra
    debugging-sucks/event-horizon-api-infra
    debugging-sucks/event-horizon-api-service
    debugging-sucks/event-horizon-hub-infra
    debugging-sucks/event-horizon-sdk-go
    debugging-sucks/event-horizon-ui
    debugging-sucks/event-horizon-ui-infra
    debugging-sucks/event-horizon-webhook-service
    debugging-sucks/event-horizon-webhook-service-infra
    debugging-sucks/openid
    debugging-sucks/proxy-service
    debugging-sucks/proxy-service-infra
    debugging-sucks/root-dns-terraform
    debugging-sucks/sigv4util
    debugging-sucks/terraform-account-factory
    debugging-sucks/terraform-manifest-k8s
    scottwis/dotfiles
)

checkout_repo() {
    repo=$1
    echo "===================================="
    if [ -d $(basename $repo) ]; then
	echo -e "${YELLOW}skipping repo $repo: directory already exists${RESET}"
    else
        echo -e "${GREEN}checking out repo $repo...${RESET}"
	git clone git@github.com:$repo	
    fi

    echo "===================================="
}

popd() {
    command popd "$@" > /dev/null
}

pushd() {
    command pushd "$@" > /dev/null
}

checkout_repos() {
    mkdir -p ~/code
    for repo in ${repos[@]}
    do
	(cd ~/code && checkout_repo $repo)
    done
}

copy_personal_config() {
    echo "===================================="
    echo -e "${GREEN}copying config files...${RESET}"
    pushd ~/code/dotfiles/home/scott
    cp admin_connect.sh .gitconfig .tmux.conf .zprofile .zshrc ~
    cd .ssh
    mkdir -p ~/.ssh
    cp config ssm-ssh-proxy.sh ~/.ssh
    popd
    echo "===================================="
}

copy_dgx_spark_config() {
    echo "===================================="
    echo -e "${GREEN}copying dgx spark specific config files...${RESET}"
    
    rsync -avh ~/code/dotfiles/home/scott/.config ~
    rsync -avh ~/code/dotfiles/home/scott/.local ~
    update-desktop-database ~/.local/share/applications

    sudo mkdir -p /usr/share/backgrounds/scott
    sudo cp ~/code/dotfiles/usr/share/backgrounds/scott/* /usr/share/backgrounds/scott

    sudo mkdir -p /usr/share/icons/hicolor/512x512/apps
    sudo cp ~/code/dotfiles/usr/share/icons/hicolor/512x512/apps/* /usr/share/icons/hicolor/512x512/apps
    
    sudo cp ~/code/dotfiles/etc/apt/preferences.d/* /etc/apt/preferences.d
    sudo cp ~/code/dotfiles/etc/apt/sources.list.d/* /etc/apt/sources.list.d
    echo "===================================="
}

install_on_dgx_spark() {
    echo "===================================="
    echo -e "${GREEN}installing various ubuntu software packages${RESET}"
    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y \
	 nvtop \
         cosmic-session \
	 zsh \
	 curl \
	 wget
    sudo apt install flatpak
    flatpak --user remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.chromium.Chromium -y
    curl https://dl.google.com/go/go$GOVERSION.linux-arm64.tar.gz -o ~/Downloads/go$GOVERSION.tgz
    pushd ~/Downloads
    sudo tar -zxvf ~/Downloads/go$GOVERSION.tgz -C /usr/local
    echo "===================================="
}

install_oh_my_zsh() {
    echo "===================================="
    if [ -d ~/.oh-my-zsh ]; then
	echo -e "${YELLOW}Skipping oh my zsh: already installed${RESET}"
    else
	echo -e "${GREEN}installing oh my zsh${RESET}"       

	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    echo "===================================="

    echo "===================================="
    if [ -d ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions ]; then
       echo -e "${YELLOW}Skipping zsh-autosuggestions plugin: already installed${RESET}"
    else
	echo -e "${GREEN}Installing zsh-autosuggestions plugin: already installed${RESET}"
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    fi
    echo "===================================="	      
}

install_rust() {
    echo "===================================="
    echo -e "${GREEN}installing rust${RESET}"
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    echo "===================================="    
}
	 

checkout_repos
copy_personal_config
copy_dgx_spark_config
install_on_dgx_spark
install_oh_my_zsh
install_rust
