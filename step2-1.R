
#### library 설치 ####
library(tidyverse)
library(rvest)
######################

#### 분석 데이터2-1 = "리얼미터_지지율 분석", (http://www.realmeter.net/category/pdf/)
# 1. 무엇을 분석할 것인가. = 탐색 과정, 정당지지율 일간 집계 


#### 1. PDF -> HTML ####
# 1-1. adobe acrobat DC에서 PDF 파일 열기
# 1-2. PDF HTML 문서로 내보내기


#### 2. R에서 html 문서 읽기 ####

# 2-1. read_html(html 문서 읽어오기), html_table(table 속성만 뽑아내기), list -> data.frame [[번호]]
preal_5_1 <- read_html('real_5_1.html')

preal_5_1  <- preal_5_1 %>% 
  html_table(fill = T) 
preal_5_1  <- preal_5_1[[10]]

# 2-2. for 반복문, 데이터 모으기(rbind, cbind)
# rbind = 데이터 프레임 아래로 결합(쌓기)
# cbind = 데이터 프레임 옆으로 결합(쌓기)

preal_5_daily <- NULL # 데이터 담을 그릇 만들기 

for(i in 1:4){
  b <- read_html(str_c('real_5_', i, '.html')) # str_c
  b <- b %>% 
    html_table(fill = T) 
  b <- b[[10]]
  preal_5_daily <- rbind(preal_5_daily, b)
  print(str_c(i, "번째 pdf가 변환됐습니다")) # str_c
}

#### 3. 데이터 전처리 ####
# 무엇을 지울 것인가 결정 ("|"), 

# 3-1. 반복문의 반목문, nrow, ncol
for(i in 1:nrow(preal_5_daily)){
  for(t in 1:ncol(preal_5_daily)){
    preal_5_daily[i, t] <- preal_5_daily[i, t] %>% 
      str_remove_all("\\|")
    print(str_c(i, "번째 행", t, "번째 열의 |가 제거됐습니다"))  
  }
}

# 3-2. 중복행 제거 unique
preal_5_daily <- unique(preal_5_daily)

# 3-4. 비어있는 열 제거 select
preal_5_daily <- preal_5_daily %>% 
  select(-1, -3, -5, -7, -9, -11, -13, -15, -18)

# 3-4. 칼럼 이름 정하기 colnames

colnames(preal_5_daily) <- c("날짜", "매우잘한다", "잘하는편", "잘못하는편", "매우잘못함", "잘한다", "잘못한다", "모름무응답", "계")

glimpse(preal_5_daily) # glimpse(벡터 속성 확인하기)

# 3-6. character(문자형 벡터) -> numeric(숫자형 벡터), as.numeric
# gather(하나의 열(벡털)로 데이터 모으기)
preal_5_daily <- preal_5_daily %>% 
  gather(평가, 지지율, 2:9)
preal_5_daily$지지율 <- as.numeric(preal_5_daily$지지율)

#### 4. 데이터 분석하기 ####

# 4-1. 필터링 filter(걸러내는)
preal_5_daily <- preal_5_daily %>% 
  filter(평가 != "계")

# 4-2. 시각화
library(ggthemes)

ggplot(preal_5_daily, aes(x = 날짜, y = 지지율, fill = 평가)) +
  geom_bar(stat = "identity") +
  theme_fivethirtyeight(base_family = "AppleGothic") 

ggplot(preal_5_daily %>% 
         filter(평가 == "잘한다" | 평가 == "잘못한다"), aes(x = 날짜, y = 지지율, fill = 평가)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = 지지율), size = 3, vjust = -0.5) +
  theme_fivethirtyeight(base_family = "AppleGothic") 

preal_5_daily1 <- preal_5_daily %>% 
  filter(평가 == "잘한다" | 평가 == "잘못한다") 
preal_5_daily1 <- preal_5_daily1 %>% 
  spread(평가, 지지율)
preal_5_daily1 <- preal_5_daily1 %>% 
  mutate(격차 = 잘한다 - 잘못한다)
preal_5_daily1 <- preal_5_daily1 %>% 
  gather(평가, 지지율, 2:4)
preal_5_daily1$지지율 <- round(preal_5_daily1$지지율, 1) #round 소숫점 표시

ggplot(preal_5_daily1 %>% 
         filter(평가 == "격차"), aes(x = 날짜, y = 지지율)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = 지지율), size = 3, vjust = -0.5) +
  theme_fivethirtyeight(base_family = "AppleGothic") 

#### 5. 심화 학습 ####
# 5-1. left_join 

real_5_daily1 <- real_5_daily %>% 
  filter(정당 == "민주당" | 정당 == "자유한국당")
real_5_daily1 <- real_5_daily1 %>% 
  spread(정당, 지지율)
preal_5_daily1 <- preal_5_daily %>% 
  filter(평가 == "잘한다" | 평가 == "잘못한다") 
preal_5_daily1 <- preal_5_daily1 %>% 
  spread(평가, 지지율)
treal_5_daily <- left_join(preal_5_daily1, real_5_daily1, by = "날짜")
treal_5_daily <- treal_5_daily  %>% 
  mutate(격차_긍정 = 잘한다 - 민주당, 격차_부정 = 잘못한다 - 자유한국당)
treal_5_daily <- treal_5_daily  %>% 
  gather(분류, 지지율, 2:7)

ggplot(treal_5_daily %>% 
         filter(분류 == "민주당" | 분류 == "잘한다"), aes(x = 날짜, y = 지지율, fill = 분류)) +
  geom_bar(stat = "identity", position = "dodge") +
  coord_flip() +
  geom_text(aes(label = 지지율), size = 3, vjust = -0.5) +
  theme_fivethirtyeight(base_family = "AppleGothic") 


 