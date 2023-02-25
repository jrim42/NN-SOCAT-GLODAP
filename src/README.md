# NN-SOCAT-GLODAP

***
### SOM-FFN 데이터 처리
- 기본적인 nc파일 처리 방식으로 필요한 데이터 저장 (SOM_FFN_v2021.mat)

### SOCAT 데이터 처리
- Read_SOCATv3_v2022.m 실행 후 데이터 저장
- socat.m에서 위의 데이터를 받아 date, lon, lat, fCO2_rec가 있는 timetable 생성
- lonGrd, latGrd와 함께 데이터 저장 (SOCATv2022_NP_2.mat)

***
### boxplot
1. boxplot_year
    - SOCAT과 SOM_FFN data를 year에 따라 나눈 후 boxplot으로 그려서 비교
    - t-test 코드는 영상 마지막 부분에 드래그 해서 표시
    - 독립표본 t-test 결과 p < 0.05로 통계적으로 유의하다는 결과가 나옴 → SOCAT과 SOM_FFN은 연도별 차이에서 유의한 차이가 있음.
    - rmoutlier로 outlier를 제거해도 빨간색으로 표시된 부분이 매우 많음.

2. boxplot_month
    - SOCAT과 SOM_FFN data를 month에 따라 나눈 후 boxplot으로 그려서 비교 (1982년부터)
    - t-test 코드는 영상 마지막 부분에 드래그 해서 표시
    - 독립표본 t-test 결과 p < 0.05로 통계적으로 유의하다는 결과가 나옴 → SOCAT과 SOM_FFN은 월별 차이에서 유의한 차이가 있음.

3. comparison_month
    - SOCAT과 SOM_FFN data를 month에 따라 나눈 후 map을 그림
    - map_comparison 코드에서 year 부분을 조금 수정해서 그린 mapping

***
### map_comparison
- 위에서 저장한 두 개의 .mat file을 받아와서 기본 위도, 경도, 시간의 range를 설정한다.
- cmd창에서 두 가지의 입력을 받는다.
    - mode: 아래의 세 가지 중 하나를 선택할 수 있다.
        (1) annual comparison
        (2) seasonal comparison
        (3) monthly comparison
    - year
- 입력을 이용하여 SOM-FFN의 spCO2 데이터와 SOCAT의 fCO2 데이터에서 필요한 데이터를 얻어낸 후
- 둘의 차이를 보여주는 diff matrix도 생성한다.
- 이후에는 SOM-FFN, SOCAT, diff의 순으로 subplot을 출력한다.

***
### 02/17 meeting
- monthly comaprison에서 12달 모두 창에 출력하면 결과 확인이 어렵기 때문에 수정하기
- subplot title 같은 추가적인 plot setting도 필요
- SOCAT과 SOM-FFN의 절댓값 비교 함수 만들기
- SOCAT data: QC_flag에 데이터 처리 방식을 다르게 할지 생각해보기
- 그리고 또...

***
### 02/24 meeting
- GLODAP: DIC와 Alk로 pCO2 계산하기
    - 표층 데이터 외의 데이터를 사용해도 괜찮을 듯 (pressure 보정)
    - CO2sys -> 검색해보기
- NN: SST data가 없는 상황 -> 온도보정이 필요한데...
    - 온도보정해도 같은 결과면 systematic problem -> 개선의 여지가 있다고 볼 수 있다.
- difference rate
    - 20정도는 알고있는 오차니까 그것을 벗어나는 값을 위주로

- CO2sys
    - pH와 pCO2는 온도와 압력의 영향을 받는다
    - Alk와 DIC는 영향을 안받는다.
    - tempin & tempout (똑같게해도 상관없을 듯?)
    - total scale 사용하기 (사실 뭘 써도 상관 없음)
    - constant는 4번 사용하기
    - 3번의 KSO4 of Dickson ... 사용하기
    - 아마 input condition만 만족시키면 값을 구할 수 있을 것