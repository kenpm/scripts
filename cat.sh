################################################
#                                              #
# DEV ENVIRONMENT SETUP SCRIPT (Catalina)      #
#                                              #
################################################
# http://osxdaily.com/2019/01/04/25-of-the-best-terminal-tips-from-2018/

wget https://iterm2.com/downloads/stable/iTerm2-3_3_9.zip
tar -zxvf iTerm2-3_3_9.zip -C ~/bin

# need to figure out how to unzip and install iterm2

# ******************************************
# Install Command Line Developer Tools
# http://osxdaily.com/2014/02/12/install-command-line-tools-mac-os-x/
# ******************************************
xcode-select --install
# Click Install on popup that appears
# These tools get installed to /Library/Developer/CommandLineTools/


# ******************************************
# Install Brew
# http://osxdaily.com/2018/03/07/how-install-homebrew-mac-os/
# ******************************************
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/uninstall)" to uninstall
brew analytics off
brew update

brew install wget

brew install node
