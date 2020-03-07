################################################
#                                              #
# DEV ENVIRONMENT SETUP SCRIPT (DEBIAN/UBUNTU) #
#                                              #
################################################


# =========================
# TODO
# =========================
# 1. Import all Visual Studio Code settings and extensions
#    a. User settings appear to be in ~/.config/Code/User/settings.json. Maybe just throw these in the workspace file?
#    b. Extensions appear to be in ~/.vscode/extensions. Probably just need to grab the whole ~/.vscode folder.
#    c. Investigate whether there's a programmatic way to download extensions for VS Code.
# 2. Import a browser profile (easy with Firefox, maybe not with others)


echo "What is your Github full name?" && read name
echo "What is your Github username?" && read gitUsername
echo "What is your Github email?" && read email
echo "What will be your code root folder?" && read codeRoot
echo "What is the Github server?" && read githubUrl
echo "What is the VPN URL?" && read vpnUrl


# =========================
# Update Repositories
# =========================
echo "***************************** Updating apt *****************************"
sudo apt update


# =========================
# Install VMWare Tools
# =========================
echo "***************************** Installing open-vm-tools-desktop *****************************"
sudo apt install open-vm-tools-desktop -yy


# =========================
# Install Basic Packages
# =========================
echo "***************************** Installing GDebi, xsel, openssh-server, sshfs, net-tools, synaptic *****************************"
dpkg -l | grep -qw gdebi || sudo apt-get install -yyq gdebi
sudo apt install -yy firefox apt-transport-https curl xsel openssh-server sshfs net-tools synaptic network-manager-openconnect-gnome network-manager-vpnc-gnome


# =========================
# Get/Install .deb Packages
# =========================
echo "***************************** Downloading VS Code *****************************"
wget -O vscode-linux-deb-x64-stable.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable
echo "***************************** Downloading Slack *****************************"
wget -O slack-desktop-4.3.2-amd64.deb https://downloads.slack-edge.com/linux_releases/slack-desktop-4.3.2-amd64.deb
echo "***************************** Downloading Stacer *****************************"
wget -O stacer_1.1.0_amd64.deb https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb
for FILE in ./*.deb
do
    echo "***************************** Installing $FILE *****************************"
    sudo gdebi -n "$FILE"
done


# =========================
# Install Sublime Merge
# =========================
echo "***************************** Installing Sublime Merge *****************************"
wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
sudo apt update
sudo apt install sublime-merge


# =========================
# Install NodeJS 10.x
# =========================
echo "***************************** Installing NodeJS *****************************"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install nodejs -yy
touch ~/.npmrc
cat > ~/.npmrc <<- EOM
prefix=~/.npm-global
registry=https://artifactory.us-east-1.bamgrid.net/api/npm/fed-npm
_auth=ZmVkLXVzZXI6QVA0NFBnNmVwczhOQjF1U0JHbmNBWmdaS1FS
always-auth=false
email=$email
EOM
echo "export PATH=~/.npm-global/bin:\$PATH" >> ~/.profile
. ~/.profile


# =========================
# Install Git
# =========================
echo "***************************** Installing Git *****************************"
sudo apt install git -yy
git config --global user.name "$name"
git config --global user.email "$email"
git config --global url."ssh://git@$githubUrl".insteadOf git://$githubUrl
git config --global --add hub.host $githubUrl
ssh-keygen -f ~/.ssh/github-$HOSTNAME -t rsa -C "$email"
# Prompted twice for the SSH passphrase here
touch ~/.ssh/config
cat > ~/.ssh/config <<- EOM
Host $githubUrl
User git
IdentityFile ~/.ssh/github-$HOSTNAME
EOM


# =========================
# Setup SSH Key
# =========================
echo "***************************** Setting up the Git SSH Key *****************************"
echo "Connecting to the VPN. You will now be asked for your LDAP password..."
sudo openconnect -u $email -b -q $vpnUrl
sshKey=`sudo cat ~/.ssh/github-$HOSTNAME.pub`
echo "Sending the following SSH key data to Github:"
echo "{ \"title\": \"github-$HOSTNAME\", \"key\": \"$sshKey\" }"
# Prompted once for the LDAP password here
curl -v -u "$gitUsername" -X POST --data "{ \"title\": \"github-$HOSTNAME\", \"key\": \"$sshKey\" }" https://$githubUrl/api/v3/user/keys
ssh-add -k ~/.ssh/github-$HOSTNAME
# Prompted once for the SSH passphrase here
ssh -T git@$githubUrl
# Prompted for 'yes' here


# =========================
# Setup Dev Folders
# =========================
echo "***************************** Setting up the Local Dev Folders *****************************"
mkdir $codeRoot
mkdir $codeRoot/browser-sdk
mkdir $codeRoot/PullRequests
mkdir $codeRoot/spec-sdk
git clone git@$githubUrl:fed-core/browser-sdk.git $codeRoot/browser-sdk
git clone git@$githubUrl:kmcnamee/PullRequests.git $codeRoot/PullRequests
git clone git@$githubUrl:sdk-doc/spec-sdk.git $codeRoot/spec-sdk

echo "***************************** Running npm install *****************************"
cd $codeRoot/browser-sdk
npm install -g n
npm i

touch $codeRoot/sdk.code-workspace
cat > $codeRoot/sdk.code-workspace <<- EOM
{
  "folders": [
    { "path": "browser-sdk"  }
    { "path": "PullRequests" },
    { "path": "spec-sdk"  }
  ],
  "settings": {
    "editor.rulers": [120],
    "workbench.colorCustomizations": { "editorRuler.foreground": "#ff6666" },
    "telemetry.enableTelemetry": false,
    "telemetry.enableCrashReporter": false,
    "files.exclude": {
      "*.log": true,
      "**/.git": false,
      "**/assets": true,
      "**/bin": true,
      "**/dist": true,
      "**/node_modules": true,
      "**/setup": true,
      "**/util": true
    }
  }
}
EOM


# =========================
# Setup Bash Aliases
# =========================
echo "***************************** Setting up the Bash Aliases *****************************"
touch ~/.bash_aliases

cat > ~/.bash_aliases <<- EOM
alias    nano='nano -l'

alias     gps='git push'
alias    gpsn='git push --no-verify'
alias      gf='git fetch'
alias     gpl='git pull --rebase'
alias     gst='git status'

alias     tes='npm run test'
alias     seq='npm run sequences'
alias    lint='npm run lint'
alias    only='grep -r ".only(" /home/$USER/sdk/browser-sdk/test/'
alias    todo='grep -r "@todo" /home/$USER/sdk/browser-sdk/src/'

alias      tu='npm run test-unit'
alias      ti='npm run test-integration'
alias     tus='npm run test-unit-services'
alias     tis='npm run test-integration-services'

alias   tuacc='npm run test-unit-account'
alias   tiacc='npm run test-integration-account'
alias  tusacc='npm run test-unit-services-account'
alias  tisacc='npm run test-integration-services-account'

alias   tucom='npm run test-unit-commerce'
alias   ticom='npm run test-integration-commerce'
alias  tuscom='npm run test-unit-services-commerce'
alias  tiscom='npm run test-integration-services-commerce'

alias   tucfg='npm run test-unit-configuration'
alias   ticfg='npm run test-integration-configuration'
alias  tuscfg='npm run test-unit-services-configuration'
alias  tiscfg='npm run test-integration-services-configuration'

alias   tucon='npm run test-unit-content'
alias   ticon='npm run test-integration-content'
alias  tuscon='npm run test-unit-services-content'
alias  tiscon='npm run test-integration-services-content'

alias   tucus='npm run test-unit-customerService'
alias   ticus='npm run test-integration-customerService'
alias  tuscus='npm run test-unit-services-customerService'
alias  tiscus='npm run test-integration-services-customerService'

alias   tudev='npm run test-unit-device'
alias   tidev='npm run test-integration-device'
alias  tusdev='npm run test-unit-services-device'
alias  tisdev='npm run test-integration-services-device'

alias   tueli='npm run test-unit-eligibility'
alias   tieli='npm run test-integration-eligibility'
alias  tuseli='npm run test-unit-services-eligibility'
alias  tiseli='npm run test-integration-services-eligibility'

alias   tuext='npm run test-unit-externalActivation'
alias   tiext='npm run test-integration-externalActivation'
alias  tusext='npm run test-unit-services-externalActivation'
alias  tisext='npm run test-integration-services-externalActivation'

alias   tuidp='npm run test-unit-identity'
alias   tiidp='npm run test-integration-identity'
alias  tusidp='npm run test-unit-services-identity'
alias  tisidp='npm run test-integration-services-identity'

alias   tuint='npm run test-unit-internal'
alias   tiint='npm run test-integration-internal'
alias  tusint='npm run test-unit-services-internal'
alias  tisint='npm run test-integration-services-internal'

alias   tumed='npm run test-unit-media'
alias   timed='npm run test-integration-media'
alias  tusmed='npm run test-unit-services-media'
alias  tismed='npm run test-integration-services-media'

alias   tumpa='npm run test-unit-media-playerAdapter'
alias   timpa='npm run test-integration-media-playerAdapter'

alias   tuses='npm run test-unit-session'
alias   tises='npm run test-integration-session'
alias  tusses='npm run test-unit-services-session'
alias  tisses='npm run test-integration-services-session'

alias   tusoc='npm run test-unit-sockets'
alias   tisoc='npm run test-integration-sockets'
alias  tussoc='npm run test-unit-services-sockets'
alias  tissoc='npm run test-integration-services-sockets'

alias   tusub='npm run test-unit-subscription'
alias   tisub='npm run test-integration-subscription'
alias  tussub='npm run test-unit-services-subscription'
alias  tissub='npm run test-integration-services-subscription'

alias   tutok='npm run test-unit-token'
alias   titok='npm run test-integration-token'
alias  tustok='npm run test-unit-services-token'
alias  tistok='npm run test-integration-services-token'

alias   tupay='npm run test-unit-paywall'
alias   tipay='npm run test-integration-paywall'
alias  tuspay='npm run test-unit-services-paywall'
alias  tispay='npm run test-integration-services-paywall'

alias   tupur='npm run test-unit-purchase'
alias   tipur='npm run test-integration-purchase'
alias  tuspur='npm run test-unit-services-purchase'
alias  tispur='npm run test-integration-services-purchase'

alias   tudrm='npm run test-unit-drm'
alias   tidrm='npm run test-integration-drm'
alias  tusdrm='npm run test-unit-services-drm'
alias  tisdrm='npm run test-integration-services-drm'

alias   tuusa='npm run test-unit-userActivity'
alias   tiusa='npm run test-integration-userActivity'
alias  tususa='npm run test-unit-services-userActivity'
alias  tisusa='npm run test-integration-services-userActivity'

alias   tuusp='npm run test-unit-userProfile'
alias   tiusp='npm run test-integration-userProfile'
alias  tususp='npm run test-unit-services-userProfile'
alias  tisusp='npm run test-integration-services-userProfile'

alias   tuseq='npm run test-unit-sequences'
alias   tiseq='npm run test-integration-sequences'

alias   tuqos='npm run test-unit-qualityOfService'
alias   tiqos='npm run test-integration-qualityOfService'
alias  tusqos='npm run test-unit-services-qualityOfService'
alias  tisqos='npm run test-integration-services-qualityOfService'

alias  tusexc='npm run test-unit-services-exception'

alias  tusutl='npm run test-unit-services-util'

alias   tipar='npm run test-integration-partners'
EOM

cat ~/.bash_aliases
. ~/.bash_aliases

echo "***************************** Reloading the Bash Profile *****************************"
. ~/.bashrc


# Open VS Code
code $codeRoot/sdk.code-workspace

echo "***************************** D E V  S E T U P  C O M P L E T E *****************************"
