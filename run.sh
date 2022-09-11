#!/bin/bash

login() {
    if [[ "$2" != null && "$3" != null ]]; then
        echo "-> login to $1"
        docker login -u "$2" -p "$3" "$1"
        echo
    fi
}

logout() {
    if [[ "$2" != null ]]; then
        echo "-> logout from $1"
        docker logout "$1"
        echo
    fi
}

l_url=`jq -r .local.url config.json`
l_user=`jq -r .local.user config.json`
l_pass=`jq -r .local.password config.json`

login "$l_url" "$l_user" "$l_pass"

data=`jq .remotes config.json`
num=`python3 -c "import json; print(len(json.loads('''$data''')))"`
for ((i=0; i<$num; i++)); do
    url=`jq -r .remotes[$i].url config.json`
    user=`jq -r .remotes[$i].user config.json`
    pass=`jq -r .remotes[$i].password config.json`

    login "$url" "$user" "$pass"

    data=`jq .remotes[$i].repos config.json`
    repos=`python3 -c "import json; print(len(json.loads('''$data''')))"`
    for ((j=0; j<repos; j++)); do
        repo=`jq -r .remotes[$i].repos[$j] config.json`
        echo "-> mirror $url/$repo"
        echo "  -> pull"
        docker pull "$url/$repo" | tee tmp
        echo
        if [[ `tail -2 tmp | grep "Image is up to date"` != "" ]]; then
            echo "  -> up to date"
            echo
        else
            echo $(date)                >> update_log
            echo "-> mirror $url/$repo" >> update_log
            echo "  -> pull"            >> update_log
            cat  tmp                    >> update_log
            if [[ `echo $repo | grep ":latest"` != "" ]]; then
                echo "  -> remove old ones"                                  | tee -a update_log
                docker rmi $(docker images | grep "none" | awk '{print $3}') | tee -a update_log
                echo
            fi
            echo "  -> push"                                                 | tee -a update_log
            docker tag "$url/$repo" "$l_url/$repo"                           | tee -a update_log
            docker push "$l_url/$repo"                                       | tee -a update_log
            echo                                                             | tee -a update_log
        fi
        echo
        echo
    done

    logout "$url" "$user"
done

rm tmp
logout "$l_url" "$l_user"
