# install dependences: curl, git, gh
system(‘sudo apt-get update’)
system(‘sudo apt-get install git-all -y’)
system(‘curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null && sudo apt update && sudo apt install gh -y’)

# install dependences - devtools
install.packages(‘devtools’)
library(‘devtools’)

# install dependences - minioclient
install.packages(‘minioclient’)
library(‘minioclient’)
install_mc()
mc_mb(‘play/faasr’)

# install FaaSr
devtools::install_github('FaaSr/FaaSr-package',ref='main',force=TRUE)
library(‘FaaSr’)
