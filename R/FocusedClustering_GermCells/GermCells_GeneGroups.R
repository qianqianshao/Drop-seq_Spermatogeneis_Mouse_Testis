### R script to analyze gene groups and infertility genes across 12 germ cell cluster centroids on 11/28/2017 by Jun
### Related to Figure 3 and S3, and Table S3C-D: 6 gene groups and infertility genes

### load data
setwd("C:/Users/junzli/Documents/Students/Qianyi/Hammoud/Centroid12")
sys.load.image(".RData",quiet=F)
cen<-as.matrix(read.delim("Cen12_minus3.txt",header=T,row.names=1,sep="\t"))
tot<-as.matrix(read.delim("Cen12_tot_minus3.txt",header=T,row.names=1,sep="\t"))
> plot(cen[,1],tot[,1])
> points(cen[,2],tot[,2],col=2)
> points(cen[,3],tot[,3],col=3)
> points(cen[,4],tot[,4],col=4)

### Select highly-variable genes (N=8,583)
g.mean<-apply(cen,1,mean)
g.var<-apply(cen,1,var)
tot.mean<-apply(tot,1,mean)
tot.var<-apply(tot,1,var)
plot(g.mean,g.var/(g.mean),cex=0.5,ylim=c(0,3))
plot(tot.mean,tot.var/(tot.mean),cex=0.5,ylim=c(0,3))
filter<-(tot.mean>2)&( tot.var/tot.mean>0.5)
sum(filter)
[1] 8583

### Generate 10x10 gene groups for the 8,583 HVG using SOM
date()
som1<-som(cen[filter,],6,6)
date()
plot(som1,ylim=c(-1,1))
cen.norm<-normalize(cen[filter,]) #this standardized each gene
colnames(cen.norm)<-colnames(cen)
som2<-som(cen.norm,6,6)
som3<-som(cen.norm,10,10)
### save as Figure S3B middle panel

### number of genes in each of the 10x10 gene groups
som3.id<-som3$visual
> table(som3.id[,1:2])
   y
x     0   1   2   3   4   5   6   7   8   9
  0 386  80  60  78 250 253 282 260 215 729
  1 176  17  17  16  16  20  17  27  55  83
  2 197  59  19  22  30  16  20  10  34 121
  3 182  61  30  38  46  19  20  14  14 117
  4 202  53  26  36  43  55  52  14  10 116
  5 226  21  14  12  22  40  39   8   7 163
  6 213  35  17  12  14  45  30   8   5 280
  7 196  41  32  27  16  28  19   7  10 124
  8 151  32  23  17  18  12   9  12  14 109
  9 179 179 172 165 119 178 259 231 160 120
tmp<-(som3.id[,1]==0)&( som3.id[,2]==9)
heatmap(cen.norm[tmp,],col=redblue100, Colv = NA)
tmp<-(som3.id[,1]==9)&( som3.id[,2]==9)
heatmap(cen.norm[tmp,],col=redblue100, Colv = NA)
tmp<-(som3.id[,1]==9)&( som3.id[,2]==3)
heatmap(cen.norm[tmp,],col=redblue100, Colv = NA, main=paste("x=",i,", y=",j))
pdf("ten-by-ten.pdf")
par(mfrow=c(5,2))
for (i in 0:9) {
for (j in 0:0) {
tmp<-(som3.id[,1]==i)&( som3.id[,2]==j)
c<-sum(tmp)
heatmap(cen.norm[tmp,],col=redblue100, Colv = NA, main=paste("x=",i,", y=",j,", n=",c))
}
}
dev.off()
tmp<-(som3.id[,1]==i)
c<-sum(tmp)
heatmap(cen.norm[tmp,],col=redblue100, Colv = NA, main=paste("x=",i,", n=",c))
heatmap(cen.norm[tmp,],col=redblue100, Colv = NA, main=paste("x=",i,", y=",j,", n=",c))
par(mfrow=c(5,2))
for (i in 0:9) {
for (j in 0:0) {
tmp<-(som3.id[,1]==i)&( som3.id[,2]==j)
c<-sum(tmp)
data<- cen.norm[tmp,]
row.id<-heatmap(data)$rowInd
image(data[row.id,],col=redblue100, main=paste("x=",i,", y=",j,", n=",c))
}
}
library(gridGraphics)
library(grid)
heatmap(as.matrix(mtcars))
library(gridGraphics)
grab_grob <- function(){
  grid.echo()
  grid.grab()
}
g <- grab_grob()
grid.newpage()
# library(gridExtra)
# grid.arrange(g,g, ncol=2, clip=TRUE)
lay <- grid.layout(nrow = 1, ncol=2)
pushViewport(viewport(layout = lay))
grid.draw(editGrob(g, vp=viewport(layout.pos.row = 1, 
                                  layout.pos.col = 1, clip=TRUE)))
grid.draw(editGrob(g, vp=viewport(layout.pos.row = 1, 
                                  layout.pos.col = 2, clip=TRUE)))
upViewport(1)

### PCA for the 8,583 HVG
pca12<-prcomp(cen.norm)
plot(pca12$x[,1],pca12$x[,2],cex=0.5)

i<-0
for (j in 0:9) {
tmp<-(som3.id[,1]==i)&( som3.id[,2]==j)
points(pca12$x[tmp,1],pca12$x[tmp,2],cex=0.7, col=j, pch=19)
}

# solve for cubic equation
t12<-c(1:12)
result8583<-matrix(NA,8583,7)
date()
for (i in 1:8583){
  expr <- as.vector(cen.norm[i,])
M<- as.matrix(cbind(rep(1,length(t12)), t12, t12^2, t12^3))
  result8583[i,1:4] <- beta<-solve(t(M)%*%M)%*%(t(M)%*%expr)
  result8583[i,6]<-SSz <- t(beta) %*% t(M) %*% expr - (sum(expr)^2) / length(expr)
 result8583[i,7]<- SSy <- sum(expr^2)-(sum(expr)^2)/ length(expr)
result8583[i,5]<- SSz / SSy
}
date()
#1 second!

cor8583<-rep(0,8583)
for (i in 1:8583) {
cor8583[i]<-cor(as.vector(t(result8583[i,1:4])%*%t(M)),cen.norm[i,])
}
plot(cor8583^2,result8583[,5])
plot(result8583[,2], result8583[,3],cex=0.6)
points(result8583[cor8583>0.9,2], result8583[cor8583>0.9,3],pch=19,col=2,cex=0.6)
plot(result8583[,1], result8583[,3],cex=0.6)
points(result8583[cor8583>0.9,1], result8583[cor8583>0.9,3],pch=19,col=2,cex=0.6)
plot(result8583[,2], result8583[,4],cex=0.6)
points(result8583[cor8583>0.9,2], result8583[cor8583>0.9,4],pch=19,col=2,cex=0.6)
 
# use pc1 or beta 1 to divide them
plot(pca12$x[,1],pca12$x[,2],cex=0.5)
points(pca12$x[cor8583>0.9,1],pca12$x[cor8583>0.9,2],cex=0.5,pch=19,col=2)
plot(pca12$x[,1], result8583[,1],cex=0.5)
points(pca12$x[cor8583>0.9,1], result8583[cor8583>0.9,1],cex=0.5,pch=19,col=2)
class1<- (pca12$x[,1]<0)&(cor8583>0.9)
sum(class1)
[1] 1062
class2<- (pca12$x[,1]>0)&(cor8583>0.9)&( result8583[,1]>(-2))
sum(class2)
[1] 1325
class3<- (cor8583>0.9)&( result8583[,1]<(-2))
sum(class3)
[1] 318
plot(pca12$x[,1], result8583[,1],cex=0.5)
points(pca12$x[class1,1], result8583[class1,1],cex=0.5,pch=19,col=2)
points(pca12$x[class2,1], result8583[class2,1],cex=0.5,pch=19,col=3)
points(pca12$x[class3,1], result8583[class3,1],cex=0.5,pch=19,col=4)
 
### heatmap of the 3 classes
heatmap(cen.norm[class1,],col=redblue100, Colv = NA)
heatmap(cen.norm[class2,],col=redblue100, Colv = NA)
heatmap(cen.norm[class3,],col=redblue100, Colv = NA)
 
### generate 6 gene groups using K-means clustering
k6<-kmeans(cen.norm,6)$cluster
plot(pca12$x[,1], pca12$x[,2],cex=0.5)
for (i in 1:6) {
tmp<-k6==i
points(pca12$x[tmp,1], pca12$x[tmp,2],cex=0.5,pch=19,col=i)
}
plot(pca12$x[,1], pca12$x[,2],cex=0.5)
for (i in 1:6) {
tmp<-(k6==i)&(cor8583>0.9)
points(pca12$x[tmp,1], pca12$x[tmp,2],cex=0.8,pch=19,col=i)
}
plot(pca12$x[,3], pca12$x[,4],cex=0.5)
for (i in 1:6) {
tmp<-(k6==i)&(cor8583>0.9)
points(pca12$x[tmp,3], pca12$x[tmp,4],cex=0.8,pch=19,col=i)
}
### generate 12 gene groups using K-means clustering
k12<-kmeans(cen.norm,12)$cluster
plot(pca12$x[,1], pca12$x[,2],cex=0.5)
for (i in 1:6) {
tmp<-k12==i
points(pca12$x[tmp,1], cex=0.7,pca12$x[tmp,2], pch=19,col=i)
}
plot(pca12$x[,1], pca12$x[,2],cex=0.5)
for (i in 1:6) {
tmp<-k12==i+6
points(pca12$x[tmp,1], cex=0.7,pca12$x[tmp,2], pch=19,col=i)
}
### heatmap for 6 gene groups from k-means clustering - Related to Figure 3A
heatmap(cen.norm[k6==1,],col=redblue100, Colv = NA)
heatmap(cen.norm[k6==1,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5))
heatmap(cen.norm[k6==2,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5))
heatmap(cen.norm[k6==3,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5))
heatmap(cen.norm[k6==4,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5))
heatmap(cen.norm[k6==5,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5))
heatmap(cen.norm[k6==6,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5))
## save as Figure 3A
 
table(k6)
#k6
#   1    2    3    4    5    6 
#1694 1388 1752  942 2095  712

# rerun it on before-normalization data

result8583.nonorm<-matrix(NA,8583,7)
date()
for (i in 1:8583){
tmp<-cen[filter,]
  expr <- as.vector(tmp[i,])
M<- as.matrix(cbind(rep(1,length(t12)), t12, t12^2, t12^3))
  result8583.nonorm [i,1:4] <- beta<-solve(t(M)%*%M)%*%(t(M)%*%expr)
  result8583.nonorm [i,6]<-SSz <- t(beta) %*% t(M) %*% expr - (sum(expr)^2) / length(expr)
 result8583.nonorm [i,7]<- SSy <- sum(expr^2)-(sum(expr)^2)/ length(expr)
result8583.nonorm [i,5]<- SSz / SSy
}
date() $7 seconds
cor8583.b<-rep(0,8583)
tmp<-cen[filter,]
for (i in 1:8583) {
cor8583.b[i]<-cor(as.vector(t(result8583.nonorm[i,1:4])%*%t(M)),tmp[i,])
}
plot(cor8583.b^2,result8583.nonorm[,5])
plot(cor8583, cor8583.b)

### plot k6 with large cor8583
### mapping k6 to the 6-6 and 10-10 SOM - Related to Figure S3B
table(som3.id[k6==1,1:2])

### distribution of male infertility genes - Related to Figure 3C-D
male187<-as.matrix(read.delim("maleInfert187.txt",header=T,row.names=1,sep="\t"))
infert<- as.matrix(read.delim("maleInfert187_123Both_human234.txt", header=T,row.names=1,sep="\t"))
> sum(rownames(cen)==rownames(infert))
[1] 24472

tmp<-cbind(k6,male187[filter,1])
> table(tmp[,2],tmp[,1])
   
       1    2    3    4    5    6
  0 1683 1379 1733  933 2072  710
  1   11    9   19    9   23    2

### infert 187 male genes
filter2<- male187[filter,1]==1 #73
heatmap(cen.norm[filter2,],col=redblue100, Colv = NA,cexRow=0.5) #
 
male187.var<- rownames(cen.norm[filter2,])[heatmap(cen.norm[filter2,])$rowInd]
write.table(male187.var,"male187_var73.txt",sep="\t")

filter.notvar<-male187[!filter,1]==1
tmp<-cen[!filter,]
tmp<-normalize(tmp)
heatmap(tmp[filter.notvar,],col=redblue100, Colv = NA,cexRow=0.4) #114 genes in not variable (not in 8583)

male187.notvar<- rownames(tmp[filter.notvar,])[heatmap(tmp[filter.notvar,])$rowInd]
write.table(male187.notvar,"male187_notvar114.txt",sep="\t")

 
### infert 187 male +123 Both genes
filter3<- (infert[filter,1]==1)|( infert[filter,2]==1) #116
heatmap(cen.norm[filter3,],col=redblue100, Colv = NA,cexRow=0.5,zlim=c(-3.5,3.5)) #
 
 
male310.var<- rownames(cen.norm[filter3,])[heatmap(cen.norm[filter3,])$rowInd]
write.table(male310.var,"male310_var116.txt",sep="\t")

filter.notvar2<- (infert[!filter,1]==1)|( infert[!filter,2]==1)
#male187[!filter,1]==1
tmp<-cen[!filter,]
tmp<-normalize(tmp)
heatmap(tmp[filter.notvar2,],col=redblue100, Colv = NA,cexRow=0.4) #194 genes in not variable (not in 8583)
 
male310.notvar<- rownames(tmp[filter.notvar2,])[heatmap(tmp[filter.notvar2,])$rowInd]
write.table(male310.notvar,"male310_notvar194.txt",sep="\t")

### added human genes to male187
#read it in
filter.human<- male187[filter,2]==1 #83
heatmap(cen.norm[filter.human,],col=redblue100, Colv = NA,cexRow=0.5,zlim=c(-3.5,3.5))
 
 
Human234.var<- rownames(cen.norm[filter.human,])[heatmap(cen.norm[filter.human,])$rowInd]
write.table(Human234.var," human234_var83.txt",sep="\t")

filter.human.notvar<- male187[!filter,2]==1
heatmap(tmp[filter.human.notvar,],col=redblue100, Colv = NA,cexRow=0.4) #151 genes in not variable (not in 8583)
 
human234.notvar<- rownames(tmp[filter.human.notvar,])[heatmap(tmp[filter.human.notvar,])$rowInd]
write.table(human234.notvar," human234_notvar151.txt",sep="\t")


tmp<-cbind(k6,male187[filter,2])
table(tmp[,2],tmp[,1])

### Handel 8 lists:
# create a txt file with all genes, but indicate high-low var and 8 Handel group IDs.

handel<- as.matrix(read.delim("Handel_noNA5595.txt",header=T,row.names=1,sep="\t"))
table(handel[,2])
   1    2    3    4    5    6    7    8 
 834   29   36  612   96  733   74 2939
handel[is.na(handel[,2]),2]<-0
> table(handel[,2])
    0     1     2     3     4     5     6     7     8 
19119   834    29    36   612    96   733    74  2939

cen.all<-normalize(cen)
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==1)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=0.4, xlab="Sp'gonia (286 hi-var genes)")
 

filter.handel<-(!is.na(handel[,1]))&(handel[,2]==2)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=1.2, xlab="Prelep (5 hi-var genes)")
 
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==3)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=1, xlab="Early Lep (12 hi-var genes)")
 
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==4)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=0.4, xlab="Late Lep/Zyg (178 hi-var genes)")
 
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==5)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=0.8, xlab="Late Lep/Zyg/Early Pach (30 hi-var genes)")
 
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==6)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=0.4, xlab="Early Pach (136 hi-var genes)")
 
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==7)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=1, xlab="Early Pach/Late Pach/Dip (16 hi-var genes)")
 
filter.handel<-(!is.na(handel[,1]))&(handel[,2]==8)
heatmap(cen.all[filter.handel,],col=redblue100, Colv = NA,cexRow=0.2, xlab="Late Pach/Dip (924 hi-var genes)")
 


Sp'g	Sp'gonia
PL	Prelep
EL	Early Lep
LL+Z	Late Lep/Zyg
LL+Z+EP	Late Lep/Zyg/Early Pach
EP	Early Pach
EP+LP+D	Early Pach/Late Pach/Dip
LP+D	Late Pach/Dip

handel.anti<- as.matrix(read.delim("Handel_anti.txt",header=T,row.names=1,sep="\t"))
handel.anti[is.na(handel.anti[,2]),2]<-0

filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==1)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=0.4, xlab="Sp'gonia (291 hi-var, anti-genes)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==2)
image(as.matrix(cen.all[filter.handel.anti,]),col=redblue100, xlab="Prelep (1 hi-var anti-gene: Gm13563)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==3)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=1, xlab="Early Lep (4 hi-var anti-genes)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==4)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=0.4, xlab="Late Lep/Zyg (101 hi-var anti-genes)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==5)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=0.8, xlab="Late Lep/Zyg/Early Pach (21 hi-var anti-genes)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==6)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=0.4, xlab="Early Pach (274 hi-var anti-genes)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==7)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=0.6, xlab="Early Pach/Late Pach/Dip (56 hi-var anti-genes)")
 
filter.handel.anti<-(!is.na(handel.anti[,1]))&(handel.anti[,2]==8)
heatmap(cen.all[filter.handel.anti,],col=redblue100, Colv = NA,cexRow=0.2, xlab="Late Pach/Dip (1742 hi-var anti-genes)")
 
table(handel.anti[,1], handel.anti[,2])

### k6 vs k12

table(k6,k12)
   k12
k6     1    2    3    4    5    6    7    8    9   10   11   12
  1    7    1    2    3    0    0  789    8  882    2    0    0
  2    0    0  329    1    0  251   33  770    0    4    0    0
  3  564  892    2    5    0    0    0    3  279    5    1    1
  4    2    2   48    1  416    0    2    0    0  442    0   29
  5    8    3   43 1344  514    0    7    0    0    0    0  176
  6    3    0   12    0    0  149    7    0    0    0  447   94

### Plot the heatmap of k12 - Related to Figure S3A
#par(mfrow=c(3,2), mar=c(3, 2, 2, 2))
heatmap(cen.norm[k12==1,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 1")
heatmap(cen.norm[k12==2,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 2")
heatmap(cen.norm[k12==3,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 3")
heatmap(cen.norm[k12==4,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 4")
heatmap(cen.norm[k12==5,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 5")
heatmap(cen.norm[k12==6,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 6")
heatmap(cen.norm[k12==7,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 7")
heatmap(cen.norm[k12==8,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 8")
heatmap(cen.norm[k12==9,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 9")
heatmap(cen.norm[k12==10,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 10")
heatmap(cen.norm[k12==11,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 11")
heatmap(cen.norm[k12==12,],col=redblue100, Colv = NA,zlim=c(-3.5,3.5), main= "K12 Cluster 12")
## save as Figure S3A

### export cen.norm and k6, k12

tmp<-cbind(cen.norm,k6,k12)
write.table(tmp,"8583genes_k6_k12.txt",sep="\t")
# save as Table S3C

7 lists:
progressive: 14
subfertile: 109
spg: 13
spc: 60
round: 32
elongated: 13
sperm: 41
Bcl2l1 duplicated, renamed as _spc, 
first saved as "7 lists.txt"
Added to "maleInfert187_123Both_human234_7lists.txt"
list	matched input
1	13	14
2	96	109
3	11	13
4	57	60
5	30	32
6	12	13
7	39	41
seven <-as.matrix(read.delim("maleInfert187_123Both_human234_7lists.txt",header=T,row.names=1,sep="\t"))

filter7<- seven[filter,4]==1 #5
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1,main="Progressive, high-var(5)", zlim=c(-3.5,3.5)) #
   
tmp<-cen[!filter,]
tmp<-normalize(tmp)
filter7.notvar<-seven[!filter,4]==1#8
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=1, main="Progressive, not-high-var(8)", zlim=c(-3.5,3.5)) 

filter7<- seven[filter,4]==2 #38
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1,main="Subfertile, high-var(38)", zlim=c(-3.5,3.5)) #
   
filter7.notvar<-seven[!filter,4]==2#58
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=0.6, main="Subfertile, not-high-var(58)" , zlim=c(-3.5,3.5)) 

filter7<- seven[filter,4]==3 #8
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1,main="spg, high-var(8)", zlim=c(-3.5,3.5)) #
   
filter7.notvar<-seven[!filter,4]==3#3
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=1, main="spg, not-high-var(3)", zlim=c(-3.5,3.5)) 

filter7<- seven[filter,4]==4 #16
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5),main="spc, high-var(16)") #
   
filter7.notvar<-seven[!filter,4]==4#41
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=0.8, zlim=c(-3.5,3.5), main="spc, not-high-var(41)") 

filter7<- seven[filter,4]==5 #9
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5),main="round, high-var(9)") #
   
filter7.notvar<-seven[!filter,4]==5#21
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5), main="round, not-high-var(21)") 

filter7<- seven[filter,4]==6 #3
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5),main="elongated, high-var(3)") 
   
filter7.notvar<-seven[!filter,4]==6#9
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5), main="elongated, not-high-var(9)") 

filter7<- seven[filter,4]==7 #20
heatmap(cen.norm[filter7,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5),main="sperm, high-var(20)") 
   
filter7.notvar<-seven[!filter,4]==7#19
heatmap(tmp[filter7.notvar,],col=redblue100, Colv = NA,cexRow=1, zlim=c(-3.5,3.5), main="elongated, not-high-var(19)") 
