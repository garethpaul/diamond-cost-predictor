#!/usr/bin/env python3
import argparse
import os
import socket
from urllib.error import URLError
from urllib.parse import urlencode
from urllib.request import urlopen


DIAMOND_TYPES = ["BR", "PR", "EM", "OV", "MQ", "PS", "AS", "CU", "RA", "HS"]
DEFAULT_PRICESCOPE_AJAX_URL = "https://www.pricescope.com/results/ajax/"
DEFAULT_STEP = 0.005
DEFAULT_TIMEOUT = 15


def drange(start, stop, step):
    current = start
    while current < stop:
        yield current
        current += step


def pricescope_ajax_url(endpoint=None):
    endpoint = endpoint or os.environ.get("PRICESCOPE_AJAX_URL", DEFAULT_PRICESCOPE_AJAX_URL)
    if not endpoint.lower().startswith("https://"):
        raise ValueError("PriceScope endpoint must use HTTPS")
    return endpoint.rstrip("?")


def build_url(shape, lower_size, upper_size, page, endpoint=None):
    query = [
        ("vendor__latitude__gte", "-180"),
        ("type_color", "1"),
        ("vendor__region__contains", ""),
        ("clarity__lte", "27"),
        ("vendor__longitude__gte", "-180"),
        ("shape", shape),
        ("price__lte", "999999"),
        ("city", "Richmond"),
        ("hca_index__lte", "10"),
        ("search_key", "sk_session_3068"),
        ("size__lte", str(upper_size)),
        ("l_country", "us"),
        ("price__gte", "100"),
        ("vln_l_ct", "180"),
        ("latitude", "37.5522003174"),
        ("size__gte", str(lower_size)),
        ("vlt_g_ct", "-180"),
        ("clarity__gte", "1"),
        ("color_m", "G-"),
        ("l_region", "VA"),
        ("search", ""),
        ("lab", "GIA"),
        ("lab", "AGS"),
        ("type_search", "1"),
        ("vendor__latitude__lte", "180"),
        ("color_p", "H+"),
        ("color__lte", "I"),
        ("vendor__country__contains", ""),
        ("f", "3"),
        ("hca_index__gte", "0"),
        ("region", "VA"),
        ("vendor__longitude__lte", "180"),
        ("longitude", "-77.4581985474"),
        ("country", "us"),
        ("vln_g_ct", "-180"),
        ("color__gte", "D"),
        ("vlt_l_ct", "180"),
        ("sort", "size"),
        ("page", str(page)),
    ]
    return pricescope_ajax_url(endpoint) + "?" + urlencode(query)


def read_lines(url, timeout):
    try:
        with urlopen(url, timeout=timeout) as response:
            return response.read().decode("utf-8", "replace").splitlines()
    except (TimeoutError, socket.timeout, URLError) as exc:
        print("   Failed to download page: {0}".format(exc))
        return []


def parse_total(line, fallback):
    try:
        return int(line.split("have ")[1].split("<b>")[0].strip())
    except (IndexError, ValueError):
        return fallback


def collect_diamonds(min_carat, max_carat, timeout, endpoint=None):
    diamonds = []
    found_total = 0
    upper_bound = max_carat - DEFAULT_STEP

    print("Finding all diamonds carat sized {0} to {1}".format(min_carat, max_carat))

    for diamond_type in DIAMOND_TYPES:
        print("Finding diamonds of shape {0}".format(diamond_type))

        for lower_size in drange(min_carat, upper_bound + DEFAULT_STEP * 0.01, DEFAULT_STEP * 2):
            total_for_query = 500
            upper_size = lower_size + DEFAULT_STEP
            print("Downloading diamonds carat sized {0} to {1}".format(lower_size, upper_size))

            for page in range(1, 21):
                if 25 * (page - 1) > total_for_query:
                    print("   Skipping page {0}/20".format(page))
                    continue

                print("   Downloading page {0}/20".format(page))
                lines = read_lines(build_url(diamond_type, lower_size, upper_size, page, endpoint), timeout)
                found_data_marker = False

                for line in lines:
                    if "diamond-data" in line:
                        found_data_marker = True
                    elif found_data_marker:
                        found_data_marker = False
                        diamonds.append(line.strip())
                    elif "We have " in line:
                        total_for_query = parse_total(line, total_for_query)

            found_total += total_for_query

    return diamonds, found_total


def write_diamonds(path, diamonds):
    with open(path, "w", encoding="utf-8") as diamond_file:
        for diamond in diamonds:
            diamond_file.write(str(diamond) + "\n")


def parse_args(argv=None):
    parser = argparse.ArgumentParser(description="Download PriceScope diamond listings.")
    parser.add_argument("min_carat", type=float)
    parser.add_argument("max_carat", type=float)
    parser.add_argument("--output", default="diamonds.txt")
    parser.add_argument("--timeout", type=float, default=DEFAULT_TIMEOUT)
    parser.add_argument("--endpoint", default=None, help="HTTPS PriceScope AJAX endpoint override")
    return parser.parse_args(argv)


def main(argv=None):
    args = parse_args(argv)
    diamonds, found_total = collect_diamonds(
        args.min_carat,
        args.max_carat,
        args.timeout,
        endpoint=args.endpoint,
    )
    print(
        "Found a total of {0} diamonds out of {1} diamonds reported".format(
            len(diamonds), found_total
        )
    )
    print("       ")
    write_diamonds(args.output, diamonds)


if __name__ == "__main__":
    main()
