###library
	library(Biobase)
	library(GenomicFeatures)
        library(ensembldb)
        library(AnnotationHub)
	library(ggplot2)
	library(dplyr)
###loading
##dataset
	gene_counts <- read.table("out/count_matrix/tableCounts_e_rev",sep="\t",header=T)
##annotations
	annotations <- read.table("data/metadata.txt",sep="\t",header=T)
	txdb <- makeTxDbFromGFF("data/Genome/hg38.ensGene.gtf",format="gtf")
        ah <- AnnotationHub()
        ahDb <- query(ah, pattern = c("Homo Sapiens", "EnsDb", 106))
        ahEdb <- ahDb[[1]]
	gene_data <- genes(ahEdb)
###code
##raw data matrix
	rownames(annotations) <- apply(annotations,1,function(x){paste(c(x[1],paste(c(x[2],x[3],x[4]),collapse="")),collapse="-")})
	mat <- gene_counts[,-c(1:6)]
	colnames(mat) <- paste(sapply(strsplit(colnames(mat),"[.]"),"[[",4),sapply(strsplit(colnames(mat),"[.]"),"[[",5),sep="-")
	sel<-apply(mat,1,function(x){ifelse(max(x)==0,1,0)})
        COUNTS <- ExpressionSet(assayData=as.matrix(mat[which(sel==0),rownames(annotations)]))
        fData(COUNTS) <- gene_counts[which(sel==0),c(1:6)]
#annotating gene length
	exons.list.per.gene <- exonsBy(txdb,by="gene")
	exonic.gene.sizes <- sum(width(reduce(exons.list.per.gene)))
	fData(COUNTS)$GeneSize <- exonic.gene.sizes[fData(COUNTS)$Geneid]
#annotating gene name
	sym <- gene_data$symbol
	names(sym) <- gene_data$gene_id
	fData(COUNTS)$GeneName <- sym[fData(COUNTS)$Geneid]
	no_name <- ifelse(fData(COUNTS)$GeneName=="",1,0)
	fData(COUNTS)$GeneName[which(no_name==1)] <- fData(COUNTS)$Geneid[which(no_name==1)]
        pData(COUNTS) <- annotations
##cpm data matrix
	cpm <- apply(exprs(COUNTS),2,function(x){x*1000000/sum(x)})
	CPM <- ExpressionSet(assayData=as.matrix(cpm))
	fData(CPM) <- fData(COUNTS)
	pData(CPM) <- pData(COUNTS)
##fpkm data matrix
	fpkm <- apply(cpm,2,function(x){x*1000/fData(CPM)$GeneSize})
	FPKM <- ExpressionSet(assayData=as.matrix(fpkm))
        fData(FPKM) <- fData(COUNTS)
        pData(FPKM) <- pData(COUNTS)

##evaluate expressed genes
	expressed <- apply(exprs(CPM),2,function(x){sum(x>1)})
	poor_expressed <- apply(exprs(CPM),2,function(x){sum(x<=1 & x>0)})
	zero_expressed <- apply(exprs(CPM),2,function(x){sum(x==0)})
	df <- data.frame(samples=rep(names(expressed),3),genes=c(rep(">1 CPM",length(expressed)),rep("0 CPM < x <  1 CPM",length(expressed)),rep("0 CPM",length(expressed))),value=c(expressed,poor_expressed,zero_expressed))

###out
	pdf("out/QC/featureCounts/number_expressed_genes.pdf")
	plot(ggplot(df, aes(fill=genes, y=value, x=samples)) + geom_bar(position="stack", stat="identity") + 
	scale_colour_viridis_d() + ggtitle("Number of expressed genes per sample") +
	theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)))
	dev.off()
	dataset <- list()
	dataset$COUNTS <- COUNTS
	dataset$CPM <- CPM
	dataset$FPKM <- FPKM
	wdir <- getwd()
	wdir <-unlist(strsplit(wdir,"/"))
	wd <- wdir[length(wdir)]
	assign(wd,dataset)
	wd %>% save(file=paste("out/count_matrix/",wd,"_expression_set.rda",sep=""))
