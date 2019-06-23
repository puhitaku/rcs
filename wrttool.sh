tftpify() {
    if [ ! -f ./BSDmakefile ]; then
        echo 'You are out of openwrt root'
        return 1
    fi

    case "$#" in
        "0") depfn="deploy.bin" ;;
        "1") depfn=$1 ;;
        *)   echo "Usage: $0 [deploy_fn]"; return 1;;
    esac

    fn=$(find ./bin/targets/ -iname "*.bin" | peco)
    if [ "$fn" == "" ]; then
        return 1
    fi

    sudo cp $fn /srv/tftp/$depfn
    srv_nobody
}

srv_nobody() {
    sudo chown nobody:nobody -R /srv
}

