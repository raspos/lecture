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
# 국토부 보도자료(http://www.molit.go.kr/USR/NEWS/m_71/dtl.jsp?lcmspage=1&id=95082344)

# 1. read_html()와 html_table() 함수를 이용해 training.html의 데이터를 가져와 {df_country}에 담아보세요.   
df_country <- read_html('training.html')

df_country <- df_country %>% 
  html_table(fill = T)

# 2. {df_country}의 7번째 데이터프레임을 {df_country}에 담아보세요. 
df_country <- df_country[[7]]

# 3. {df_country}의 열 이름을 {df_country}의 첫행으로 바꿔보세요.
# 3-1. 1~3번째 '행'을 slice() 함수를 이용해 지워보세요.
colnames(df_country) <- df_country[1,]
df_country <- df_country %>% 
  slice(-1, -2, -3)
 
# 4. {df_country}의 자료구조를 파악해 보세요.
glimpse(df_country)

# 5. gather() 함수를 이용해 {df_country}의 숫자형태(아직은 문자형인) 데이터(2열부터 9열까지)를 모아보세요. 변수는 cate, num입니다.
df_country <- df_country %>% 
  gather(cate, num, 2:9)

# 6. {df_country}의 변수 num(df_country$num)에서 str_remove_all() 함수를 이용해 ','를 지운 뒤 문자형을 숫자형으로 변환하는 함수 as.numeric()을 써서 숫자형 데이터로 변환해 보세요.
df_country$num <- df_country$num %>% 
  str_remove_all("\\,") %>% 
  as.numeric()

# 7. spread() 함수를 이용해  {df_country}의 숫자형 데이터를 펼쳐보세요. 
df_country <- df_country %>% 
  spread(cate, num)

# 8. mutate() 함수를 이용해 17개 지자체 토지 가운데,
# 8-1. 하천이 차지하는 비율을 계산해 변수 '하천_비율'에 담아보세요.
# 8-2. 전, 답, 대 면적의 합을 계산해 변수 '농지'에 담아보세요.
df_country <- df_country %>% 
  mutate(하천_비율 = (`하천(㎢)` / `계(㎢)`) * 100, 농지 = `전(㎢)` + `답(㎢)` + `대(㎢)`)

