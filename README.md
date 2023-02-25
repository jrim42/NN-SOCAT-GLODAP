# comparison of NN-SOCAT-GLODAP (North Pacific)
고려대학교 해양환경연구실 인턴 팀과제

***
1. mission 01
    - 북서태평양 한정으로, SOM-FFN 결과를 raw data인 SOCAT과 비교해본다.
        - 상관관계, 절대값 차이 (단순 비교)
        - SOM-FFN 자료와 raw data의 차이가 큰 지점의 특징 찾기 (연구)
2. mission 02
    - 북서태평양 또는 전 대양을 대상으로, SOM-FFN의 결과를 Glodap 자료와 비교해본다.

***
### SOM-FFN (NN)
- AI로 추정한 전 지구적 범위의 각 위경도 1도에 해당하는 spCO2 값
    - self-organizing maps (SOMs) to cluster data
    - feed-forward networks (FFNs) to reconstruct mapped fields from sparse data.
- `.nc` file

### SOCAT
- The Surface Ocean CO2 Atlas
- Underway로 측정한 특정 지역 범위에 해당하는 fCO2 값
- a synthesis activity for quality-controlled, surface ocean fCO2 (fugacity of CO2) observations by the international marine carbon research community (>100 contributors).
- `.tsv` file

### GLODAP