#!/bin/bash

version_pattern="^v[0-9]{1,}\.[0-9]{1,}\.[0-9]{1,}$"
#vX.Y.Z
init_version="v0.0.1"
work_dir=$(pwd)
script_dir=$(cd "$(dirname "$0")"; pwd)

function echo_red()
{
        echo -e "\033[31m$1 \033[0m"
}
function echo_green()
{
        echo -e "\033[32m$1 \033[0m"
}
function git_tag_logo()
{
    echo_green "====================================================="
    echo_green "       version format 1.0.0"
    echo_green "                      | | |--->working/bugfix"
    echo_green "                      | |----->add feature"
    echo_green "                      |------->struct revolution"
    echo_green "====================================================="
}

function version()
{
    git tag -l --sort=-v:refname |head -n 1
}

function format_version()
{
    version_now=$(version)
    if ! [[ $version_now =~ $version_pattern ]]
    then
        echo_red "version pattern is $version_now, but need pattern $init_version"
        echo_green "will change version pattern to $init_version, sure(y/n) ?"
        read format_input
        if [ $format_input != "y" ]
        then
            echo_green "Abort!"
            exit 1
        fi
        git_tag $init_version
        exit
    fi
}

function update_version()
{
    version_bit=$1
    z=$(version | awk -F'.' '{print $3}')
    y=$(version | awk -F'.' '{print $2}')
    x=$(version | awk -F'.' '{print $1}'|awk -F'v' '{print $2}')

    if [ $version_bit == "x" ]
    then
        let x+=1
        version_new="v"${x}.0.0
    elif [ $version_bit == "y" ]
    then
        let y+=1
        version_new="v"${x}.${y}.0
    else
        let z+=1
        version_new="v"${x}.${y}.${z}
    fi
    echo $version_new
}

function git_tag()
{
    version_now=$1
    git tag -a $version_now -m "升级到${version_now}版本"
    git push origin --tags
}

git_tag_logo

format_version

echo_green "plese chose struct revolution(x), add feature(y), working/bugfix(z) ?"

read -p "input(z): " update_type
pattern="^[xyz]$"
if ! [[ $update_type =~ $pattern ]]
then
    echo_red "Error:unknown input $update_type"
    exit -1
fi

version_now=$(version)
version_new=$(update_version $update_type)

echo_green "version is $version_now now, will upgrade to $version_new, sure(y/n)?"
read format_input
if [ $format_input != "y" ]
then
    echo_green "Abort!"
    exit 1
fi

git_tag $version_new