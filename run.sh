#!/bin/bash

login() {
    if [[ "$2" != null && "$3" != null ]]; then
        echo "-> login to $1"
        skopeo login -u "$2" -p "$3" "$1"
        echo
    fi
}

logout() {
    if [[ "$2" != null ]]; then
        echo "-> logout from $1"
        skopeo logout "$1"
        echo
    fi
}

log="updater.log"

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
        echo "-> mirror $url/$repo" | tee -a $log
#        skopeo delete docker://"$l_url"/"$repo"
        skopeo copy docker://"$url"/"$repo" docker://"$l_url"/"$repo" | tee -a $log
    done

    logout "$url" "$user"
done

logout "$l_url" "$l_user"
