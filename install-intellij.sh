dir=$(pwd)
cd ~

function add_to_path {
	if [[ $(cat ~/.bashrc | grep "intellij/bin" | wc -l) >0 ]]; then echo "Remove intellij from the ~/.bashrc file"
	else echo -e "# adding intellij to path\nexport PATH=$PATH:~/intellij/bin" >> ~/.bashrc; source ~/.bashrc; echo 'added intellij to path'; fi; }

if [[ $(find . -maxdepth 1 -name "idea.sh" | wc -l) > 0 ]]; then echo "intellij already installed"; exit 1;
elif [[ $(find . -maxdepth 1 -name "intellij" | wc -l) > 0 ]]; then add_to_path;
elif [[ $(find . -type f -name "idea.sh" | wc -l) >0 ]]; then echo "intellij is already downloaded. just add it to path, or delete it and re run this script. to find out where it is run: find ~ -type f -name idea.sh";
else
echo "Do you have an Intellij Ultimate license? (y | n)"; read license;
# TODO: make the links auto updating
if [[ $license = n ]]; then wget https://download.jetbrains.com/idea/ideaIC-2020.3.3.tar.gz
else wget https://download.jetbrains.com/idea/ideaIU-2020.3.3.tar.gz; fi

tar -zvxf ideaI*.tar.gz
rm -f ideaI*.tar.gz
mv -f idea-I* intellij
echo "installed intellij"
cd intellij/bin
./idea.sh &
cd $dir
add_to_path
fi
