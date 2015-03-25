#!/bin/bash

## twitterchive.sh
## Stephen Turner (stephenturner.us)
##
## Script uses the t command line client (https://github.com/sferik/t)
## to search twitter for keywords stored in the arr variable below.
##
## Must first install the t gem and authenticate with OAuth.
##
## Twitter enforces some API limits to how many tweets you can search for
## in one query, and how many queries you can execute in a given period.
##
## I'm not sure what these limitations are, but I've hit them a few times.
## To be safe, I would limit the number of queries to ~5, $n to ~200, and
## run no more than a couple times per day.

## declare an array variable containing all your search terms. 
## prefix any hashtags with a \
declare -a arr=(bioinformatics metagenomics genomics rna-seq \#rstats \#cville)

## How many results would you like for each query?
n=400

## cd into where the script is being executed from.
DIR="$(dirname "$(readlink $0)")"
cd $DIR
echo $DIR
echo $(pwd)

echo

## now loop through the above array
for query in ${arr[@]}
do
	## if your query contains a hashtag, remove the "#" from the filename
	filename=$DIR/${query/\#/}.txt
	echo -e "Query:\t$query"
	echo -e "File:\t$filename"

	## create the file for storing tweets if it doesn't already exist.
	if [ ! -f $filename ]
	then
		touch $filename
	fi

	## use t (https://github.com/sferik/t) to search the last $n tweets in the query, 
	## concatenating that output with the existing file, sort and uniq that, then 
	## write the results to a tmp file. 
	search_cmd="t search all -ldn $n '$query' | cat - $filename | sort | uniq | grep -v ^ID > $DIR/tmp"
	echo -e "Search:\t$search_cmd"
	eval $search_cmd

	## rename the tmp file to the original filename
	rename_cmd="mv $DIR/tmp $filename"
	echo -e "Rename:\t$rename_cmd"
	eval $rename_cmd

	echo
done

## push changes to github.
## errors running git push via cron necessitated authenticating over ssh instead of https
# git init
# git touch README.md
# git add README.md
# git commit -m 'first commit'
# git remote add origin https://github.com/stephenturner/twitterchive.git
# git remote set-url origin git@github.com:stephenturner/twitterchive.git 
# git push origin master
# git add -A
# git commit -a -m "Update search results: $(date)"
# git push origin master

##	Run with a cronjob (make sure cron env has path to t executable (e.g., ~/bin)  
##	00	09,15	*	*	*	export PATH=~/bin:$PATH && cd /path/twitterchive/ && ./twitterchive.sh &> ~/cronlog.txt
