library(RMySQL)
library(ggplot2)

db = dbConnect(MySQL(),user='root',dbname='cit_asset',host='localhost')
rs = dbSendQuery(db, "select asset_number,kelompok_aset,
                      nm11_2017,
                      dm11_2017
                      from far_depre where write_off_date is null and
                      bulk_2005_write_off_date is null group by asset_number
                      order by rand() limit 10")
data = fetch(rs, n=-1)
data$kelompok_aset <- as.factor(data$kelompok_aset)

depreLogLabel = c('Rp.10.000','Rp.100.000','Rp.1.000.000','Rp.10.000.000','Rp.100.000.000','Rp.1.000.000.000')
depreBreakScale = c(10^4,10^5,10^6,10^7,10^8,10^9)
nbvLogLabel = c('Rp.100.000','Rp.1.000.000','Rp.10.000.000','Rp.100.000.000','Rp.1.000.000.000','Rp.10.000.000.000','Rp.100.000.000.000')
nbvBreakScale = c(10^5,10^6,10^7,10^8,10^9,10^10,10^11)

depre_plot <- ggplot(data, aes(data$kelompok_aset,data$dm11_2017))+
  geom_violin(trim = TRUE,fill='#A4A4A4',scale='count')+geom_boxplot(width=0.1)+
  labs(title='Depreciation Amount Distribution 100.000 sample',x='Kelompok Aset',y='Depreciation')+
  scale_y_continuous(labels = depreLogLabel, trans = 'log10', breaks = depreBreakScale)
depre_plot

nbv_plot <- ggplot(data, aes(data$kelompok_aset,data$nm11_2017))+
  geom_violin(trim = TRUE,fill='#A4A4A4',scale='count')+geom_boxplot(width=0.1)+
  labs(title='Net Book Value Amount Distribution 100.000 sample',x='Kelompok Aset',y='Net Book Value')+
  scale_y_continuous(labels = nbvLogLabel, trans = 'log10', breaks = nbvBreakScale)
nbv_plot

pie_data_depre <- aggregate(dm11_2017~kelompok_aset,data,sum)
pie(pie_data_depre$dm11_2017,labels = pie_data_depre$kelompok_aset,
    title='Porsi depre per kelompok aset (sample 100.')+
    title('Proporsi depre per kelompok aset, sample 100.000')

pie_data_nbv <- aggregate(nm11_2017~kelompok_aset,data,sum)
pie(pie_data_nbv$nm11_2017,labels = pie_data_nbv$kelompok_aset,
    title='Porsi depre per kelompok aset (sample 100.')+
    title('Proporsi depre per kelompok aset, sample 100.000')

############################################################################################
library(dplyr)
library(ggplot2)
library(ggrepel)
library(forcats)
library(scales)
db = dbConnect(MySQL(),user='root',dbname='history',host='localhost')
rs = dbSendQuery(db, "SELECT regional, site_id, site_name, far_depre_2014.asset_number,cost
                      FROM far_depre_2014
                      LEFT JOIN migration.`site_2009_2015`
                      ON `site_2009_2015`.asset_number = far_depre_2014.asset_number;")
data = fetch(rs, n=-1)
blank_theme <- theme_minimal()+
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.border = element_blank(),
    panel.grid=element_blank(),
    axis.ticks = element_blank(),
    plot.title=element_text(size=14, face="bold")
  )

sumCostByRegional <- aggregate(cost~regional,data,sum)
sumCostByRegional %>%
  arrange(desc(cost)) %>%
  mutate(prop = percent(cost / sum(cost))) -> sumCostByRegional
pie <- ggplot(sumCostByRegional, aes(x = "", y = cost, fill = fct_inorder(regional))) +
  geom_bar(width = 1, stat = "identity") + blank_theme + 
theme(axis.text.x = element_blank())
  coord_polar("y", start = 0) +
  geom_text(aes(y = cost, label = prop), size = 5)
pie