#!/bin/sh
set -e


## init env
if [ ! -f /init.lock ];then
    grep '^\s\+#' -v /etc/raddb/mods-available/ldap |grep '^#' -v|grep '^$' -v > tmp.txt && mv tmp.txt /etc/raddb/mods-available/ldap
    sed "/localhost/a identity = \'${LDAP_ADMIN_ID}\'\npassword = ${LDAP_ADMIN_PASSWD}" /etc/raddb/mods-available/ldap -i
    sed "/localhost/s#.*#server = \'${LDAP_ADDR}\'#" /etc/raddb/mods-available/ldap -i
    sed "s#base_dn = 'dc=example,dc=org'#base_dn = \'${LDAP_BASE_DN}\'#" /etc/raddb/mods-available/ldap -i
    
    sed "$ aclient fb-ovpn {\n\tipaddr = 0.0.0.0/0\n\tsecret = ${SECRET}\n\tnastype = other\n}" /etc/raddb/clients.conf -i
    sed "s#1812#${RADIUS_SERVER_PORT}#" /etc/raddb/sites-enabled/yl_server -i
    ln -s /etc/raddb/mods-available/ldap /etc/raddb/mods-enabled/
    touch /init.lock
fi


# this if will check if the first argument is a flag
# but only works if all arguments require a hyphenated flag
# -v; -SL; -f arg; etc will work, but not arg1 arg2
if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    set -- freeradius "$@"
fi

# check for the expected command
if [ "$1" = 'freeradius' ]; then
    shift
    exec freeradius -X "$@"
fi

# many people are likely to call "radiusd" as well, so allow that
if [ "$1" = 'radiusd' ]; then
    shift
    exec freeradius -X "$@"
fi

# else default to run whatever the user wanted like "bash" or "sh"
exec "$@"
