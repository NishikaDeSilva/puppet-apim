#!/usr/bin/env bash
set -o xtrace

platform="api-manager"

parent_repo=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .git_repo.parent' params.json )
repo=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .git_repo.name' params.json )
branch=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .git_repo.branch' params.json )

git clone "https://github.com/${parent_repo}/${repo}" && git checkout ${branch} #TODO: uncomment this line

# add dependencies
wget $(jq -r '.common.jdbc_download_link') -O ${repo}/files/lib/

mkdir trash && wget $(jq -r '.common.jdk_download_link') -O trash
jar_file_location=$(find trash -name '*.jar') && mv ${jar_file_location} ${repo}/files/lib/

# add products to files/packs/
products=$(jq -r '.platforms[] | select( .name == '\"${platform}\"') | .products' params.json)

for row in $(echo "${products}" | jq -r '.[] | @base64')
do
  _jq() {
     echo ${row} | base64 --decode | jq -r ${1}
    }

  product_name=$(_jq '.name')
  product_version=$(_jq '.version')
  product_zip="${product_name}-${product_version}.zip"

  cp ~/.wum3/products/${product_name}/${product_version}/${product_zip} ${repo}/files/packs/

done
