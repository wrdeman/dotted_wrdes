#!/bin/bash

BRANCHES=$(git branch --merged | grep  -v 'master\|develop\|feature')

echo "Branches to be deleted: "
echo $BRANCHES | sed "s/ /'\n'/g"
read -r -p "Are you sure? [y/N] " response
case $response in
    [yY][eE][sS]|[yY])
        echo "Deleting ..."
        git branch --merged | grep  -v 'master\|develop\|feature' | xargs -n 1 git branch -d
        ;;
    *)
        echo "Exiting"
        exit 0
        ;;
esac

