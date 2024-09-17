#!/bin/bash
function create_os_user(){ 
    print_log "8. Configuration os user begin"
    
    if [[ "${INSTALL_USER}" == "" ]];then
        print_sub_log "Installation user default: postgres"
        INSTALL_USER=postgres
    else
        INSTALL_USER=${INSTALL_USER}
    fi
    is_exists_user=$(grep ${INSTALL_USER} /etc/passwd|wc -l)
    if [ ${is_exists_user} -eq 1 ];then
        print_sub_log "User ${INSTALL_USER} exists"
    else
        print_error_log "User ${INSTALL_USER} doesn't exists"
    fi

    print_sub_log "Create user ${INSTALL_USER} and group "

    useradd -u 3000 ${INSTALL_USER} >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    print_sub_log "Setting ${INSTALL_USER} user password"

    count=0
    max_attempts=3

    while [[ ${count} -lt ${max_attempts} ]]; do
        ((count++))
        read -p "Please input ${INSTALL_USER} os user's password: " passwd1
        read -p "Please confirm ${INSTALL_USER} os user's password: " passwd2

        if [[ "${passwd1}" == "${passwd2}" ]]; then
            echo ${passwd2} | passwd --stdin ${INSTALL_USER} &>/dev/null && {
                print_sub_log "Setting ${INSTALL_USER} user password successfully !"
                break
            }
        else
            if [[ $count -eq $max_attempts ]]; then
                print_error_log "Exceeded maximum attempts,exit."
                exit 99
            else
                print_error_log "The password doesn't match, please try again."
            fi
        fi
    done
    print_log "   Configuration os user end"
}

function mkdir_data_dir(){
    print_log "9. Configuration install directory begin"
    if [ -d ${PG_DATA} ];then
        print_sub_log "The data directory already exists"
        chown ${INSTALL_USER}.${INSTALL_USER} -R ${PG_DATA}
    else
        print_sub_log "The data directory doesn't exists and will be created"
        mkdir -p ${PG_DATA}
        TOP_DIR=$(dirname ${PG_DATA})
        chown ${INSTALL_USER}.${INSTALL_USER} -R ${TOP_DIR}
    fi
    print_log "   Configuration install directory end"
}
function compile_process(){
    print_log "10.Compiling installation begin"
    #Define compile parameter
    if [[ "${PAGE_SIZE}" == "" ]];then
        PAGE_SIZE=8
    else
        PAGE_SIZE=${PAGE_SIZE}
    fi
    if [[ "${PG_HOME}" == "" ]];then
        PG_HOME=/usr/local
    else
        PG_HOME=${PG_HOME}
    fi
    if [[ "${PGPORT}" == "" ]];then
        PGPORT=5432
    else
        PGPORT=${PGPORT}
    fi

    PARAMETERS="--prefix=${PG_HOME} --with-pgport=${PGPORT} --with-blocksize=${PAGE_SIZE} --with-openssl --with-readline --with-lz4 --with-zlib --with-ldap --with-pam  --with-perl --with-tcl --with-python --with-libxml --with-libxslt --with-gssapi --with-uuid=e2fs --with-selinux --with-llvm"

    SOURCE_DIR_NAME=$(basename ${SOFTWARE_PACKAGE_PATH} .tar.bz2)
    PARENTDIR=$(dirname "$SOFTWARE_PACKAGE_PATH")
    tar -jxf ${SOFTWARE_PACKAGE_PATH} -C ${PARENTDIR}
    cd ${PARENTDIR}/${SOURCE_DIR_NAME};
    cpucnt=$(getconf _NPROCESSORS_ONLN)
    ./configure ${PARAMETERS} >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}

    #checking error

    errorcnt=$(egrep -wi "error" ${ERROR_LOG} | wc -l)

    if [[ "${errorcnt}" -ge 1 ]];then
        print_error_log "ERROR:Please checking more information from log ${ERROR_LOG}"
        exit 99
    fi

    #begining compile
    make -j${cpucnt} world >>${COMPILE_ERROR} 2>&1 >>${SUCCESS_LOG}
    c_errorcnt=$(egrep -wi "error" ${COMPILE_ERROR} | wc -l)
    if [[ "${c_errorcnt}" -ge 1 ]];then
        print_error_log "ERROR:Please checking more information from log ${COMPILE_ERROR}"
        exit 99
    fi

    #beging install
    make -j${cpucnt} install-world >>${COMPILE_ERROR} 2>&1 >>${SUCCESS_LOG}

    print_log "   Compiling installation end"
}

function config_env(){
    print_log "11.Configuring ${INSTALL_USER} user environment begin"
    su - ${INSTALL_USER}&>/dev/null<<EOF
        sed -i "/export/d" ~/.bashrc
EOF
    su - ${INSTALL_USER}&>/dev/null<<EOF
        echo "export PG_HOME=${PG_HOME}" >>~/.bashrc
        echo "export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}" >>~/.bashrc
        echo "export PATH=${PATH}" >>~/.bashrc
EOF
    print_log "   Configuring ${INSTALL_USER} user environment end"
}

function init_dbcluster(){
    print_log "12.Initialize PostgreSQL database cluster begin"
    if [[ "${SUPERADMIN}" == "" ]];then
        SUPERADMIN=postgres
    else
        SUPERADMIN=${SUPERADMIN}
    fi
    if [[ "${AUTHMETHOD}" == "" ]];then
        AUTHMETHOD=trust
    else
        AUTHMETHOD=${AUTHMETHOD}
    fi 
    if [[ "${SERVERENCODE}" == "" ]];then
        SERVERENCODE=utf8
    else
        SERVERENCODE=${SERVERENCODE}
    fi     
    su - ${INSTALL_USER} -c "initdb -D ${PG_DATA} -k --auth=${AUTHMETHOD} --encoding=${SERVERENCODE} -U ${INSTALL_USER}" >>${COMPILE_ERROR} 2>&1 >>${SUCCESS_LOG}
    print_log "   Initialize PostgreSQL database cluster end"
}

function db_verify(){
    print_log "13.Verifying database connection begin"
    su - ${INSTALL_USER} -c "pg_ctl start -D ${PG_DATA} -l /tmp/logfile" >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
    res=$(${PG_HOME}/bin/psql -U ${INSTALL_USER} -p ${PGPORT} -d postgres -Atq -c 'select 1')
    if [[ "${res}" == "1" ]];then
        print_sub_log "Connection successfully !"
    fi
    print_log "   Verifying database connection end"  
} 


