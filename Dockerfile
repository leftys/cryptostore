FROM python:3.10-slim-bullseye as build-stage

# Virtualenv
#RUN python -m venv /usr/src/env
#ENV VIRTUAL_ENV=/usr/src/env
#ENV PATH="$VIRTUAL_ENV/bin:$PATH"
ENV PIP_ROOT_USER_ACTION=ignore
ENV PIP_DISABLE_PIP_VERSION_CHECK=1


RUN apt-get update && \
	apt-get install --no-install-recommends -y git gcc g++ && \
	rm -rf /var/lib/apt/lists/* && \
	apt-get clean 
# RUN pip install --no-cache-dir cython wheel && \
RUN \
	pip install --no-cache-dir pyarrow==7.0.0 && \
	pip install --no-cache-dir git+https://github.com/leftys/orderbook.git
RUN pip install --no-cache-dir git+https://github.com/leftys/cryptofeed.git@parquet-backend

FROM python:3.10-slim-bullseye as final

#ENV VIRTUAL_ENV=/usr/src/env
#ENV PATH="$VIRTUAL_ENV/bin:$PATH"

#COPY --from=build-stage $VIRTUAL_ENV $VIRTUAL_ENV
COPY --from=build-stage /usr/local/lib/python3.10/site-packages /usr/local/lib/python3.10/site-packages
COPY kucoin_config.yaml cryptostore.py /

CMD ["/cryptostore.py"]
ENTRYPOINT ["python"]
