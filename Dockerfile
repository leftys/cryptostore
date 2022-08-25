FROM python:3.10-slim-bullseye

RUN apt-get update
RUN apt-get install -y gcc g++ git

ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

RUN pip install --no-cache-dir cython
RUN pip install --no-cache-dir aioredis
RUN pip install --no-cache-dir pymongo[srv]
RUN pip install --no-cache-dir motor
RUN pip install --no-cache-dir asyncpg
RUN pip install --no-cache-dir pyarrow==7.0.0
RUN pip install --no-cache-dir git+https://github.com/leftys/orderbook.git
RUN pip install --no-cache-dir git+https://github.com/leftys/cryptofeed.git@parquet-backend

COPY kucoin_config.yaml /
COPY cryptostore.py /cryptostore.py

CMD ["/cryptostore.py"]
ENTRYPOINT ["python"]
