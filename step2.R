
#### step2 ####

#### package 설치 ####
### package = 함수를 담아놓음 묶음, 설치할 때 install.pakages("패키지명"), 불러올 때 library(패키지명), 오른쪽 아래 창(Packages)에서 설치 여부 확인
library(tidyverse)
library(rvest)

#### 분석 데이터2 = "리얼미터_지지율 분석", (http://www.realmeter.net/category/pdf/)
# 1. 무엇을 분석할 것인가. = 탐색 과정, 정당지지율 일간 집계 


#### 1. PDF -> HTML ####
# 1-1. adobe acrobat DC에서 PDF 파일 열기
# 1-2. PDF HTML 문서로 내보내기


#### 2. R에서 html 문서 읽기 ####

# 2-1. read_html(html 문서 읽어오기), html_table(table 속성만 뽑아내기), list -> data.frame [[번호]]


Sys.setlocale("LC_ALL","English")


Sys.setlocale("LC_ALL","Korean")

# 2-2. for 반복문, 데이터 모으기(rbind, cbind)
# rbind = 데이터 프레임 아래로 결합(쌓기), 열의 수가 같아야 함.
# cbind = 데이터 프레임 옆으로 결합(쌓기), 행의 수가 같아야 함. 



#### 3. 데이터 전처리 ####
# 무엇을 지울 것인가 결정 ("|"), 

# 3-1. str_remove_all와 str_remove


# 3-2. 반복문의 반목문, nrow, ncol
for(i in 1:nrow(real_5_daily)){
  for(t in 1:ncol(real_5_daily)){
    real_5_daily[i, t] <- real_5_daily[i, t] %>% 
      str_remove_all("\\|")
    print(str_c(i, "번째 행, ", t, "번째 열의 |가 제거됐습니다"))  
  }
}
  
# 3-3. 중복행 제거 unique

# 3-4. 비어있는 열 제거 select(-1, -3, -5, -7, -9, -11, -13, -15, -17, -19, -22)


# 3-5. 칼럼 이름 정하기 colnames


# 3-6. character(문자형 벡터) -> numeric(숫자형 벡터), as.numeric
# gather(하나의 열(벡털)로 데이터 모으기, 변수 = 정당, 지지율)


#### 4. 데이터 분석하기 ####

# 4-1. 필터링 filter(걸러내는)
real_5_daily <- real_5_daily %>% 
  filter(정당 != "계")

real_5_daily1 <- real_5_daily %>% 
  filter(정당 == "민주당" | 정당 == "자유한국당")

real_5_daily1 <- real_5_daily1 %>% 
  spread(정당, 지지율)

real_5_daily1 <- real_5_daily1 %>% 
  mutate(격차 = 민주당 - 자유한국당)

real_5_daily1 <- real_5_daily1 %>% 
  gather(정당, 지지율, 2:4)

# 4-2. 시각화
library(ggthemes)

ggplot(real_5_daily, aes(x = 날짜, y = 지지율, fill = 정당)) +
  geom_bar(stat = "identity") +
  theme_fivethirtyeight(base_family = "AppleGothic") 

# 검증

ggplot(real_5_daily1 %>% 
         filter(정당 != "격차"), aes(x = 날짜, y = 지지율, fill = 정당)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = 지지율), size = 3, vjust = -0.5) +
  theme_fivethirtyeight(base_family = "AppleGothic") 

ggplot(real_5_daily1 %>% 
         filter(정당 == "격차"), aes(x = 날짜, y = 지지율)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = 지지율), size = 3, vjust = -0.5) +
  theme_fivethirtyeight(base_family = "AppleGothic") 

# 4-3. 의미 분석
# 정당별 지지율 분석 
# 날짜별 민주당과 자유한국당의 지지율 차이, 5월 8일, 5월 15일 특이값 분석
 


