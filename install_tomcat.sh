#! /bin/bash

# Desactivamos la actualización del kernel primero
sed -i "s/#\$nrconf{kernelhints} = -1;/\$nrconf{kernelhints} = -1;/g" /etc/needrestart/needrestart.conf
# 1. Actualizamos el sistema como de costumbre
apt update
apt upgrade -y

# 2. Creamos el usuario tomcat con las configuraciones necesarias
sudo useradd -m -d /opt/tomcat -U -s /bin/false tomcat

# 3. Instalamos el paquete jdk 21
sudo apt install openjdk-21-jdk -y

# 4. Entramos al directorio tmp
cd /tmp 

# 5. Descargamos la versión 11 de tomcat desde el directorio tmp
wget https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.2/bin/apache-tomcat-11.0.2.tar.gz

# 6. Extraemos el contenido descargado
tar xzvf apache-tomcat-11*tar.gz -C /opt/tomcat --strip-components=1

# 7. Asignamos al usuario tomcat la propiedad de los archivos descargados
chown -R tomcat:tomcat /opt/tomcat/
chmod -R u+x /opt/tomcat/bin

# 8. Configuramos las credenciales y roles de tomcat
sed -i '/<\/tomcat-users>/i \<role rolename="manager-gui" /><user username="manager" p
asswrd="manager_password" roles="manager-gui" /><role rolename="admin-gui" /><user username="admin" password="admin_pass
word" roles="manager-gui,admin-gui" />' /opt/tomcat/conf/tomcat-users.xml

# 9. Permitimos que el tomcat sea accesible de forma externa
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i '/<Valve /,/\/>/ s|<Valve|<!--<Valve|; /<Valve /,/\/>/ s|/>|/>-->|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

# 10. Creamos el archivo de servicio para tomcat
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

# 11. Recargamos los daemons de systemd
systemctl daemon-reload

# 12. Iniciamos el tomcat
systemctl start tomcat

# 13. Configuramos tomcat para que inicie automáticamente al arrancar el sistema
systemctl enable tomcat

ufw allow 8080


