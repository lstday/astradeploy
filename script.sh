#!/bin/bash
VERSION="0.20"
set -e
USER=`id -u`
if [ $USER -ne "0" ]; then
        echo "Must be root"
        exit 1
fi
cd /root


user_input()
{
	while true; do
		echo $1
		read UINPUT
		echo "Your entered $UINPUT"
		read -p "Are you shure? (press Y or y if all ok) " yn
		case $yn in
			[Yy]* ) eval $2="$UINPUT"; break;;
			* ) echo "Ok, one more time... ";;
		esac
	done
}


not_sorted()
{
update-rc.d -f cups remove

while true; do
        echo -n "Enter arm num: "
        read_input
        echo "Your entered $UINPUT"
        read -p "Are you shure? (press Y or y if all ok)" yn
        if ! [[ $1 =~ ^[0-9]+$ ]]; then
                echo "Wrong argument - must be arm number"
        elif [ $1 -gt 80 ]; then
        echo "ARM park is smaller - near 80 machines"
        exit 1
fi
        ARMNAME=UINPUT
done

ARMIP="192.168.10.$((100 + $((10#$ARMNUM))))"

echo "It this arm OBI or DL? (press 1 for obi, 2 for dl)"
select obidl in "OBI" "DL"; do
        case $obidl in
                OBI ) mount /opt/astra-se-1.4.iso /media/cdrom && apt-get install dnsutils zip libpam-mount fly-admin-smc smc-ald smc-ald-audit smc-ald-capabilities smc-ald-device-ctrl smc-ald-hosts smc-ald-mac smc-ald-policy smc-ald-services smc-ald-tasks smc-ald-trusted smc-ald-users smc-audit smc-capabilities smc-common smc-config-editor smc-device-ctrl smc-local smc-mac smc-policy smc-sysctl smc-users || echo "installing packages failed"
                break;;
                DL ) mount /opt/astra-se-1.4.iso /media/cdrom && apt-get install openssh-server dnsutils zip libpam-mount || echo "installing packages failed"
                break;;
        esac
done

echo "pref("startup.homepage_welcome_url","http://$SERVER_NAME");
user_pref("startup.homepage_welcome_url","http://$SERVER_NAME");
user_pref("browser.startup.homepage","http://$SERVER_NAME");
user_pref("network.negotiate-auth.delegation-uris", "http://");
user_pref("network.negotiate-auth.trusted-uris", "http://");" | tee /etc/firefox/syspref.js > /usr/lib/firefox/defaults/pref/vendor.js

update-alternatives --set editor /usr/bin/mcedit

sed -i "/NAME=\"aldcd\"/cNAME=\"aldcd\"\ntouch -t 01010101 \/var\/lib\/ald\/cache\/parsec\/mac_\*" /etc/init.d/aldcd
}


get_variables_server()
{
	ASTRA_VERSION=$(lsb_release -a 2>/dev/null | grep Release | awk {'print $2'})
	case "$ASTRA_VERSION" in
		"1.2" ) 
		POSTGR_VERSIONS=('8.4') 
		;;
		"1.3" ) 
		POSTGR_VERSIONS=('9.1')
		;;
		"1.4" ) 
		POSTGR_VERSIONS=('9.2' '9.3')
		;;
		"1.5" ) 
		POSTGR_VERSIONS=('9.2' '9.4')
		;;
	esac
	#user_input "Enter arm name: " ARM_NAME
	user_input "Enter domain name(ex: domain.name): " DOMAIN_NAME
	user_input "Enter ald server name(NOT fqdn, ex: srv1): " SERVER_NAME
	user_input "Enter ip address:(ex: 192.168.1.1) " ARM_IP #TODO: check correct input
	user_input "Enter arm name:(NOT fqdn,ex: arm07) " ARM_NAME
	user_input "Enter server ip:(ex: 192.168.1.1) " SERVER_IP
}


install_packages_1.5() #TODO: fix it!!!
{
	#POSTGR_VERSIONS="9.2|9.4"
	apt-get install bind9 dnsutils ntp openssh-server zip rsync libpam-mount apache2 libapache2-mod-php5 libapache2-mod-auth-kerb php5 php5-curl php5-gd php5-pgsql php5-xmlrpc php5-xsl php5-imagick php5-intl  dovecot-imapd dovecot-gssapi exim4-daemon-heavy postgis gdal-bin osm2pgsql
	for version in "${POSTGR_VERSIONS[@]}"; do 
		apt-get install postgresql-"$POSTGR_VERSIONS" postgresql-client-"$POSTGR_VERSIONS" postgresql-contrib-"$POSTGR_VERSIONS" postgresql-doc-"$POSTGR_VERSIONS" postgresql-pltcl-"$POSTGR_VERSIONS" postgresql-"$POSTGR_VERSIONS"-postgis-2.1 postgresql-"$POSTGR_VERSIONS"-postgis-scripts postgresql-"$POSTGR_VERSIONS"-postgis-2.1-scripts postgresql-plperl-"$POSTGR_VERSIONS"
	done
}

install_packages_1.4() #TODO: fix it!!!
{
	#POSTGR_VERSIONS="9.2|9.3"
	apt-get install bind9 dnsutils ntp openssh-server zip rsync libpam-mount apache2 libapache2-mod-php5 libapache2-mod-auth-kerb php5 php5-curl php5-gd php5-pgsql php5-xmlrpc php5-xsl php5-imagick  dovecot-imapd dovecot-gssapi exim4-daemon-heavy
	for version in "${POSTGR_VERSIONS[@]}"; do 
		apt-get install postgresql-"$version" postgresql-client-"$version" postgresql-contrib-"$version" postgresql-doc-"$version" postgresql-pltcl-"$version"
	done
}


install_packages_1.3() #TODO: fix it!!!
{
	apt-get install rsync openssh-server bind9 dnsutils zip libpam-mount postgresql postgresql-contrib postgresql-pltcl-9.1 fly-admin-postgres apache2 libapache2-mod-php5 libapache2-mod-auth-kerb php5 php5-curl php5-gd php5-pgsql php5-xmlrpc php5-xsl php5-imagick
}
install_packages_1.2() #TODO: fix it!!!
{
	apt-get install bind9 dnsutils ntp openssh-server zip rsync libpam-mount apache2 libapache2-mod-php5 libapache2-mod-auth-kerb php5 php5-curl php5-gd php5-pgsql php5-xmlrpc php5-xsl php5-imagick postgresql-9.2 postgresql-client-9.2 postgresql-contrib-9.2 postgresql-doc-9.2 postgresql-pltcl-9.2 dovecot-imapd dovecot-gssapi exim4-daemon-heavy
}


install_packages()
{
	echo "Here will be checked mounted cdrom"

	ASTRA_VERSION=$(lsb_release -a 2>/dev/null | grep Release | awk {'print $2'})
	eval "install_packages_$ASTRA_VERSION"
#if [[ ! -z "$ASTRA_VERSION" ]]; then
#	eval "install_packages_$ASTRA_VERSION"
#fi
}


conf_bash()
{
	echo "export PS1='\e]2;[\u@\h]\a[\e[31;1m\t\e[0m]\n\u@\h:\w>'" >> /root/.bashrc
	[[ `/bin/grep -i histfilesize /root/.bashrc` ]] || /bin/echo "HISTFILESIZE=10000" >> /root/.bashrc #TODO: fix it
	[[ `/bin/grep -i histtimeformat /root/.bashrc` ]] || /bin/echo 'HISTTIMEFORMAT="%y-%m-%d %T "' >> /root/.bashrc

	[[ `/bin/cat /var/spool/cron/crontabs/root | /bin/grep -i history` ]] || /bin/echo "0 4 * * * history | /usr/bin/tee /root/reglament/bash_log.txt /var/log/bash_log.txt" >> /var/spool/cron/crontabs/root
	/etc/init.d/cron restart

}


conf_network() #TODO: fix it!!! Need to understand, what int is in network Function must fix udev rules
{
	cp /etc/network/interfaces{,_bak}
	echo "auto lo
iface lo inet loopback
auto eth0
iface eth0 inet static
	address $ARM_IP
	netmask 255.255.255.0" > /etc/network/interfaces

echo "search $DOMAIN_NAME
nameserver $SERVER_IP" > /etc/resolv.conf

	cp /etc/hosts{,_bak}
	echo "127.0.0.1		localhost.localdomain	localhost
$ARM_IP      $ARM_NAME.$DOMAIN_NAME		$ARM_NAME" > /etc/hosts
}


conf_grub() #TODO dont know how it will be in version less 1.4
{
	cp /boot/grub/grub.cfg{,_bak}
	sed -i '/^menuentry.*pax.*\|^menuentry.*recovery.*/,/}/d' /boot/grub/grub.cfg #actual for version 1.4
}


conf_bind() #TODO tabs and spaces!!!
{
	echo "\$TTL 604800
@ IN SOA $SERVER_NAME.$DOMAIN_NAME. $SERVER_NAME.$DOMAIN_NAME. (
20160901 ; Serial
604800 ; Refresh
86400 ; Retry
2419200 ; Expire
604800 ) ; Negative Cache TTL
			IN			NS		$SERVER_NAME
@			IN		MX 10	$SERVER_NAME
$SERVER_NAME			IN		A		$SERVER_IP
;srv2			IN		A		192.168.10.2 ;TODO FIX IT
srv-print1	IN		A		192.168.10.21
\$GENERATE 101-200 arm\${\$-100}    IN      A       192.168.10.\$" > /etc/bind/db.$DOMAIN_NAME #TODO CHECK IT"

echo "\$TTL 604800
@ IN SOA $SERVER_NAME.$DOMAIN_NAME. root.$SERVER_NAME.$DOMAIN_NAME. (
2011091301 ; Serial
604800 ; Refresh
86400 ; Retry
2419200 ; Expire
604800 ) ; Negative Cache TTL

			IN	NS	$SERVER_NAME.$DOMAIN_NAME.
1			IN	PTR	$SERVER_NAME.$DOMAIN_NAME.
2			IN	PTR	srv2.$DOMAIN_NAME.
21			IN	PTR	srv-print1.$DOMAIN_NAME.
101			IN	PTR	arm01.$DOMAIN_NAME.
\$GENERATE 101-200 arm\${
-100}    IN      A       192.168.10.\$" > /etc/bind/db.192.168.10

	echo ". 3600000 IN NS A.ROOT-SERVERS.NET.
A.ROOT-SERVERS.NET.			3600000		A		$SERVER_IP" > /etc/bind/db.root

	echo /usr/sbin/named >> /etc/parsec/privsock.conf

	[ -f /etc/rc2.d/S18bind9 ] && unlink /etc/rc2.d/S18bind9 || ln -s /etc/init.d/bind9 /etc/rc2.d/S98bind9

	service bind9 restart
}


conf_ntp_client()
{
	cp /etc/ntp.conf{,_bak}
	echo "driftfile /var/lib/ntp/ntp.drift
statsdir /var/log/ntpstats/
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server 192.168.10.1 iburst
restrict 192.168.10.1" > /etc/ntp.conf

	sed -i "2s/^/\/usr\/sbin\/ntpdate -u $SERVER_NAME\n/" /etc/init.d/ntp

	/usr/sbin/ntpdate -u $SERVER_NAME

	[ -x /etc/rc2.d/S18nstp ] && unlink /etc/rc2.d/S18ntp
	[ `ls /etc/rc2.d/ | grep ntp` ] || ln -s /etc/init.d/ntp /etc/rc2.d/S98ntp

}


conf_ntp_server()
{
	cp /etc/ntp.conf{,_bak}
	echo "driftfile /var/lib/ntp/ntp.drift
statsdir /var/log/ntpstats/
statistics loopstats peerstats clockstats
filegen loopstats file loopstats type day enable
filegen peerstats file peerstats type day enable
filegen clockstats file clockstats type day enable
server 127.127.1.0
fudge 127.127.1.0 stratum 0
restrict -4 default kod notrap nomodify nopeer noquery
restrict -6 default kod notrap nomodify nopeer noquery
restrict 127.0.0.1
restrict 192.168.10.0" > /etc/ntp.conf

#[ -x /etc/rc2.d/S18nstp ] && unlink /etc/rc2.d/S18ntp
	update-rc.d ntp defaults
	service ntp restart
#[ `ls /etc/rc2.d/ | grep ntp` ] || ln -s /etc/init.d/ntp /etc/rc2.d/S98ntp
}


conf_ald_server() #TODO or replacement?
{
	cp /etc/ald/ald.conf{,_bak}
	sed -i "/^DOMAIN=.*/c\DOMAIN=.$DOMAIN_NAME" /etc/ald/ald.conf
	sed -i "/^SERVER=.*/c\SERVER=$SERVER_NAME.$DOMAIN_NAME" /etc/ald/ald.conf
	sed -i "/^TICKET_MAX_LIFE=.*/c\TICKET_MAX_LIFE=7d" /etc/ald/ald.conf
	sed -i "/^TICKET_MAX_RENEWABLE_LIFE=.*/c\TICKET_MAX_RENEWABLE_LIFE=14d" /etc/ald/ald.conf
	sed -i "/^SERVER_ON=.*/c\SERVER_ON=1" /etc/ald/ald.conf
	sed -i "/^CLIENT_ON=.*/c\CLIENT_ON=1" /etc/ald/ald.conf
	ald-init init #TODO switch it to interactive mode: ald-init init -f
}

########

conf_apache_pam()
{
#TODO configure
#TODO install apache pam

}

conf_apache_krb()
{
	a2enmod auth_kerb
	a2enmod rewrite

	[[ -x /DATA/www ]] || mkdir -p /DATA/www
	cp /etc/apache2/sites-available/default{,_bak}
	echo "<VirtualHost *:80>
	ServerAdmin webmaster@localhost

	DocumentRoot /DATA/www
	<Directory />
		Options FollowSymLinks
		AllowOverride None
	</Directory>
	<Directory /DATA/www/>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride All
		Order allow,deny
		allow from all
		AuthType Kerberos
		KrbAuthRealms $DOMAIN_NAME.RU
		KrbServiceName HTTP/$SERVER_NAME.$DOMAIN_NAME
		Krb5Keytab /etc/apache2/keytab
		KrbSaveCredentials on
		KrbMethodNegotiate on
		KrbMethodK5Passwd off
	</Directory>
ErrorLog \${APACHE_LOG_DIR}/error.log
	LogLevel warn

	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>" > /etc/apache2/sites-enabled/000-default

	ald-admin service-add HTTP/$SERVER_NAME.$DOMAIN_NAME
	ald-admin sgroup-svc-add HTTP/$SERVER_NAME.$DOMAIN_NAME  --sgroup=mac
	ald-client update-svc-keytab HTTP/$SERVER_NAME.$DOMAIN_NAME  --ktfile="/etc/apache2/keytab"
	chown www-data /etc/apache2/keytab
	chmod 644 /etc/apache2/keytab

	chmod 1777 /var/lib/php5
	pdp-flbl 3:0:0xffffffffffffffff:0x5 /var/
	pdp-flbl 3:0:0xffffffffffffffff:0x5 /var/lib
	pdp-flbl 3:0:0xffffffffffffffff:0x5 /var/lib/php5/


#sed -i "/DOMAIN=*/c\DOMAIN=.$DOMAIN_NAME" /etc/ald/ald.conf
	cp /etc/php5/apache2/php.ini{,_bak}
	sed -i "/upload_max_filesize = */c\upload_max_filesize = 2048M" /etc/php5/apache2/php.ini
	sed -i "/memory_limit = */c\memory_limit = 2048M" /etc/php5/apache2/php.ini
	sed -i "/post_max_size = */c\post_max_size = 2048M" /etc/php5/apache2/php.ini
	sed -i "/max_execution_time = */c\max_execution_time = 3600" /etc/php5/apache2/php.ini
	sed -i "/date.timezone = */c\date.timezone = 'Europe/Moscow'" /etc/php5/apache2/php.ini

	service apache2 restart
}

conf_postgres()
{
	
	echo "Creating principals:"
	ald-admin service-add postgres/$SERVER_NAME.$DOMAIN_NAME
	ald-admin sgroup-svc-add postgres/$SERVER_NAME.$DOMAIN_NAME --sgroup=mac
	ald-client update-svc-keytab postgres/$SERVER_NAME.$DOMAIN_NAME --ktfile="/etc/postgresql/krb5.keytab"
	chown postgres /etc/postgresql/krb5.keytab

	MESSAGE="Enter used cluster encoding. It's CP1251 or UTF-8 only: "
	PG_ENCODING=''
	#while [[ PG_ENCODING != "CP1251|UTF-8" || PG_ENCODING != "UTF-8" ]]; do
	while [[ $PG_ENCODING != @(CP1251|UTF-8) ]]; do
	{
		user_input "Enter postgres encoding\(its CP1251 or UTF-8 \)" PG_ENCODING
	}
	done


	locale-gen
	[ -x /DATA/ ] || mkdir -p /DATA/

	sed -i "/# ru_RU.UTF-8/c\ru_RU.$PG_ENCODING" /etc/locale.gen
	sed -i "/# en_US.UTF-8/c\en_US.$PG_ENCODING" /etc/locale.gen

	for version in "${POSTGR_VERSIONS[@]}"; do 
		pg_dropcluster $version main --stop
		pg_createcluster --locale=ru_RU.$PG_ENCODING -d /DATA/main_$version $version main
		cp /etc/postgresql/$version/main/pg_hba.conf{,_bak}

		echo "local	all	postgres								peer
host		all	all			127.0.0.1	255.255.255.255			gss
host		all	postgres		192.168.10.1 	255.255.255.255			pam
host		all	all			192.168.10.0	255.255.255.0			gss" > /etc/postgresql/$version/main/pg_hba.conf  

		sed -i -e "s/listen_addresses = '.*'/listen_addresses = \'\*\'/" /etc/postgresql/$version/main/postgresql.conf
		sed -i -e "s/.*krb_srvname.*'/krb_srvname = 'postgres'/" /etc/postgresql/$version/main/postgresql.conf
		sed -i -e "s/.*ac_ignore_socket_maclabel.*/ac_ignore_socket_maclabel = false/" /etc/postgresql/$version/main/postgresql.conf
		sed -i -e "s/.*lc_messages.*'/lc_messages = 'C'/" /etc/postgresql/$version/main/postgresql.conf 
		
		if [[ ( $version != '9.3' ) && ( $version != '9.4' ) ]]; then
			sed -i -e "s/.*ac_enable_sequence_mac.*/ac_enable_sequence_mac = false/" /etc/postgresql/$version/main/postgresql.conf
		fi
		
		pg_tune

	done
}

pg_tune() #TODO: to be continued
{
	total_mem=$(cat /proc/meminfo | grep MemTotal | awk '{print $2}')
	shared_buffers=$((total_mem /  6))
	work_mem=$(((total_mem - shared_buffers) / 20))
	maintenance_work_mem=$(((total_mem - shared_buffers) / 4))
	
	sed -i "/^.\?shared_buffers = */c\shared_buffers = $shared_buffers" /etc/postgresql/$version/main/postgresql.conf
	sed -i "/^.\?work_mem = */c\work_mem = $work_mem" /etc/postgresql/$version/main/postgresql.conf
	sed -i "/^.\?maintenance_work_mem = */c\maintenance_work_mem = $maintenance_work_mem" /etc/postgresql/$version/main/postgresql.conf
	
	#echo "page_size=`getconf PAGE_SIZE`
	#phys_pages=`getconf _PHYS_PAGES`
	#shmall=`expr $phys_pages / 2`
	#shmmax=`expr $shmall \* $page_size`
	#echo kernel.shmmax=$shmmax
	#echo kernel.shmall=$shmall
	#fsync=off" >> /etc/sysctl.conf
	
	#sysctl -p


	if [[ $POSTGR_VERSIONS == '8.4' ]]; then
		service postgresql-8.4 restart
	else
		service postgresql restart
	fi
}


type_of_arm()
{
	echo "What type of arm is it: server, user arm or obi arm?"
	select obidl in "OBI" "USER" "SERVER"; do
		case $obidl in
			OBI ) mount /opt/astra-se-1.4.iso /media/cdrom && apt-get install dnsutils zip libpam-mount fly-admin-smc smc-ald smc-ald-audit smc-ald-capabilities smc-ald-device-ctrl smc-ald-hosts smc-ald-mac smc-ald-policy smc-ald-services smc-ald-tasks smc-ald-trusted smc-ald-users smc-audit smc-capabilities smc-common smc-config-editor smc-device-ctrl smc-local smc-mac smc-policy smc-sysctl smc-users || echo "installing packages failed"
			break;;
			DL ) mount /opt/astra-se-1.4.iso /media/cdrom && apt-get install openssh-server dnsutils zip libpam-mount || echo "installing packages failed"
			break;;
			SERVER ) mount /opt/astra-se-1.4.iso /media/cdrom && apt-get install openssh-server dnsutils zip libpam-mount || echo "installing packages failed"
			break;;
		esac
	done
}

#==================================================> Run here

user_input_yn()
{
	while true; do
		read -p "$1 (press Y/y or N/n) " yn
		case $yn in
			[Yy]* ) eval $2; break;;
			[Nn]* ) break;;
			* ) echo "Invalid answer, please try again.";;
		esac
	done
}

new_server()
{
	while :; do
	echo "
Press key to enter menu:
1. Setup all packages with confirmation
2. Configure server as all-in-one server
3. Configure server as web-server
4. Configure server as database-server
0. Exit to main menu"
	read CHOISE
	case "$CHOISE" in
		"1" ) 
		get_variables_server
		install_packages		
		user_input_yn "Configure bash?" conf_bash
		user_input_yn "Configure network?" conf_network
		user_input_yn "Configure grub?" conf_grub
		user_input_yn "Configure bind?" conf_bind
		user_input_yn "Configure ntp server?" conf_ntp_server
		user_input_yn "Configure ald server?" conf_ald_server
		user_input_yn "Configure apache server(krb)?" conf_apache_krb
		user_input_yn "Configure postgres server(krb)?" conf_postgres
		;;
		"2" ) 
		echo "Here we configuring server as web-server"	
		;;
		"3" ) 
		echo "Here we configuring server as database-server"			
		;;
		"0" ) 
		break	;;
		* ) echo "Invalid key, please try again. "
		;;	
	esac
	done
}

old_server()
{
	echo "nothing to do for old_server"
}

new_client()
{
	echo "nothing to do for new_client"
}

menu()
{
	while :; do
	echo "
Press key to enter menu:
1. Configure new server
2. Add packages for configured yet server
3. Configure new client
4. Open console
5. Open MC
8. Version
9. About
0. Exit
"
	read CHOISE
	case "$CHOISE" in
		"1" ) 
		new_server
		;;
		"2" ) 
		old_server	
		;;
		"3" ) 
		new_client	
		;;
		"4" ) 
		echo "Onening terminal. Press ctrl+D to return to script"
		sleep 1
		/bin/bash
		;;
		"5" ) 
		echo "Onening MC. Press F10 to return to script"
		sleep 1
		/usr/bin/mc
		;;
		"8" ) 
		echo "Version $VERSION"
		;;
		"9" ) 
		echo "This script was started in 2016 and was released in 2018 by E.Eliseev in RusBITech."
		;;
		"0" ) 
		break
		;;
		* ) echo "Invalid key, please try again."
		;;
	esac
	done
}

#=======STARTS+HERE=======>
menu
