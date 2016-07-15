#! /bin/sh
#this script creates a folder with all caches of all dependencies of the 'result' link found in this directory.
#it returns the path of the cache folder.
#if there are already some links in the cache they will only be updated but never removed.


#the folder where all caches are stored. make sure that the users nixbld has access to this folder
path=/tmp/fractalideBuildCache

if [ -h ./result ]; then
  deps=$(nix-store --query --requisites $(readlink -f ./result))

  mkdir -p $path

  for i in $deps
  do
    if [ -h $i/buildCache  ]; then
        cache=$(ls $i/buildCache)
        ln -sfn $i/buildCache/$cache $path/$cache
    fi
  done
fi
echo $path
