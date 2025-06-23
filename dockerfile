# 使用官方的Python镜像作为基础镜像
FROM m.daocloud.io/docker.io/python:3.8-slim-buster

# 设置工作目录
WORKDIR /app

# 将当前目录的内容复制到工作目录中
COPY . /app

# 更改pip源为清华大学的镜像源
RUN mkdir -p /root/.pip && echo "[global]\ntrusted-host =  pypi.tuna.tsinghua.edu.cn\nindex-url = https://pypi.tuna.tsinghua.edu.cn/simple" > /root/.pip/pip.conf

# 安装Flask
RUN pip install --no-cache-dir flask

# 暴露端口5000供应用使用
EXPOSE 5000

# 定义环境变量
ENV FLASK_APP=demo_web.py

# 当容器启动时运行 Flask 应用
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
