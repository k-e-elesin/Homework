#!/bin/bash

# подготовка образа astra 1.7.5
sudo echo "deb [arch=amd64 trusted=yes] http://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-update/ 1.7_x86-64 non-free contrib main  
deb [arch=amd64 trusted=yes] http://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-base/ 1.7_x86-64 main contrib non-free 
deb [arch=amd64 trusted=yes] http://dl.astralinux.ru/astra/stable/1.7_x86-64/repository-extended/ 1.7_x86-64 non-free contrib main " > /etc/apt/sources.list.d/sources_last_astra.list

sudo apt install -qy debootstrap

sudo echo "#!/bin/bash
debootstrap --include ncurses-term,locales,gawk,lsb-release,acl --components=main,contrib,non-free 1.7_x86-64 \$1 http://repo.inter.sibghk.ru/repo/base_updated_1.7.5" > ~/makeastra

sudo chmod +x ~/makeastra

sudo apt install docker.io

sudo adduser $USER docker

sudo mkdir ~/docker_astra

sudo cp /etc/apt/sources.list.d/sources_last_astra.list ~/docker_astra/etc/apt/sources.list

sudo echo "#!/bin/bash
tar -C \$1 -cpf - . | docker import - \$2 --change \"ENV PATH /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin\" --change 'CMD [\"/bin/bash\"]' --change \"ENV LANG=ru_RU.UTF-8\"" > ~/docker_import

sudo chmod +x ~/docker_import

sudo ~/./docker_import ~/docker_astra astra:stable

sudo mkdir ~/docker_ap

# подготовка образа c apache и php
sudo echo "FROM astra:stable
RUN apt update && apt install -qy apache2 php libapache2-mod-php
RUN sudo echo"<!DOCTYPE html>
<html>
    <head>
        <title>Привет, мир!</title>
    </head>
    <body>
        <?php echo '<p>Привет, мир!</p>'; ?>
    </body>
</html>" > /var/www/html/index.php" > ~/docker_ap/Dockerfile

# собираю контейнер и запускаю
sudo docker build ~/docker_ap -t astra:175-apache-php
sudo docker run -d --name web-srv -p 80:80 astra:175-apache-php
