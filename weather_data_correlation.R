library(corrplot)
library(RColorBrewer)
library(jsonlite)

weather_data <- fromJSON("~//MTA_proj//realtime_data.json",pretty=TRUE)

head(weather_data)

keeps <- c("ozone","temperature","dewpoint","nearestStormDistance","cloudcover","humidity","apparentTemerature","pressure","windSpeed","precipProbability","visibility","precipIntensity")

wthr_data<- weather_data$currently[,names(weather_data$currently) %in% keeps]

data<-data.frame(weather_data$currently)

data$id<-weather_data$`_id`
data$longitude<-weather_data$longitude
data$latitude<-weather_data$latitude
data$offset<-weather_data$offset
data$timezone <-weather_data$timezone


weather_corr <- cor(wthr_data,y=NULL,use="everything",method=c("pearson","kendall","spearman"))
p.mat <- cor.mtest(weather_corr)
col <- colorRampPalette(c("#BB4444","EE9988", "#FFFFFF", "#77AADD", "#4477AA"))
corrplot(weather_corr, method="color", col=col(180),  
         type="upper", order="hclust", 
         addCoef.col = "black", # Add coefficient of correlation
         tl.col="black", tl.srt=35, #Text label color and rotation
         # Combine with significance
         p.mat = p.mat, sig.level = 0.01, insig = "blank", 
         # hide correlation coefficient on the principal diagonal
         diag=FALSE 
)

write.table(data,file="~//MTA_proj//weather_data.csv",sep=",",row.names = FALSE)
write.table(weather_corr,file="~//MTA_proj//weather_correlations.csv",sep=",",row.names = FALSE)
cor.mtest <- function(mat, ...) {
  mat <- as.matrix(mat)
  n <- ncol(mat)
  p.mat<- matrix(NA, n, n)
  diag(p.mat) <- 0
  for (i in 1:(n - 1)) {
    for (j in (i + 1):n) {
      tmp <- cor.test(mat[, i], mat[, j], ...)
      p.mat[i, j] <- p.mat[j, i] <- tmp$p.value
    }
  }
  colnames(p.mat) <- rownames(p.mat) <- colnames(mat)
  p.mat
}
# matrix of the p-value of the correlation
