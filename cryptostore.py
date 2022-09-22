'''
Copyright (C) 2018-2022  Bryant Moscon - bmoscon@gmail.com
Please see the LICENSE file for the terms and conditions
associated with this software.
'''
from datetime import datetime
import os

from cryptofeed import FeedHandler
from cryptofeed.exchanges import EXCHANGE_MAP
from cryptofeed.feed import Feed
from cryptofeed.defines import L2_BOOK, TICKER, TRADES, FUNDING, CANDLES, OPEN_INTEREST, LIQUIDATIONS
from cryptofeed.backends.parquet import BookParquet, TradeParquet, TickerParquet, FundingParquet, CandlesParquet, OpenInterestParquet, LiquidationsParquet


async def tty(obj, receipt_ts):
    # For debugging purposes
    rts = datetime.utcfromtimestamp(receipt_ts).strftime('%Y-%m-%d %H:%M:%S')
    print(f"{rts} - {obj}")


def load_config() -> Feed:
    exchange = os.environ.get('EXCHANGE')
    symbols = os.environ.get('SYMBOLS')

    if symbols is None:
        raise ValueError("Symbols must be specified")
    symbols = symbols.split(",")

    channels = os.environ.get('CHANNELS')
    if channels is None:
        raise ValueError("Channels must be specified")
    channels = channels.split(",")

    config = os.environ.get('CONFIG')
    backend = os.environ.get('BACKEND')
    snap_only = os.environ.get('SNAPSHOT_ONLY', False)
    if snap_only:
        if snap_only.lower().startswith('f'):
            snap_only = False
        elif snap_only.lower().startswith('t'):
            snap_only = True
        else:
            raise ValueError('Invalid value specified for SNAPSHOT_ONLY')
    snap_interval = os.environ.get('SNAPSHOT_INTERVAL', 1000)
    snap_interval = int(snap_interval)
    host = os.environ.get('HOST', '127.0.0.1')
    port = os.environ.get('PORT')
    if port:
        port = int(port)
    candle_interval = os.environ.get('CANDLE_INTERVAL', '1m')
    database = os.environ.get('DATABASE')
    user = os.environ.get('USER')
    password = os.environ.get('PASSWORD')
    org = os.environ.get('ORG')
    bucket = os.environ.get('BUCKET')
    token = os.environ.get('TOKEN')

    cbs = None
    if backend == 'PARQUET':
        kwargs = {'path': ''}
        cbs = {
            L2_BOOK: BookParquet(**kwargs, snapshot_interval=snap_interval, max_depth=20),
            TRADES: TradeParquet(**kwargs),
            TICKER: TickerParquet(**kwargs),
            FUNDING: FundingParquet(**kwargs),
            CANDLES: CandlesParquet(**kwargs),
            OPEN_INTEREST: OpenInterestParquet(**kwargs),
            LIQUIDATIONS: LiquidationsParquet(**kwargs)
        }
    elif backend == 'TTY':
        cbs = {
            L2_BOOK: tty,
            TRADES: tty,
            TICKER: tty,
            FUNDING: tty,
            CANDLES: tty,
            OPEN_INTEREST: tty,
            LIQUIDATIONS: tty
        }
    else:
        raise ValueError('Invalid backend specified')

    # Prune unused callbacks
    remove = [chan for chan in cbs if chan not in channels]
    for r in remove:
        del cbs[r]

    return EXCHANGE_MAP[exchange](candle_intterval=candle_interval, symbols=symbols, channels=channels, config=config, callbacks=cbs)


def main():
    fh = FeedHandler(config = os.environ.get('CONFIG'))
    cfg = load_config()
    fh.add_feed(cfg)
    fh.run()


if __name__ == '__main__':
    main()
