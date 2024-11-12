#!/bin/sh

exec docker run --rm \
  -e EXCHANGE="BINANCE_FUTURES" \
  -e CHANNELS="trades,l2_book,open_interest,funding,liquidations,book_delta" \
  -e SYMBOLS="BTC-USDT-PERP,ETH-USDT-PERP" \
  -e BACKEND="PARQUET" \
  -e CONFIG="/kucoin_config.yaml" \
  leftys/cryptostore:latest
