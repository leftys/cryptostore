FROM python:3.10-slim-bullseye as build-stage

ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

RUN apt-get update && \
	apt-get install --no-install-recommends -y git gcc g++ && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean 

RUN --mount=type=cache,target=/root/.cache/pip \
	pip install --no-cache-dir -U pyarrow cython uvloop yapic.json pip
#ADD "http://www.randomnumberapi.com/api/v1.0/random?min=100&max=1000&count=5" skipcache
RUN  --mount=type=cache,target=/root/.cache/pip pip install --no-cache-dir git+https://github.com/leftys/cryptofeed.git@parquet-backend

FROM python:3.10-slim-bullseye as final

RUN apt-get update && \
	apt-get install --no-install-recommends -y netcat rlwrap && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean 
COPY --from=build-stage /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY kucoin_config.yaml cryptostore.py /

CMD ["/cryptostore.py"]
ENTRYPOINT ["python"]
