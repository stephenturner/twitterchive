# twitterchive - Archive Twitter search results

**_This repository is no longer being maintained._**
 
Blog post about this at <http://gettinggeneticsdone.blogspot.com/2013/05/automated-analysis-tweets-bioinformatics-twitterchive.html>.

## `twitterchive.sh`

[`twitterchive.sh`](twitterchive.sh): Script to search and save results from a Twitter search.

Script uses [sferki's `t` command line client](https://github.com/sferik/t) to search twitter for keywords stored in the arr variable inside the script.

Must first install the `t` gem and authenticate with OAuth (see the `t` readme).

Twitter enforces some API limits to how many tweets you can search for in one query, and how many queries you can execute in a given period.

I'm not sure what these limitations are, but I've hit them a few times. To be safe, I would limit the number of queries to ~5, `$n` to ~200, and run no more than a couple times per hour.

You can set this up in a cron job using something like:

```
# Run at the top of the hour every four hours. 
00 00,04,08,12,16,20 * * * export PATH=/usr/local/bin:$PATH && cd /path/to/twitterchive && ./twitterchive.sh > /home/user/logs/cronlog.txt 2>&1
```

## `analysis/twitterchive.r`

[`analysis/twitterchive.r`](analysis/twitterchive.r): R stats script that contains a function to read in and parse the fixed width text files above, and produce some plots:

* Number of tweets per day for the last *n* days
* Frequency of tweets by hour of the day
* Barplot of the most frequently used hashtags within a query
* Barplot of the most prolific tweeters
* The ubiquitous wordcloud
