#!/bin/bash
#   FreeSWITCH Installation script for CentOS 5.5/5.6
#   and Debian based distros (Debian 5.0 , Ubuntu 10.04 and above)
#   Copyright (C) <2011>  <Star2Billing S.L> 
#This program is free software; you can redistribute it and/or
#modify it under the terms of the GNU General Public License
#as published by the Free Software Foundation; either version 2
#of the License, or (at your option) any later version.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program; if not, write to the Free Software
#Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

# To download this script direct to your server type
#wget --no-check-certificate https://raw.github.com/Star2Billing/newfies-dialer/master/install/freeswitch/install-freeswitch.sh
#
#TODO: memcache



# Identify Linux Distribution type
if [ -f /etc/debian_version ] ; then
    DIST='DEBIAN'
elif [ -f /etc/redhat-release ] ; then
    DIST='CENTOS'
else
    echo ""
    echo "This Installer should be run on a CentOS or a Debian based system"
    echo ""
    exit 1
fi


FS_CONF_PATH=https://raw.github.com/Star2Billing/newfies-dialer/master/install/freeswitch-conf
FS_INIT_PATH=https://raw.github.com/Star2Billing/newfies-dialer/master/install/freeswitch-init
FS_GIT_REPO=git://git.freeswitch.org/freeswitch.git
FS_INSTALLED_PATH=/usr/local/freeswitch

#####################################################
FS_BASE_PATH=/usr/src/
#####################################################

CURRENT_PATH=$PWD

clear
echo ""
echo "FreeSWITCH will be installed in $FS_INSTALLED_PATH"
echo "Press Enter to continue or CTRL-C to exit"
echo ""
read INPUT


echo "Setting up Prerequisites and Dependencies for FreeSWITCH"
case $DIST in
    'DEBIAN')
        apt-get -y update
        apt-get -y install autoconf automake autotools-dev binutils bison build-essential cpp curl flex g++ gcc git-core libaudiofile-dev libc6-dev libdb-dev libexpat1 libgdbm-dev libgnutls-dev libmcrypt-dev libncurses5-dev libnewt-dev libpcre3 libpopt-dev libsctp-dev libsqlite3-dev libtiff4 libtiff4-dev libtool libx11-dev libxml2 libxml2-dev lksctp-tools lynx m4 make mcrypt ncftp nmap openssl sox sqlite3 ssl-cert ssl-cert unixodbc-dev unzip zip zlib1g-dev zlib1g-dev
        apt-get -y install libssl-dev pkg-config
        apt-get -y install libvorbis0a libogg0 libogg-dev libvorbis-dev
        ;;
    'CENTOS')
        yum -y update
        yum -y install autoconf automake bzip2 cpio curl curl-devel curl-devel expat-devel fileutils gcc-c++ gettext-devel gnutls-devel libjpeg-devel libogg-devel libtiff-devel libtool libvorbis-devel make ncurses-devel nmap openssl openssl-devel openssl-devel perl patch unixODBC unixODBC-devel unzip wget zip zlib zlib-devel

        #install the RPMFORGE Repository
        if [ ! -f /etc/yum.repos.d/rpmforge.repo ];
            then
                # Install RPMFORGE Repo
        rpm --import http://apt.sw.be/RPM-GPG-KEY.dag.txt
        echo '
[rpmforge]
name = Red Hat Enterprise $releasever - RPMforge.net - dag
mirrorlist = http://apt.sw.be/redhat/el5/en/mirrors-rpmforge
enabled = 0
protect = 0
gpgkey = file:///etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-dag
gpgcheck = 1
' > /etc/yum.repos.d/rpmforge.repo
        fi

        yum -y --enablerepo=rpmforge install git-core
    ;;
esac

# Install FreeSWITCH
cd $FS_BASE_PATH
git clone $FS_GIT_REPO
cd $FS_BASE_PATH/freeswitch
sh bootstrap.sh && ./configure --prefix=/usr/local/freeswitch
[ -f modules.conf ] && cp modules.conf modules.conf.bak
sed -i -e \
"s/#applications\/mod_curl/applications\/mod_curl/g" \
-e "s/#asr_tts\/mod_flite/asr_tts\/mod_flite/g" \
-e "s/#asr_tts\/mod_tts_commandline/asr_tts\/mod_tts_commandline/g" \
-e "s/#formats\/mod_shout/formats\/mod_shout/g" \
-e "s/#endpoints\/mod_dingaling/endpoints\/mod_dingaling/g" \
-e "s/#formats\/mod_shell_stream/formats\/mod_shell_stream/g" \
-e "s/#say\/mod_say_de/say\/mod_say_de/g" \
-e "s/#say\/mod_say_es/say\/mod_say_es/g" \
-e "s/#say\/mod_say_fr/say\/mod_say_fr/g" \
-e "s/#say\/mod_say_it/say\/mod_say_it/g" \
-e "s/#say\/mod_say_nl/say\/mod_say_nl/g" \
-e "s/#say\/mod_say_ru/say\/mod_say_ru/g" \
-e "s/#say\/mod_say_zh/say\/mod_say_zh/g" \
-e "s/#say\/mod_say_hu/say\/mod_say_hu/g" \
-e "s/#say\/mod_say_th/say\/mod_say_th/g" \
-e "s/#xml_int\/mod_xml_cdr/xml_int\/mod_xml_cdr/g" \
modules.conf
make && make install && make sounds-install && make moh-install

# Enable FreeSWITCH modules
cd $FS_INSTALLED_PATH/conf/autoload_configs/
[ -f modules.conf.xml ] && cp modules.conf.xml modules.conf.xml.bak
sed -i -r \
-e "s/<\!--\s?<load module=\"mod_xml_curl\"\/>\s?-->/<load module=\"mod_xml_curl\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_xml_cdr\"\/>\s?-->/<load module=\"mod_xml_cdr\"\/>/g" \
-e  "s/<\!--\s?<load module=\"mod_dingaling\"\/>\s?-->/<load module=\"mod_dingaling\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_shout\"\/>\s?-->/<load module=\"mod_shout\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_tts_commandline\"\/>\s?-->/<load module=\"mod_tts_commandline\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_flite\"\/>\s?-->/<load module=\"mod_flite\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_say_ru\"\/>\s?-->/<load module=\"mod_say_ru\"\/>/g" \
-e "s/<\!--\s?<load module=\"mod_say_zh\"\/>\s?-->/<load module=\"mod_say_zh\"\/>/g" \
-e 's/mod_say_zh.*$/&\n    <load module="mod_say_de"\/>\n    <load module="mod_say_es"\/>\n    <load module="mod_say_fr"\/>\n    <load module="mod_say_it"\/>\n    <load module="mod_say_nl"\/>\n    <load module="mod_say_hu"\/>\n    <load module="mod_say_th"\/>/' \
modules.conf.xml


#Configure Dialplan
cd $FS_INSTALLED_PATH/conf/dialplan/

# Place Plivo Default Dialplan in FreeSWITCH
[ -f default.xml ] && mv default.xml default.xml.bak
wget --no-check-certificate $FS_CONF_PATH/default.xml -O default.xml

# Place Plivo Public Dialplan in FreeSWITCH
[ -f public.xml ] && mv public.xml public.xml.bak
wget --no-check-certificate $FS_CONF_PATH/public.xml -O public.xml


#Configure XML CDR
cd $FS_INSTALLED_PATH/conf/autoload_configs/

#this is commented as we don't use xml_cdr anymore
## Place Newfies XML CDR conf in FreeSWITCH
#[ -f xml_cdr.conf.xml ] && mv xml_cdr.conf.xml xml_cdr.conf.xml.bak
#wget --no-check-certificate $FS_CONF_PATH/xml_cdr.conf.xml -O xml_cdr.conf.xml
#create dir to store send error of CDR
#mkdir /usr/local/freeswitch/log/err_xml_cdr/

#Return to current path
cd $CURRENT_PATH

#Add alias fs_cli
chk=`grep "fs_cli" ~/.bashrc|wc -l`
if [ $chk -lt 1 ] ; then
    echo "alias fs_cli='/usr/local/freeswitch/bin/fs_cli'" >> ~/.bashrc
fi    

case $DIST in
    'DEBIAN')
        #Install init.d script
        wget --no-check-certificate $FS_INIT_PATH/debian/freeswitch -O /etc/init.d/freeswitch
        chmod 0755 /etc/init.d/freeswitch
        cd /etc/init.d; update-rc.d freeswitch defaults 90
     ;;
    'CENTOS')
        #Install init.d script
        wget --no-check-certificate $FS_INIT_PATH/centos/freeswitch -O /etc/init.d/freeswitch
        chmod 0755 /etc/init.d/freeswitch
        chkconfig --add freeswitch
        chkconfig --level 2345 freeswitch on
    ;;
esac



# Install Complete
#clear
echo ""
echo ""
echo ""
echo "**************************************************************"
echo "Congratulations, FreeSWITCH is now installed at '$FS_INSTALLED_PATH'"
echo "**************************************************************"
echo
echo "* To Start FreeSWITCH in foreground :"
echo "    '$FS_INSTALLED_PATH/bin/freeswitch'"
echo
echo "* To Start FreeSWITCH in background :"
echo "    '$FS_INSTALLED_PATH/bin/freeswitch -nc'"
echo
echo "**************************************************************"
echo ""
echo ""
