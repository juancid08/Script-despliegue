#! /bin/bash

# Hacemos esto antes que nada para desactivar la actualización de kernel
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
# 1. Hacemos esto como siempre
apt update
apt upgrade -y

# 2. Añadimos el usuario tomcat
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# 3. Instalamos jdk 21
sudo apt install openjdk-21-jdk -y

# 4. Entramos en tmp
cd /tmp 

# 5. Desde tmp instalamos el tomcat 11
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.2/bin/apache-tomcat-11.0.2.tar.gz

# 6. Extraemos lo que hemos descargado
tar xzvf apache-tomcat-11*tar.gz -C /opt/tomcat --strip-components=1

# 7. Ponemos a tomcat como propietario de lo que hemos descargado
chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

# 8. Configuramos los usuarios de tomcat
sed -i '/<\/tomcat-users>/i \<role rolename="manager-gui" /><user username="manager" p
asswrd="manager_password" roles="manager-gui" /><role rolename="admin-gui" /><user username="admin" password="admin_pass
word" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml

# 9. Permite que tomcat se pueda acceder desde fuera de su servidor
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# 10. Introducimos el servicio tomcat en tomcat.service
echo '[Unit]
Description=Tomcat
After=network.target

[Service]
Type=forking

User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-1.21.0-openjdk-amd64"
Environment="JAVA_OPTS=-Djava.security.egd=file:///dev/urandom"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"
Environment="CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC"

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target' | sudo tee /etc/systemd/system/tomcat.service

# 11. Reinicio de daemons
systemctl daemon-reload

# 12. Iniciamos el tomcat
systemctl start tomcat

# 13. Habilitamos tomcat
systemctl enable tomcat

ufw allow 8080


