BASE_DIR=/defender-docs/src/sre/defender-environments/
#Will use below , but for testing will use new one above
#BASE_DIR=$(workspaces.build-workspace.path)/defender-docs/src/sre/defender-environments/
MAIN_BRANCH="main"

push_to_github() {
    cd $BASE_DIR
    git fetch origin
    git reset --hard origin/$MAIN_BRANCH

    # Switch to the main branch
    git checkout $MAIN_BRANCH

    # Add the specific file you want to commit
    git add .
    git commit -m "Updated feature_toggles_by_env.md file via _pipeline_validate_kustomize - $(date '+%Y-%m-%d %H:%M:%S')"
    git push origin $MAIN_BRANCH
    return $?
}

back_off_time=3
counter=1

push_to_github
return_val=$?
while [ $return_val -ne 0 ]; do
    if [ $counter -eq 5 ]; then
        echo 'Retried too many times. Exiting as failed!'
        exit 1
    fi
    echo 'Push to GitHub failed. Sleeping for $back_off_time seconds and then retrying...'
    sleep $back_off_time
    back_off_time=$((back_off_time*2 + 1))
    counter=$((counter + 1))
    push_to_github
    return_val=$?
done

exit $?
