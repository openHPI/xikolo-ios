#!/bin/bash

set -x
git=`sh /etc/profile; which git`
merge_base=`$git merge-base master HEAD`
branch_name=`$git symbolic-ref HEAD | sed -e 's,.*/\\(.*\\),\\1,'`
commit_count_merge_base=`$git rev-list --count $merge_base`
commit_count_diff_head=`$git rev-list --count $merge_base..HEAD`

build_number=$commit_count_merge_base
if [ "$branch_name" != "master" ]; then
    build_number="$build_number.$commit_count_diff_head"
    if [ "$branch_name" != "dev" ]; then
        build_number="$build_number.0"
    fi
fi

/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $build_number" "${PRODUCT_SETTINGS_PATH}"

echo "Updated build number in ${PRODUCT_SETTINGS_PATH} to $build_number"
