# NN-SOCAT-GLODAP
- 해양환경연구실 학부생 인턴 팀과제
- comparison of NN-SOCAT/GLODAP data of North Pacific

***
1. `mission 00`
    - m_map toolbox를 이용하여 SOM-FFN data를 'Interrupted Mollweide Projections'으로 구현
    <img width="1112" alt="스크린샷 2023-02-27 오전 1 47 28" src="https://user-images.githubusercontent.com/90167645/221424262-b4aa9313-0807-446e-8384-568b361fe8f0.png">
2. `mission 01`
    - 북서태평양 한정으로, SOM-FFN 결과를 raw data인 SOCAT과 비교
        - 상관관계, 절대값 차이 (단순 비교)
        - SOM-FFN 자료와 raw data의 차이가 큰 지점의 특징 찾기 (연구)
    <img width="1268" alt="스크린샷 2023-02-27 오전 1 15 48" src="https://user-images.githubusercontent.com/90167645/221424342-47b8d3cf-d9a6-42b6-9ed7-1e4ce282094f.png">

3. `mission 02`
    - 북서태평양 또는 전 대양을 대상으로, SOM-FFN의 결과를 Glodap 자료와 비교

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
