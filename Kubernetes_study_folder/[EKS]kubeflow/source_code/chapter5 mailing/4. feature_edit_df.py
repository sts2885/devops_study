
#이 부분 대충 적고 넘어가서 실제로 돌아가는지 확인 할 방법이 없어보이는데?
import pandas as pd

#feature에 text processing function을 combining하는 법

df['domains'] = df['links'].apply(extract_domains)
df['isThreadStart'] = df['depth'] == 0

#dataset을 빌딩하는 걸 split할 수 있다. -> 실제 witchcraft로 부터 멀게 하기 위해
from sklearn.feature_extraction.text import TfidVectorizer

bodyV = TfidfVectorizer()
bodyFeatures = bodyV.fit_transform(df['body'])

domainV = TfidVectorizer()

def makeDomainsAList(d):
    return ' '.join([a for a in d if not a is None])

domainFeatures = domainV.fit_transform(
    df['domains'].apply(makeDomainsAList)
)

from scipy.sparse import csr_matrix, hstack

data = hstack([
    csr_matrix(df[[
        'containsPythonStackTrace', 'containsJavaStackTrace',
        'containsExceptionInTaskBody', 'isThreadStart'
    ]].to_numpy()), bodyFeatures, domainFeatures
])


