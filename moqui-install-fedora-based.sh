
if [[ ! $1 ]]; then echo "Usage: ./moqui-install-debian-based.sh <path to install moqui>"; exit 1; fi

# config stuff
gradleVersion=5.6.4
jreVersion=1.8.0
javaVerison=${jreVersion:2:1}
dir=$(pwd)

# make sure to install git
#if [[ $(apt list --installed | grep gradle) ]]; then echo 'git is already installed'
#else echo "install git by running: sudo apt -y install git"; fi

# java install and configure
if [[ $(java -version 2>&1 | grep $jreVersion)  ]]; then echo "java $javaVerison already installed"
elif [ -d /usr/lib/jvm/java-$jreVersion-openjdk ]; then echo "update java default to java-1.$javaVerison.0 by running: sudo update-alternatives --config java";
else echo -e "install java $javaVerison by running: sudo apt -y install openjdk-$jreVersion-jre"; fi

# gradle install and configure
function install_gradle() {
  if [[ $(cat ~/.bashrc | grep gradle) ]]; then echo "remove the line in ~/.bashrc that has gradle in it";
  else wget https://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip; unzip -q gradle-$gradleVersion-bin.zip -x ~/; rm gradle-$gradleVersion-bin.zip
    echo -e "# adding gradle to path\nexport PATH=$PATH:~/gradle-$gradleVersion/bin" >> ~/.bashrc; source ~/.bashrc; echo 'installed gradle $gradleVersion and added it to path'; fi
}
if [[ $(gradle -version 2>&1 | grep $gradleVersion) ]]; then echo "gradle $gradleVersion already installed"
elif [[ $(gradle -version 2>&1 | grep "command not found") ]]; then install_gradle;
else
  if [[ $(apt list --installed | grep gradle) ]]; then echo "uninstall gradle by running: sudo apt remove *gradle*";
  elif [[ $(find ~/ -type f -name "gradle") ]]; then echo $'\nYou have installed gradle, but it isnt on PATH, and might not be gradle $gradleVersion.\n\n\t Would you like to install and add to PATH anyways? (y | n)'; read varname
    if [[ $varname != y || $varname != Y ]]; then echo 'add a gradle $gradleVersion version to PATH'
    else install_gradle; fi;
  fi; fi

# if java and gradle are working, install moqui
# otherwise java and gradle are not installed to the proper version, the user needs to do something and then run again
if [[ $(gradle -version 2>&1 | grep $gradleVersion) && $(java -version 2>&1 | grep "1.$javaVerison.0") ]]; then
  if [ -d $1 ]; then echo -e "\nMoqui is already downloaded at $1/moqui.\n\tWould you like to delete this folder? (y | n)"; read deleteconf;
    if [[ deleteconf != y || deleteconf != Y ]]; then echo %s "rename or delete $1/moqui to run this part of the script"
    else rm -r $1; fi
  else
    echo -e "installing moqui at $1\n"; git clone https://github.com/moqui/moqui-framework moqui; cd moqui;
    gradle getRuntime; gradle downloadElasticSearch; gradle load;
    echo -e $'\nSuccessfully installed moqui at $1. \n\tTo get a component, for example: HiveMind, run: gradle getComponent -Pcomponent=HiveMind\n\tTo run Moqui, run: java -jar moqui.war\n\tFor more information visit https://moqui.org'; fi
else
  cd $dir; echo -e $'\nTo get moqui running, follow the instructions above and then run this script again!'; fi



