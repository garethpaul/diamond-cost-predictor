# Diamond Cost Predictor

Legacy Python 2 scripts for downloading diamond listing data and building a
simple price model.

## Download Endpoint

`psdownload.py` uses the HTTPS Pricescope AJAX endpoint by default:

```sh
python psdownload.py 0.5 1.0
```

To point the downloader at a different endpoint, set
`PRICESCOPE_AJAX_URL`. The script rejects non-HTTPS values:

```sh
PRICESCOPE_AJAX_URL=https://www.pricescope.com/results/ajax/ python psdownload.py 0.5 1.0
```

## Verify

Run the source-level baseline check:

```sh
scripts/check-baseline.sh
```
