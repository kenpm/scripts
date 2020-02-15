################################################
#                                              #
# DEV ENVIRONMENT SETUP SCRIPT (Catalina)      #
#                                              #
################################################


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
