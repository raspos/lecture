pacman::p_load("googlesheets", "rvest", "tidyverse", "jsonlite", "ggthemes")
getwd()
a <- read_html("stat19.html")
a <- a %>% 
  html_table(fill = T)
 
aa <- a[[9]]

aa[,1] <- str_c(aa$X1, aa$X2, aa$X3, aa$X4)  
aa <- aa %>% 
  select(-2, -3, -4)

b <- read_html("stat1.html")
b <- b %>% 
  html_table(fill = T)

bb <- b[[5]]

bb[,1] <- str_c(bb$X1, bb$X2, bb$X3, bb$X4)  
bb <- bb %>% 
  select(-2, -3, -4)

c <- read_html("stat19.html")
c <- c %>% 
  html_table(fill = T)

cc <- c[[9]]
cc[,1] <- str_c(cc$X1, cc$X2, cc$X3, cc$X4)  

#### 방법은 2가지 
#1. 모든 데이터를 모아서 한 번에
 
aa <- NULL
for(i in 9:19){
  a <- read_html(str_c("stat", i, ".html")) %>% 
    html_table(fill = T)
  aa <- c(aa, a)
  }
 
bb <- NULL
for(t in 1:length(aa)){
  b <- aa[[t]]
  if(ncol(b) == 24){
    bb <- rbind(bb, b)
  } else {
    b <- b 
    }
}
bb[,1] <- str_c(bb$X1, bb$X2, bb$X3, bb$X4)  
bb <- bb %>% 
  select(-2, -3, -4)
# 날짜를 모르겠네 

#2. 날짜도 같이 긇어보자
d <- read_html("stat1.html")
d <- d %>% 
  html_nodes(xpath = '/html/body/p[3]') %>% 
  html_text()


