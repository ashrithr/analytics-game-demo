#######################
#load the rpart library
require(rpart)

#######################
#load the data
setwd("/tmp")
p_data = read.csv(file="1_demo_data.tsv",sep="\t",dec=".",header=TRUE)
#head
summary(p_data)

#######################
#rpart
dtree <- rpart(paid ~ .,data = p_data, method="class")
print(dtree)
