


#모든 데이터를 다 다운로드 받으라는 hard coding된 함수
def downlolad_data(year: int) -> str :
    #블록 안에 import해야 kubeflow가 function을 serialise 할 수 있다.

    from datetime import datetime
    from lxml import etree
    from requests import get
    from time import sleep

    import json

    #잠깐... month는 변수로 받아놓고 왜 안써
    def scrapeMailArchives(mailingList: str, year: int, month: int):
        #여기에 좀 ugly 한 xpath 가들어가는데 궁금하면 example repo를 확인해봐라.
        #(들어온 범위에서 1년 어치만 받는듯? range 1,2면 1년이잖아?)
        datesToScrape = [(year, i) for i in range(1,2)]
        #밑에 반복문을 보니까 i가 month인거 같은데? 변수 이름 ㅡㅡ
        records = []


        for y,m in datesToScrape:
            print(m, "-", y)
            #recursive function이 갑자기 여기에?
            #보니까 2겹짜리 html인거 같은데?
            #위에 mailing List에 들어가는 최초의 list에서
            #한번 껍데기를 까고, spark-dev라는 거에서 같은 작업을
            #한번 더하나 본데
            #이러면 readbility가 떨어지니까 데이터 받는 부분을 다른 함수로 쪼개야 되는게 맞지 않나
            records += scrapeMailArchives("spark-dev", y, m)
            output_path = '/data_processing/data.json'
            #이상하다.. 아무리 봐도 recursive가 ending이 되는 조건이 없는데?
            with open(output_path,'w') as f:
                json.dump(records, f)
        return output_path
        


