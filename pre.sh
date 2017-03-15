# NGX_DIR is an environment variable
if [ ! ${NGX_DIR} ]
then
    echo environment variable NGX_DIR not found
    exit 1
fi
NGX_BIN=${NGX_DIR}/sbin/nginx
NGX_CONF=${NGX_DIR}/conf

cp nginx_t.conf ${NGX_CONF}
if [ -s ${NGX_DIR}/logs/nginx_t.pid ]
then
    ${NGX_BIN} -c ${NGX_CONF}/nginx_t.conf -s reload
else
	${NGX_BIN} -c ${NGX_CONF}/nginx_t.conf
fi
