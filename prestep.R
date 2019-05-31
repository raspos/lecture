
#### prestep ####

#### dataframe 데이터프레임 ####

### 1. 데이터프레임(dataframe)은?
## 데이터 프레임은 행과 열로 이뤄진 자료구조입니다. 
## 엑셀과 같이 숫자, 문자 등 다양한 데이터를 하나의 테이블에 담을 수 있습니다.
## 우리가 쉽게 접할 수 있는 형태, 분석이 용이해서 취재에서 활용할 수 있는 자료형태입니다. 
## a <- b 는 변수 a에 b를 담는다는 의미 


### 2. 데이터프레임의 데이터(값)에 접근하는 방법
## data(데이터프레임)$colname(열이름)


## data[행, ], data[,열], data[행, 열]


### 3. 데이터프레임 변수의 유형을 알아보는 함수


### 4. 열=변수=벡터
## 각 변수의 유형
# int = 정수(숫자열)
# dbl = 실수(숫자열)
# num = 숫자형 벡터(숫자열)
# chr = 문자형 벡터(문자열)
# fct(factor) = 범주형 데이터(사전에 정해진 특정 유형으로만 분류) == 문자열 

### 5. 변수 유형 바꾸기


## 숫자형 벡터 중요한 이유 = 연산


### 6. 데이터프레임 이름 바꾸기

#### 실제 데이터를 갖고 실습하기 ####

df_manager <- readr::read_csv('https://docs.google.com/spreadsheets/d/e/2PACX-1vTMk1a3Ob7Cdu99TDmf1kULHXgj79XDP-__vDGFaAoApKlS0kyyhgNZD2-lNk6td73Zwb6zTZoq0BBt/pub?gid=831508092&single=true&output=csv')

#1. 데이터프레임{df_manager}에서 감독 연봉 데이터를 변수 salary에 담아보세요. 

#2. {df_manager}의 자료구조를 파악해 보세요.

#3. {df_manager}에서 변수 순위를 문자형으로 바꿔보세요.  

#4. 트레이 힐만 감독의 연봉과 김한수 감독의 연봉의 차이를 계산해 보세요.

#5. {df_manager}의 열 이름(변수명)을 영어로 바꿔보세요. ex) 순위 = rank, 이름 = name, 연봉 = salary, 소속팀 = team

