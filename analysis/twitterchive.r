## Most of this code was adapted near-verbatim from Neil's post about ISMB 2012.
## http://nsaunders.wordpress.com/2012/08/16/twitter-coverage-of-the-ismb-2012-meeting-some-statistics/

## Modify this. This is where I keep this repo.
repoDir <- ("~/workprojects/twitterchive/")

## Go to the analysis directory
setwd(paste(repoDir, "analysis", sep=""))

## Function needs better documentation
twitterchivePlots <- function (filename=NULL) {
    
    ## Load required packages
    require(tm)
    require(wordcloud)
    require(RColorBrewer)
    
    if (class(filename)!="character") stop("filename must be character")
    if (!file.exists(filename)) stop(paste("File does not exist:", filename))
    
    searchTerm <- sub("\\.txt", "", basename(filename))
    
    message(paste("Filename:", filename))
    message(paste("Search Term: ", searchTerm))
    
    ## Read in the data and munge around the dates.
    ## I can't promise the fixed widths will always work out for you.
    message("Reading in data.")
    trim.whitespace <- function(x) gsub("^\\s+|\\s+$", "", x) # Function to trim leading and trailing whitespace from character vectors.
    d <- read.fwf(filename, widths=c(18, 14, 18, 1000), stringsAsFactors=FALSE, comment.char="")
    d <- as.data.frame(sapply(d, trim.whitespace), stringsAsFactors=FALSE)
    names(d) <- c("id", "datetime", "user", "text")
    d$user <- sub("@", "", d$user)
    d$datetime <- as.POSIXlt(d$datetime, format="%b %d %H:%M")
    d$date <- as.Date(d$datetime)
    d$hour <- d$datetime$hour
    d <- na.omit(d) # CRs cause a problem. explain this later.
    write.csv(d, file=sub("\\.txt", "\\.csv", filename))
    head(d)
    
    ## Number of tweets by date for the last n days
    recentDays <- 30
    message(paste("Plotting number of tweets by date in the last", recentDays, "days."))
    recent <- subset(d, date>=(max(date)-recentDays))
    byDate <- as.data.frame(table(recent$date))
    names(byDate) <- c("date", "tweets")
    png(paste(searchTerm, "barplot-tweets-by-date.png", sep="--"), w=1000, h=700)
    par(mar=c(8.5,4,4,1))
    with(byDate, barplot(tweets, names=date, col="black", las=2, cex.names=1.2, cex.axis=1.2, mar=c(10,4,4,1), main=paste("Number of Tweets by Date", paste("Term:", searchTerm), sep="\n")))
    dev.off()
    # ggplot(byDate) + geom_bar(aes(date, tweets), stat="identity", fill="black") + theme_bw() + ggtitle("Number of Tweets by Date") + theme(axis.text.x=element_text(angle=90, hjust=1))
    
    ## Number of tweets by hour
    message("Plotting number of tweets by hour.")
    byHour <- as.data.frame(table(d$hour))
    names(byHour) <- c("hour", "tweets")
    png(paste(searchTerm, "barplot-tweets-by-hour.png", sep="--"), w=1000, h=700)
    with(byHour, barplot(tweets, names.arg=hour, col="black", las=1, cex.names=1.2, cex.axis=1.2, main=paste("Number of Tweets by Hour", paste("Term:", searchTerm), paste("Date:", Sys.Date()), sep="\n")))
    dev.off()
    # ggplot(byHour) + geom_bar(aes(hour, tweets), stat="identity", fill="black") + theme_bw() + ggtitle("Number of Tweets by Hour")
    
    ## Barplot of top 20 hashtags
    message("Plotting top 20 hashtags.")
    words <- unlist(strsplit(d$text, " "))
    head(table(words))
    ht <- words[grep("^#", words)]
    ht <- tolower(ht)
    ht <- gsub("[^A-Za-z0-9]", "", ht) # remove anything not starting with a letter or number
    ht <- as.data.frame(table(ht))
    ht <- subset(ht, ht!="") # remove blanks
    ht <- ht[sort.list(ht$Freq, decreasing=TRUE), ]
    ht <- ht[-1, ] # remove the term you're searching for? it usually dominates the results.
    ht <- head(ht, 20)
    head(ht)
    png(paste(searchTerm, "barplot-top-hashtags.png", sep="--"), w=1000, h=700)
    par(mar=c(5,10,4,2))
    with(ht[order(ht$Freq), ], barplot(Freq, names=ht, horiz=T, col="black", las=1, cex.names=1.2, cex.axis=1.2, main=paste("Top Hashtags", paste("Term:", searchTerm), paste("Date:", Sys.Date()), sep="\n")))
    dev.off()
    # ggplot(ht) + geom_bar(aes(ht, Freq), fill = "black", stat="identity") + coord_flip() + theme_bw() + ggtitle("Top hashtags")
    
    ## Top Users
    message("Plotting most prolific users.")
    users <- as.data.frame(table(d$user))
    colnames(users) <- c("user", "tweets")
    users <- users[order(users$tweets, decreasing=T), ]
    users <- subset(users, user!=searchTerm)
    users <- head(users, 20)
    head(users)
    png(paste(searchTerm, "barplot-top-users.png", sep="--"), w=1000, h=700)
    par(mar=c(5,10,4,2))
    with(users[order(users$tweets), ], barplot(tweets, names=user, horiz=T, col="black", las=1, cex.names=1.2, cex.axis=1.2, main=paste("Most prolific users", paste("Term:", searchTerm), paste("Date:", Sys.Date()), sep="\n")))
    dev.off()
    
    ## Word clouds
    message("Plotting a wordcloud.")
    words <- unlist(strsplit(d$text, " "))
    words <- grep("^[A-Za-z0-9]+$", words, value=T)
    words <- tolower(words)
    words <- words[-grep("^[rm]t$", words)] # remove "RT"
    words <- words[!(words %in% stopwords("en"))] # remove stop words
    words <- words[!(words %in% c("mt", "rt", "via", "using", 1:9))] # remove RTs, MTs, via, and single digits.
    wordstable <- as.data.frame(table(words))
    wordstable <- wordstable[order(wordstable$Freq, decreasing=T), ]
    wordstable <- wordstable[-1, ] # remove the hashtag you're searching for? need to functionalize this.
    head(wordstable)
    png(paste(searchTerm, "wordcloud.png", sep="--"), w=800, h=800)
    wordcloud(wordstable$words, wordstable$Freq, scale = c(8, .2), min.freq = 3, max.words = 200, random.order = FALSE, rot.per = .15, colors = brewer.pal(8, "Dark2"))
    #mtext(paste(paste("Term:", searchTerm), paste("Date:", Sys.Date()), sep=";"), cex=1.5)
    dev.off()
    
    message(paste(searchTerm, ": All done!\n"))
}

filelist <- as.list(list.files("..", pattern="bog14.txt", full.names=T))
#filelist <- list("../bioinformatics.txt", "../metagenomics.txt", "../rstats.txt", "../rna-seq.txt", "../cville.txt", "../SFAF2013.txt")
lapply(filelist, twitterchivePlots)

# Using imagemagick:
# system("montage bog14--barplot-tweets-by-date.png bog14--barplot-tweets-by-hour.png bog14--barplot-top-hashtags.png bog14--barplot-top-users.png  -tile 2x -geometry -0-0 bog14--montage.jpg")