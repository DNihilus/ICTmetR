library(RISmed)
library(ggplot2)

# Generar la cadena oara la búsqueda
query <- "(exome OR whole OR deep OR high-throughput OR (next AND generation) OR (massively AND parallel)) AND sequencing"

# Obtener los resultados de la BD de pubmed
ngs_search <- EUtilsSummary(query, type="esearch",db = "pubmed",mindate=1980, maxdate=2013, retmax=30000)
# Hacer un conteo de los resultados obtenidos
QueryCount(ngs_search)
# Obtener un objeto con todos los datos del resultado de la consulta
ngs_records <- EUtilsGet(ngs_search)
# Revisar por el Año (YearPubmed) de los resultados <Hay datos del titulo, autor, fecha, etc>
years <- Year(ngs_records)
ngs_pubs_count <- as.data.frame(table(years))
 
total <- NULL
for (i in 1980:2013){
peryear <- EUtilsSummary("", type="esearch", db="pubmed", mindate=i, maxdate=i)
total[i] <- QueryCount(peryear)
}
year <- 1980:2013
total_pubs_count<- as.data.frame(cbind(year,total[year]))
names(total_pubs_count) <- c("year","Total_publications")
names(ngs_pubs_count) <-  c("year","NGS_publications")
pubs_year <-  merge(ngs_pubs_count,total_pubs_count,by="year")
pubs_year$NGS_publications_normalized <-  pubs_year$NGS_publications *100000 / pubs_year$Total_publications

write.table(pubs_year,"NGS_publications_per_year.txt",quote=F,sep="\t",row.names=F)
 
 
journal <- MedlineTA(ngs_records)
ngs_journal_count <- as.data.frame(table(journal))
ngs_journal_count_top25 <- ngs_journal_count[order(-ngs_journal_count[,2]),][1:25,]
 
journal_names <- paste(ngs_journal_count_top25$journal,"[jo]",sep="")
 
total_journal <- NULL
for (i in journal_names){
perjournal <- EUtilsSummary(i, type='esearch', db='pubmed',mindate=1980, maxdate=2013)
total_journal[i] <- QueryCount(perjournal)
}
 
journal_ngs_total <- cbind(ngs_journal_count_top25,total_journal)
names(journal_ngs_total) <- c("journal","NGS_publications","Total_publications")
journal_ngs_total$NGS_publications_normalized <- journal_ngs_total$NGS_publications / journal_ngs_total$Total_publications
 
write.table(journal_ngs_total,"NGS_publications_per_journal.txt",quote=F,sep="\t",row.names=F)


pubs_per_year <- read.table("NGS_publications_per_year.txt",header = T,sep="\t")
pubs_per_journal <- read.table("NGS_publications_per_journal.txt",header = T,sep="\t")

ggplot(pubs_per_year,aes(year, NGS_publications_normalized)) + geom_line (colour="blue",size=2) +
xlab("Year") +
ylab("NGS/100000 articles")+
ggtitle("NGS PubMed articles")
 
ggplot(pubs_per_journal,aes(journal, NGS_publications,fill=journal)) + geom_bar(stat="identity")+
coord_flip()+
theme(legend.position="none")
 
ggplot(pubs_per_journal ,aes(journal, NGS_publications_normalized,fill=journal)) + geom_bar(stat="identity")+
coord_flip()+
theme(legend.position="none")
