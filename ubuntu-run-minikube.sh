#!/bin/bash

sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add
sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"

sudo apt -y update

sudo apt install docker.io -y
sudo apt install -y kubectl

sudo curl -O https://get.helm.sh/helm-v3.9.0-linux-amd64.tar.gz
sudo tar -xzf helm-v3.9.0-linux-amd64.tar.gz
sudo install linux-amd64/helm /usr/local/bin/helm

cat /etc/group | grep docker | grep $USERNAME &>/dev/null

sudo service docker start

sudo service docker status --no-pager

if [ "$?" -eq 0 ]; then
    cat /etc/group | grep docker | grep $USERNAME &>/dev/null

    if ! [ "$?" -eq 0 ]; then
      # call yourself back after adding the user to the docker group
      sudo usermod -a -G docker $USERNAME
      sudo bash $0
      # exit current run
      exit
    fi

    if ! [ -s "/usr/local/bin/minikube" ]; then
      curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      sudo install minikube-linux-amd64 /usr/local/bin/minikube
    fi
    
    if ! [ -x "/usr/local/bin/minikube" ]; then
        minikube start --driver=docker
    fi
    
    if ! [ -s "/etc/bash_completion.d/kubectl" ]; then
      git clone https://github.com/ohadm2/k8s-tools-installer.git
      
      cd k8s-tools-installer

      kubectl completion bash > /tmp/kubectl_completion
      sudo install /tmp/kubectl_completion /etc/bash_completion.d/kubectl
      sudo install complete_alias.sh /etc/bash_completion.d/

      cp ~/.bashrc ~/bashrc-backup-$(date +%s)
      cp bashrc-for-k8s ~/.bashrc
      
      /etc/bash_completion.d/kubectl
      /etc/bash_completion.d/complete_alias.sh
      
      . ~/.bashrc
    fi
    
    echo "tests:"
    
    kubectl get pods
    helm

    echo "Run 'source ~/.bashrc' and then 'h' for help. Also run 'alias' to view the new aliases."
else
    echo "Error Occurred while trying to run the docker daemon! Aborting ..."
fi


