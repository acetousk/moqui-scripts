
if [ ! $1 ]; then echo "Usage: ./moqui-install-debian-based.sh <path to install moqui>"; exit 1; fi

# config stuff
gradleVersion=5.6.4
jreVersion=1.8.0
javaVersion=${jreVersion:2:1}
dir=$(pwd)

# make sure to install git
if [[ $(apt list --installed | grep "git/" | wc -l) -gt 0 ]]; then echo "git is already installed"
else echo -e "install git by running: sudo apt -y install git\n"; exit 1; fi

# java install and configure
if [[ $(java -version 2>&1 | grep "$jreVersion" | wc -l) -gt 0 ]]; then echo "java $javaVerison already installed"
elif [[ $(find /usr/lib/jvm/ -type d -name "java-$javaVersion*" | wc -l) -gt 0 ]]; then echo "update java default to java-$javaVersion-openjdk by running: sudo update-alternatives --config java";
else echo -e "install java $javaVersion by running: sudo apt -y install openjdk-$javaVersion-jdk"; exit 1; fi

# gradle install and configure
function install_gradle {
  if [ $(cat ~/.bashrc | grep gradle) ]; then echo "remove the line in ~/.bashrc that has gradle in it"; exit 1;
  else wget https://services.gradle.org/distributions/gradle-$gradleVersion-bin.zip; unzip -q gradle-$gradleVersion-bin.zip -x ~/; rm gradle-$gradleVersion-bin.zip
    echo -e "# adding gradle to path\nexport PATH=$PATH:~/gradle-$gradleVersion/bin" >> ~/.bashrc; source ~/.bashrc; echo 'installed gradle $gradleVersion and added it to path'; fi
}
if [[ $(gradle -version 2>&1 | grep "$gradleVersion" | wc -l) -gt 0 ]]; then echo "gradle $gradleVersion already installed"
elif [[ $(gradle -version 2>&1 | grep "not found" | wc -l) -gt 0 ]]; then echo -e "\nYou may have installed gradle, but it isnt on PATH.\n\n\t Would you like to install and add a new folder to PATH anyways? (y | n)"; read varname
  if [[ $varname != y ]]; then echo -e "add a gradle $gradleVersion version to PATH or delete gradle that is from: \n\t $PATH"; exit 1; fi;
  install_gradle
elif [[ $(apt list --installed | grep gradle | wc -l) -gt 0 ]]; then echo "uninstall gradle by running: sudo apt remove *gradle*"; exit 1; fi;

# if java and gradle are working, install moqui
# otherwise java and gradle are not installed to the proper version, the user needs to do something and then run again
if [[ $(gradle -version 2>&1 | grep "$gradleVersion" | wc -l) -gt 0 && $(java -version 2>&1 | grep "$jreVersion" | wc -l) -gt 0 ]]; then
  echo "made it"
  if [[ $(find ~/ -maxdepth 1 -name "moqui" | wc -l) -gt 0 ]]; then echo -e "\nMoqui is already downloaded at $1/moqui.\n\tWould you like to delete this folder? (y | n)"; read deleteconf;
    echo $deleteconf
    if [[ $deleteconf = n ]]; then echo -e "rename or delete $1/moqui to run this part of the script"; exit 1
    else rm -rf $1/moqui; echo -e "removed $1/moqui"; fi; fi

  echo -e "installing moqui at $1\n"; git clone https://github.com/moqui/moqui-framework moqui; cd moqui;
  gradle getRuntime; gradle downloadElasticSearch; gradle load;
  echo -e "\nSuccessfully installed moqui at $1/moqui. \n\tTo get a component, for example: HiveMind, run: gradle getComponent -Pcomponent=HiveMind\n\tTo run Moqui, run: java -jar moqui.war then go to http://localhost:8080\n\tFor more information visit https://moqui.org"; exit 1;

echo $'\nTo get moqui running, follow the instructions above and then run this script again!'; fi
