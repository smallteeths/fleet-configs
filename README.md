本次测试
#直接运行./demo_web.py 即可看到5000端口暴露一个web UI ，修改templates中index.html文件中的版本信息离开测试不同的tag.


#修改templates中的"版本"修改为1.0.0
#容器测试-先build一个1.0.0版本。
docker build -t my-demo-web:1.0.0 .
#Run测试
docker run -p 5001:5000 my-demo-web:1.0.0


#修改templates中的"版本"修改为2.0.0然后打包
docker build -t my-demo-web:2.0.0 .
docker run -p 5001:5000 my-demo-web:2.0.0

#安装fleet
helm repo add fleet https://rancher.github.io/fleet-helm-charts/
helm -n cattle-fleet-system install --create-namespace --wait fleet-crd \
    fleet/fleet-crd
helm -n cattle-fleet-system install --create-namespace --wait fleet \
    fleet/fleet

#先填写好secret,然后应用fleet中的GirRepo.yaml即可。



# 为镜像仓库创建 Secret
kubectl create secret docker-registry aliyun-registry-secret \
  --docker-server=registry.cn-shanghai.aliyuncs.com \
  --docker-username=<your-aliyun-username> \
  --docker-password=<your-aliyun-password> \
  --namespace=fleet-local
#fleet-控制器信任ca证书

kubectl -n cattle-fleet-system create secret generic custom-ca \
  --from-file=ca.crt=./my-ca.crt

kubectl -n cattle-fleet-system patch deployment fleet-controller --type=json -p='[
  {
    "op": "add",
    "path": "/spec/template/spec/volumes/-",
    "value": {
      "name": "custom-ca",
      "secret": {
        "secretName": "custom-ca"
      }
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/volumeMounts/-",
    "value": {
      "name": "custom-ca",
      "mountPath": "/etc/ssl/certs/custom-ca.crt",
      "subPath": "ca.crt",
      "readOnly": true
    }
  },
  {
    "op": "add",
    "path": "/spec/template/spec/containers/0/env/-",
    "value": {
      "name": "SSL_CERT_FILE",
      "value": "/etc/ssl/certs/custom-ca.crt"
    }
  }
]'

进入fleet-控制器验证
printenv SSL_CERT_FILE





#https://docs.github.com/zh/authentication/keeping-your-account-and-data-secure/managing-your-personal-access-tokens#%E5%9C%A8%E5%91%BD%E4%BB%A4%E8%A1%8C%E4%B8%8A%E4%BD%BF%E7%94%A8-personal-access-token
# 为 GitHub 仓库创建 Secret（使用个人访问令牌）
kubectl create secret generic github-secret \ 
    -n fleet-local \
    --type=kubernetes.io/basic-auth \
    --from-literal=username=$user \
    --from-literal=password=$pat


