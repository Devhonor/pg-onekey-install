#!/bin/bash


function f_hn_dns(){
    print_log "1. Configuring hostname and dns begin"
    if [[ "${NIC_NAME}" == "" ]];then
        print_error_log "NIC_NAME must be specified"
        exit 99
    else
        check_nic_name=$(ip addr show ${NIC_NAME})
        status=$?
        if [ ${status} -eq 0 ];then
            get_ipaddr=$(ip addr show ${NIC_NAME} | grep 'inet\b' | awk '{print $2}' | cut -d/ -f1)
            sed -i "/${get_ipaddr}/d" /etc/hosts
            echo -e "${get_ipaddr}\t ${HOSTNAME}.com\t server" >>/etc/hosts
        else
            print_error_log "Please check network interface card name"
            exit 99
        fi
    fi
    hostnamectl set-hostname ${HOSTNAME}
    if [[ $? -eq 0 ]];then
            print_success_log "hostname configuration successfully!"
    else
            print_error_log "hostname configuration failure !"
    fi
    print_log "   Configuring hostname end"
}

function f_firewalld(){
    print_log "2. Checking firwalld begin"
    fire_status=$(systemctl status firewalld | grep running | awk -F'(' '{print $2}'| awk -F')' '{print $1}')
    if [[ "${fire_status}" == "running" ]];then 
        print_error_log "ERROR: firewall is running,please stopped it !"
        print_sub_log "Stoping firewalld begin"
        systemctl stop firewalld
        print_sub_log "Stoping firewalld end"

        print_sub_log "Stoping boot start active begin"
        systemctl disable firewalld
        print_sub_log "Stoping boot start active end"
    else
        print_sub_log "Firewall has been forbiden !"
    fi
    print_log "   Checking firwalld end"
}
function f_selinux(){
    print_log "3. Checking selinux begin"
    sf_status=$(getenforce)
    if [[ "${sf_status}" == "Disabled" ]];then 
        print_success_log "Selinux has been disabled"
    else
        sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
        print_error_log "Warning: Selinux is active,please disabled it using setenforce 0"
        setenforce 0
    fi
    print_log "   Checking selinux end"
}

function f_user(){
    install_user=$(egrep "${INSTALL_USER}" /etc/passwd | awk -F':' '{print $1}')
    print_log "4. Checking user and group begin "
    is_user=$(id ${INSTALL_USER} &>/dev/null)
    if [[ $? -eq 1 ]];then 
        print_error_log "ERROR: ${INSTALL_USER} user doesn't exists and will be added !"
        useradd -u 3000 ${INSTALL_USER}
        is_user=$(id ${INSTALL_USER} &>/dev/null)
        if [[ $? -eq 0 ]];then
            print_success_log "${INSTALL_USER} user has been added !"
        fi
    else 
        print_success_log "${INSTALL_USER} user already exists !"      
    fi
    print_log "   Checking user and group end "
}


function f_deps(){
    print_log "5. Checking software dependences and installing loss software begin"
    os_version=$(hostnamectl | grep Operating |awk '{print$5}' | awk -F. '{print $1}')
    if [[ "${os_version}" == "7" ]];then
        command_mode=yum
        while read line;do
            is_check_pkg=$(${command_mode} list installed | grep -w ${line} |awk '{print $1}' | wc -l)
            if [[ ${is_check_pkg} == "1" ]];then
                print_success_log "The package ${line} has been installed !"
            else 
                print_sub_log "The package ${line} will be installed !"
                ${command_mode} install -y ${line} >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
                error_check=$(egrep "Error: Unable to find a match" ${ERROR_LOG} | wc -l)
                if [ ${error_check} -ne 0 ];then
                    print_error_log "The package ${line} install failure"
                else
                    print_success_log "The package ${line} install successfully"
                fi
            fi
        done<${TOPLEVEL_DIR}/lib/pkglist
    elif [[ "${os_version}" == "8" ]];then
        command_mode=dnf
        while read line;do
            is_check_pkg=$(${command_mode} list installed | grep -w ${line} |awk '{print $1}' | wc -l)
            if [[ ${is_check_pkg} == "1" ]];then
                print_success_log "The package ${line} has been installed !"
            else 
                print_sub_log "The package ${line} will be installed !"
                ${command_mode} install -y ${line} >>${ERROR_LOG} 2>&1 >>${SUCCESS_LOG}
                error_check=$(egrep "Error: Unable to find a match" ${ERROR_LOG} | wc -l)
                if [ ${error_check} -ne 0 ];then
                    print_error_log "The package ${line} install failure"
                else
                    print_success_log "The package ${line} install successfully"
                fi
            fi
        done<${TOPLEVEL_DIR}/lib/pkglist
    else
        command_mode=dnf
    fi


    error_check=$(egrep "Error: Unable to find a match" ${ERROR_LOG} | wc -l)

    if [ ${error_check} -ne 0 ];then
        print_error_log "There have some erros in ${ERROR_LOG},please check it"
        exit 99
    fi

    
    print_log "   Checking software dependences and installing loss software end"
}

function f_kernel(){
    >/etc/sysctl.d/97-postgres-database-sysctl.conf
    print_log "6. Configuring kernel parameters begin"
    while read line;do
        echo ${line}>>/etc/sysctl.d/97-postgres-database-sysctl.conf
    done<${TOPLEVEL_DIR}/lib/kernelpara
    sysctl --system &>/dev/null
    print_success_log "Kernel parameter configuration completed !"
    print_log "   Configuring kernel parameters end"
}

function f_limit(){
    print_log "7. Configuring resource limits begin"
    while read line;do
        sed -i '/*/d' /etc/security/limits.conf 
        echo ${line}>>/etc/security/limits.conf 
    done<${TOPLEVEL_DIR}/lib/limits
    print_success_log "Resource limits configuration completed !"
    print_log "   Configuring resource limits end"
}

