#!/bin/bash

dir=$(pwd)
cd ~

# java install and configure
if [[ $(java -version 2>&1 | grep "1.8.0") ]]; then echo "java 8 already installed"
elif [ -d "/usr/lib/jvm/java-1.8.0-openjdk"]; then echo "update java default to java-1.8.0 by running: sudo update-alternatives --config java";
else echo "install java 8 by running: sudo apt -y install openjdk-8-jre"; fi

# gradle install and configure
if [[ $(gradle -version 2>&1 | grep "5.6.4") ]]; then echo 'gradle 5.6.4 already installed'
elif [[ $(gradle -version 2>&1 | grep "command not found") ]]; then
  if [[ $(cat ~/.bashrc | grep gradle) ]]; then echo "remove the line in ~/.bashrc that has gradle in it";
  else wget https://services.gradle.org/distributions/gradle-5.6.4-bin.zip; unzip -q gradle-5.6.4-bin.zip; rm gradle-5.6.4-bin.zip
    echo $'# adding gradle to path\nexport PATH=$PATH:~/gradle-5.6.4/bin' >> ~/.bashrc; source ~/.bashrc; echo 'installed gradle 5.6.4 and added it to path'; fi
else
  if [[ $(apt list --installed | grep gradle) ]]; then echo "uninstall gradle by running: sudo apt remove *gradle*";
  elif [[ $(find ~/ -type f -name "gradle") ]]; then echo $'\nYou have installed gradle, but it isnt on PATH, and could be the wrong version\n\n\t Would you like to install and add to PATH anyways? (y | n)'; read varname
    if [ $varname != y || $varname != Y ]; then echo 'add a gradle 5.6.4 version to PATH'
    elif [[ $(cat ~/.bashrc | grep gradle) ]]; then echo "remove the line in ~/.bashrc that has gradle in it";
    else wget https://services.gradle.org/distributions/gradle-5.6.4-bin.zip; unzip -q gradle-5.6.4-bin.zip; rm gradle-5.6.4-bin.zip
      echo $'# adding gradle to path\nexport PATH=$PATH:~/gradle-5.6.4/bin' >> ~/.bashrc; source ~/.bashrc; echo 'installed gradle 5.6.4 and added it to path'; fi
  fi; fi

# if java and gradle are working, install moqui
# otherwise java and gradle are not installed to the proper version, the user needs to do something and then run again
if [[ $(gradle -version 2>&1 | grep "5.6.4") && $(java -version 2>&1 | grep "1.8.0") ]]; then
  if [ -d ~/moqui ]; then echo $'\nMoqui is already downloaded at ~/moqui.\n\tWould you like to delete this folder? (y | n)'; read deleteconf;
    if [[ deleteconf != y || deleteconf != Y ]]; then echo 'rename or delete this folder to run this part of the script'
    else rm -r ~/moqui; fi
  else
    echo $'installing moqui at ~/moqui\n'; git clone https://github.com/moqui/moqui-framework moqui; cd moqui;
    gradle getRuntime; gradle downloadElasticSearch; gradle load;
    echo $'\nSuccessfully installed moqui at ~/moqui. \n\tTo get a component, for example: HiveMind, run: gradle getComponent -Pcomponent=HiveMind\n\tTo run Moqui, run: java -jar moqui.war\n\tFor more information visit https://moqui.org'; fi
else
  cd $dir; echo $'\nTo get moqui running, follow the instructions above and then run this script again!'; fi
