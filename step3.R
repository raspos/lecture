#### step3 ####

#### package 설치 ####
### package = 함수를 담아놓음 묶음, 설치할 때 install.pakages("패키지명"), 불러올 때 library(패키지명), 오른쪽 아래 창(Packages)에서 설치 여부 확인
library(tidyverse)
library(rvest)

#### 분석 데이터3 = "고위공직자 재산공개 분석" 
 
#### 1. PDF -> HTML ####
# 1-1. adobe acrobat DC에서 PDF 파일 열기
# 1-2. PDF HTML 문서로 내보내기

url <- c("ulsan")

#### 1. df_gov == 최종 저장 자료 ####
df_gov <- NULL
df_gov_total <- NULL

#### 1-1. error ####
df_error <- NULL
df_error1 <- NULL
df_error2 <- NULL
df_error_6 <- NULL
df_error_6name <- NULL
pro3_error <- NULL

#### 1-2 HTML 읽기 ####
pro <- read_html(str_c(url, '.html'))

### 1-3. 데이터 테이블 추출 ####
pro_all <- pro %>%
  html_nodes('table') %>%
  html_table(fill = TRUE, trim = TRUE)  

###### 2. table 만들기 ######
pro3 <- NULL
pro9 <- NULL
pro12 <- NULL

for(i in 1:length(pro_all)){
  pro1 <- pro_all[[i]]
  if(ncol(pro1) == 8) {
    pro1 <- pro1
  } else if(ncol(pro1) == 9) {
    pro1 <- pro1 %>% 
      select(-X4)
    colnames(pro1) <- colnames(pro3)
  } else if(ncol(pro1) == 7) {
    pro1 <- pro1 %>% 
      separate(X7, c("X7", "X8"), sep = " ")
  } else if(ncol(pro1) == 6) {
    df_error_6 <- rbind(df_error_6, pro1) 
  } else if(ncol(pro1) == 10) {
    pro1 <- pro1 %>% 
      select(-X4, -X10)
    colnames(pro1) <- colnames(pro3)
  } else if(ncol(pro1) == 11) {
    print("예외처리 발생")
    df_error1 <- rbind(df_error1, pro1)
  } else {
    print("예외처리 발생")
    df_error2 <- rbind(df_error2, pro1)
  }  
  
  if(ncol(pro1) == 7 | ncol(pro1) == 8 | ncol(pro1) == 9){
    for(k in 1:nrow(pro1)){
      if(pro1[1,1] == "소 속" | pro1[1,1] == "소속" | is.na(pro1[1,1])){
        pro20 <- pro1[1,8]
        pro21 <- pro1[1,2]
        pro22 <- pro1[1,5]
      } else {
        pro23 <- pro23
      }
      print(i)
      pro23 <- cbind(pro20, pro21, pro22)
      pro9 <- rbind(pro9, pro23)
    }  
  } else {
    for(k in 1:nrow(pro1)){
      if(pro1[1,1] == "소 속" | pro1[1,1] == "소속" | is.na(pro1[1,1])){
        pro20 <- pro1[1,8]
        pro21 <- pro1[1,2]
        pro22 <- pro1[1,5]
      } else {
        pro23 <- pro23
      }
      print(i)
      pro23 <- cbind(pro20, pro21, pro22)
      df_error_6name <- rbind(df_error_6name, pro23)
    }
    pro1 <- NULL
  }
  pro3 <- rbind(pro3, pro1)
}

pro3 <- cbind(pro9, pro3)

#### 3. 2차 정제 ####

pro3 <- pro3 %>%
  filter(!str_detect(X1, "본인과의 관계"), !str_detect(X1, "본인과 의 관계"), !str_detect(X1, "소속"), !str_detect(X1, "단위"))

pro3 <- pro3 %>%
  mutate(cate1 = "0")
pro3 <- pro3[, c(1:3, 12, 5, 4, 6:11)]

pro3$X2[is.na(pro3$X2)] <- ""
for(i in 1:nrow(pro3)){
  if(str_detect(pro3$X2[i], "\\▶")){
    pro3$cate1[i] <- pro3$X2[i]
    print(i)
  } else {
    pro3$cate1[i] <- pro3$cate1[i]
  }
}

for(i in 1:nrow(pro3)){
  if(str_detect(pro3$cate1[i], "\\▶")){
    pro3$cate1[i] <- pro3$cate1[i]
    print(i)
  }else{
    pro3$cate1[i] <- pro3$cate1[i-1]
  }
}

pro3$cate1 <- pro3$cate1 %>%
  str_remove_all("▶") %>%
  str_remove_all("\\(소계\\)") %>%
  str_replace_all("\\․", ",")

pro4 <- pro3 %>%
  filter(str_detect(X1, "\\▶"))
df_gov_total <- rbind(df_gov_total, pro4)

pro3 <- pro3 %>%
  filter(!str_detect(X1, "\\▶"))

colnames(pro3) <- c("name", "company", "position", "cate1", "cate2", "owner", "right", "l_money", "plus", "minus", "p_money", "etc")

pro5 <- pro3 %>%
  filter(str_detect(owner, "총"))
pro3 <- pro3 %>%
  filter(!str_detect(owner, "총"))

for(i in 1:nrow(pro3)){
  if(pro3$cate2[i] == ""){
    pro3$cate2[i] <- pro3$cate1[i]
  } else {
    pro3$cate2 <- pro3$cate2
  }
}

pro3 <- pro3 %>% 
  mutate(개별index = str_c(name, "-", company, "-", position), location = url)

for(i in 1:nrow(pro3)){
  if(pro3$owner[i] == ""){
    print(i)
    a <- str_c(pro3$right[i-1], pro3$right[i])
    pro3$right[i-1] <- ""
    pro3$right[i-1] <- a
  } else {
  }
} 

for(k in 1:11){
  pro3 <- pro3 %>%
    filter(pro3[k] != "")
}

pro3 <- pro3 %>%
  separate(col = plus, c("plus", "real_plus"), sep = "\\(")
pro3 <- pro3 %>%
  separate(col = minus, c("minus", "real_minus"), sep = "\\(")

for(i in 1:nrow(pro3)){
  for(t in 8:14){
    pro3[i,t] <- pro3[i,t] %>% 
      str_remove("\\)") %>% 
      str_remove(" /") %>%
      str_remove_all(",") %>%
      str_replace_na(0) %>% 
      str_replace("\\-", "0") 
    print(i)
  }
}

colnames(pro3) <- c("성명", "소속", "직위", "재산의 종류", "대분류",  "본인과의 관계", "소재지 면적 등 권리의 명세", 
                    "종전가액", "증가액", "증가액_실거래가", "감소액",  "감소액_실거래가", "현재가액", "변동사유", "개별index", "지역")

pro3$종전가액 <- as.numeric(pro3$종전가액)
pro3$증가액 <- as.numeric(pro3$증가액) 
pro3$증가액_실거래가 <- as.numeric(pro3$증가액_실거래가)
pro3$감소액 <- as.numeric(pro3$감소액)
pro3$감소액_실거래가 <- as.numeric(pro3$감소액_실거래가)
pro3$현재가액 <- as.numeric(pro3$현재가액)
pro3_go <- NULL
for(i in 1:nrow(pro3)){
  if(pro3$종전가액[i] + pro3$증가액[i] - pro3$감소액[i] !=  pro3$현재가액[i] | is.na(pro3$종전가액[i]) | is.na(pro3$현재가액[i])){
    test_a <- pro3[i,]
    print(i)
    pro3_error<- rbind(pro3_error, test_a)  
  } else {
    test_b <- pro3[i,]
    pro3_go <- rbind(pro3_go, test_b)
  }
}

df_gov <- rbind(df_gov, pro3_go)

df_gov$`재산의 종류` <- df_gov$`재산의 종류` %>% 
  str_remove_all(" ") %>% 
  str_remove_all(",")

df_gov$대분류 <- df_gov$대분류 %>% 
  str_remove_all(" ") %>% 
  str_remove_all(",")

df_gov$`본인과의 관계` <- df_gov$`본인과의 관계` %>% 
  str_remove_all(" ") %>% 
  str_remove_all(",")

write_excel_csv(df_gov, "gov_ulsan_2019.csv")

write_excel_csv(pro3_error, 'gov_ulsan_2019_error.csv')
 
df_gov %>% 
  group_by(개별index) %>% 
  count()

