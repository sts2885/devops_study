<h1>개인 공부를 위해 기존에 다른분들이 개발하신 instagram clone code를 fork해 가지고 왔습니다.</h1>

원본의 링크는

[여기에 있습니다.](https://github.com/Instagram-Clone-Coding)
<h2>원본 레포지토리에는 개발된 front-end, back-end의 코드가 aws ec2에만 올라가는 구조로 되어 있었지만,</h2>


저는 이를 EKS에 띄우려고 합니다.

Dockerfile, Terraform 코드, yaml 파일을 작성해 eks 배포를 할 예정 입니다.


#repo 구성

#기존 개발을 진행했던 팀의 구조를 최대한 가져갑니다.
- Frontend repo : https://github.com/sts2885/React_instagram_clone/tree/release_v_1
- Backend repo : https://github.com/sts2885/Spring_instagram-clone/tree/release_v_1
- Deploy repo : https://github.com/sts2885/devops_study


# Frontend와 Backend repo
이 프로젝트가 agile 기반으로 개발되지는 않았지만, 그렇다고 가정하고,
Frontend, 와 Backend repo의 중간 중간에 release branch를 분기합니다.

그 뒤에 release branch에서는 약간의 syntax error나 version 등의 문제를 해결하고 (hotfix), Dockfile을 생성합니다.  

# Deploy repo 
마음만 같아서는 infra-cluster repo와 manifest repo를 나누고 싶은데
그러기 보다는 같은 repository에 두고 release branch(manifest)와 cluster branch만 나눠 둡니다.  
##둘을 굳이 decoupling하는 이유는 이러면 다른 프로젝트 수행시 재사용도 가능하고, infra+release 라는 복합 이슈를 다루지 않고 각자 파트만 집중할 수 있기에 나눴습니다.

#infra-cluster : https://github.com/sts2885/devops_study/tree/dev_kube_study
  
#release : https://github.com/sts2885/devops_study/tree/instagram-release-v1.0

## jenkins 등록할 repo는 위 3개 전부 입니다.
### front, backend는 코드 변경시 dockerize
### deploy 는 dockerize의 결과물이 manifest로서 push된 것을 감지하여, eks배포를 맡습니다.

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ