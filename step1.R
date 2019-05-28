#### step1 ####

#### package 설치 ####
### package = 함수를 담아놓음 묶음, 설치할 때 install.pakages("패키지명"), 불러올 때 library(패키지명), 오른쪽 아래 창(Packages)에서 설치 여부 확인

install.packages("tidyverse") # tidyverse는 데이터를 불러오고, 정리하고, 변형하는 함수가 내장된 패키지. 시각화, 모델링 함수도 적용.
install.packages("rvest") # 웹에 있는 html 문서를 읽어올 때 사용하는 함수 묶음.  
library(tidyverse) 
library(rvest) 

#### 분석 데이터1 = "연도별 정부포상 현황", 행정안전부 자료(흔히 보도자료로 나올 수 있을 만한...) ####
# 변수가 무엇인지 탐색 (연도, 계, 훈포장 소계, 훈포장 훈장, 훈포장 포장, 표창 소계, 표창 대표, 표창 국표) # 8개

#### 1. PDF -> HTML ####
# 1-1. adobe acrobat DC에서 PDF 파일 열기
# 1-2. PDF HTML 문서로 내보내기

#### 2. R에서 html 문서 읽기 ####

# 2-1. read_html(html 문서 읽어오기), html_table(table 속성만 뽑아내기), list -> data.frame [[번호]]
prize_2018 <- read_html('prize_2018.html')

prize_2018 <- prize_2018 %>% 
  html_table(fill = T) 

prize_2018 <- read_html('prize_2018.html')

prize_2018 <- html_table(prize_2018, fill = T)

prize_2018 <- prize_2018[[1]]

#### 3. 데이터 전처리 ####

# 3-1. str_c(붙이기)
prize_2018[1, ] <- str_c(prize_2018[1, ], "_", prize_2018[2, ]) 

# 3-2. colnames(열 이름)
colnames(prize_2018) <- c("연도", "계", "훈포장_소계", "훈포장_훈장", "훈포장_포장", "표창_계", "표창_대표", "표창_국표")
colnames(prize_2018) <- prize_2018[1, ]  

# 3-3. slice(행을 추출하거나 잘라내고), select(열을 제외하거나 뽑아내고)
prize_2018 <- prize_2018 %>% 
  slice(-1, -2, -3) %>% 
  select(-2, -3, -6)

# 3-4. glimpse(벡터 속성 확인하기)
glimpse(prize_2018) 
prize_2018[1, 4] - prize_2018[1, 5]

# 3-5. str_remove(필요없는 문자 지우기, 정규표현식 = 특수문자에는 \\), character(문자형 벡터) -> numeric(숫자형 벡터), as.numeric
prize_2018$훈포장_훈장 <- prize_2018$훈포장_훈장 %>% 
  str_remove("\\,") %>% 
  as.numeric()  

# 반복문으로 간편하게 
for(i in 2:5){
  prize_2018[,i] <- prize_2018[,i] %>% 
    str_remove("\\,") %>% 
    as.numeric()
}

glimpse(prize_2018) #double(숫자형)

#### 4. 데이터 분석하기 ####

# 4-1. mutate(데이터프레임에 조건을 만족하는 새로운 열(변수)를 만들거나, 기존의 열을 조건에 맞게 변경할 때 사용)

prize_2018 <- prize_2018 %>% 
  mutate(훈포장_계 = 훈포장_훈장 + 훈포장_포장,
         표창_계 = 표창_대표 + 표창_국표)

# 4-2. gather(모으고), spread(펼치고), separate(분리하고)

prize_2018 <- prize_2018 %>% 
  gather(cate, num, 2:7) # 왜 모으는 지는 그래프 그려보면 알 수 있음

prize_2018 <- prize_2018 %>% 
  spread(cate, num) # mutate, summarise 연산할 때 편함

prize_2018 <- prize_2018 %>% 
  separate(cate, c("cate1", "cate2"), sep = "\\_")

# 4-3. 시각화
library(ggthemes)

ggplot(prize_2018 %>% 
         filter(연도 != "48∼97", cate2 != "계"), aes(x = 연도, y = num, fill = cate2)) +
  geom_col() +
  theme_fivethirtyeight(base_family = "AppleGothic") 
  
# 4-4. 의미 분석
# 변수를 바꿔 넣어가면서 의미를 분석, filter(특정 요건에 맞춰 데이터 추출하는 함수)
# 정권 별로 그룹화해서 특정 정권에 포상을 남발한 원인 분석(월 단위 데이터 요청) 
# 특정연도에 늘어난 이유(예 : 99년 “공무원의 명예퇴직이나 교원들의 정년 인하로 퇴직자가 늘어 갑작스럽게 국민훈장과 근정훈장에 대한 수요가 증가했기 때문”) (훈장의 세부종류별 데이터 요청)    

#### 5. 실제 데이터로 실습하기 ####

