#!/bin/bash
# Nodes
RED='\033[1;31m'
GREEN='\033[01;32m'
NC='\033[0m' # No Color
bin="./bin"

options=("18.224.0.169" "52.14.180.128" "18.221.62.255" "52.14.5.83"  "Upload" "Start All" "Stop All" "Remove chain data" "Quit")
echo "Availible nodes:"
print_list(){
for ((i = 0; i < ${#options[@]}; ++i)); do
    # bash arrays are 0-indexed
    position=$(( $i + 1 ))
    echo "$position) ${options[$i]}"
done
}    
upload(){

for ((i = 0; i < ${#options[@]}-5; ++i)); do
    echo -e "* ${RED} ${options[$i]} ${NC} *"
     ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo mkdir -p /home/release
     ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo rm -rv /home/release/*  
     echo "* UPLOADING"
     rsync -ave 'ssh -i block.pem' --info=progress2  --timeout=5 --rsync-path="sudo rsync" $bin/gess  ubuntu@${options[$i]}:/home/release/gess
    echo -e "* ${GREEN} DONE ${NC} *"
done
}
start_process(){

for ((i = 0; i < ${#options[@]}-5; ++i)); do
   echo -e "* Starting node  ${RED} ${options[$i]} ${NC} *"
    ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo pkill gess
    ipstr=$( ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} hostname -I)
    ip4="$(echo "${ipstr}" | sed -e 's/[[:space:]]*$//')"
   echo  sudo /home/release/gess  --testnet --rpc  --rpcaddr $ip4 --rpcapi eth,net,web3,admin,miner,debug,personal  --nat extip:${options[$i]}
   ssh -i block.pem -o ConnectTimeout=5 ubuntu@${options[$i]} nohup sudo /home/release/gess  --testnet --cache=2048 --rpc  --rpcaddr $ip4 --rpcapi eth,net,web3,admin,miner,debug,personal  --nat extip:${options[$i]} > /dev/null 2>&1 &
   
    echo -e "* ${GREEN} DONE ${NC} *"
 done  
}
stop_process(){

for ((i = 0; i < ${#options[@]}-5; ++i)); do
   echo -e "* Starting node  ${RED} ${options[$i]} ${NC} *"
    ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo pkill gess
    ipstr=$( ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} hostname -I)
    ip4="$(echo "${ipstr}" | sed -e 's/[[:space:]]*$//')"
   echo "Press Ctrl+C to continue loading ..."
   echo  ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo pkill gess 
   ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo pkill gess 
    echo -e "* ${GREEN} DONE ${NC} *"
 done  
}
remove_chain(){

for ((i = 0; i < ${#options[@]}-5; ++i)); do
   echo -e "*  NODE  ${RED} ${options[$i]} ${NC} *"
    ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} sudo pkill gess
    ipstr=$( ssh -i block.pem -o ConnectTimeout=5  ubuntu@${options[$i]} hostname -I)
    ip4="$(echo "${ipstr}" | sed -e 's/[[:space:]]*$//')"
   echo "Press Ctrl+C to continue loading ..."
   echo  ssh -i block.pem -o ConnectTimeout=5 -Y ubuntu@${options[$i]} sudo rm -rv 	/home/ubuntu/.essentia
   ssh -i block.pem -o ConnectTimeout=5 -Y ubuntu@${options[$i]} sudo rm -rv 	/home/ubuntu/.essentia
   echo  ssh -i block.pem -o ConnectTimeout=5 -Y ubuntu@${options[$i]} sudo rm -rv 	/home/ubuntu/.esshash
   ssh -i block.pem -o ConnectTimeout=5 -Y ubuntu@${options[$i]} sudo rm -rv 	/home/ubuntu/.esshash
    echo -e "* ${GREEN} DONE ${NC} *"
 done  
}
echo "**********************************************************"
PS3='Select:' 
select opt in "${options[@]}"
do
    case $opt in
        "18.224.0.169")
	    clear
	echo "**** ${opt} ****"
            ssh -i block.pem ubuntu@$opt
	    print_list
	    ;;
        "52.14.180.128")
	    clear
	echo "**** ${opt} ****"
            ssh -i block.pem ubuntu@$opt
           print_list
            ;;
        "18.221.62.255")
	    clear
	echo "**** ${opt} ****"
            clear
            ssh -i block.pem ubuntu@$opt
            print_list
            ;; 
        "52.14.5.83")
	echo "**** ${opt} ****"
            clear
            ssh -i block.pem ubuntu@$opt
            print_list
            ;; 
	"Upload")
		upload
		print_list
	    ;;	
	"Stop All")
		stop_process
		print_list
	    ;;	
    "Start All")
        start_process
		print_list
	    ;;	
	"Remove chain data")
        remove_chain
		print_list
	;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done
