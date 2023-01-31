#Local hierarchy:
#       /-home
#         |-user
#           |-update.sh
#           |-DoNotStarve (install dir)
#           |-.klei
#             |-DoNotStarve
#               |-Cluster_1
#                 |-cluster_ini.txt
#                 |-cluster_token.txt
#                 |-Master
#                   |-modoverrides.lua
#                 |-Cave
#
#remote url:
#       modoverrides:https://gitee.com/resol1024/gserver/raw/master/DoNotStarve/modoverrides
#       save.zip:

#USER_HOME="/home/user/"
USER_HOME="/home/resol/"


update_mod(){
        MOD_CONF_PATH=$USER_HOME".klei/DoNotStarveTogether/Cluster_1/Master/modoverrides.lua"
        MOD_SET_PATH=$USER_HOME"DoNotStarve/mods/dedicated_server_mods_setup.lua"

        curl -L http://gitee.com/resol1024/gserver/raw/master/DoNotStarve/modoverrides > $MOD_CONF_PATH

        ids_str=`grep -o '\[\"workshop-[0-9]\{1,10\}\"\]' $MOD_CONF_PATH | grep -o '[0-9]\{1,10\}'`
        ids=(${ids_str// /})

        echo "" > $MOD_SET_PATH
        for id in ${ids[@]}
        do
                echo "ServerModSetup($id)" >> $MOD_SET_PATH
        done
}

update_backup(){
        rm -r $USER_HOME".klei/DoNotStarveTogether/Cluster_1"
        cp -r $USER_HOME"backup/Cluster_1" $USER_HOME".klei/DoNotStarveTogether/Cluster_1"

}

update_zip(){
        rm -r $USER_HOME".klei/DoNotStarveTogether/Cluster_1"
        unzip $USER_HOME"Cluster_1.zip" -d $SAVE_PATH
}

update_token(){
        TOKEN_PATH=$USER_HOME".klei/DoNotStarveTogether/Cluster_1/cluster_token.txt"
        curl -L http://gitee.com/resol1024/gserver/raw/master/DoNotStarve/cluster_token.txt > $TOKEN_PATH
}

restart(){
        #cd /home/resol/DoNotStarve/bin64
        #./"dontstarve_dedicated_server_nullrenderer_x64"

        if [ "`screen -list | grep -o Master`" != "Master" ];then
                screen -S Master | screen -d Master
        fi
        if [ "`screen -list | grep -o Cave`" != "Cave" ];then
                screen -S Cave | screen -d Cave
        fi

        screen -r Master -X stuff '\003'
        screen -r Cave   -X stuff '\003'
        echo "Master&Cave are stopping"
        echo "Master will be start after 3s"
        sleep 3
        echo "Master is starting"
        echo "Cave will be start after 5s"
        screen -r Master -X cd /home/resol/DoNotStarve/bin64
        screen -r Master -X stuff "./dontstarve_dedicated_server_nullrenderer_x64 -shard Master\n"

        sleep 5
        echo "Cave is starting"
        screen -r Cave -X cd /home/resol/DoNotStarve/bin64
        screen -r Cave -X stuff "./dontstarve_dedicated_server_nullrenderer_x64 -shard Caves\n"
        echo "Starting commands had been send,please check the result"
}




if [ $# = 0 ];then
        restart
elif [ "$1" = "-token" ];then
        update_token
elif [ "$1" = "-mod" ];then
        update_mod
elif [ "$1" = "-backup" ];then
        update_backup
        restart
elif [ "$1" = "-zip" ];then
        update_zip
else
        echo "unknow option"
fi
