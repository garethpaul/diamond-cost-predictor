#!/usr/bin/env python3
import contextlib
import importlib.util
import io
import pathlib
import tempfile
import unittest
from urllib.error import URLError
from urllib.parse import parse_qs, urlparse


ROOT_DIR = pathlib.Path(__file__).resolve().parents[1]
SCRAPER_MODULE_PATH = ROOT_DIR / 'psdownload.py'


def load_scraper_module():
    spec = importlib.util.spec_from_file_location('diamond_psdownload', SCRAPER_MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


psdownload = load_scraper_module()


class PriceScopeDownloadTests(unittest.TestCase):
    def assertParseArgsExits(self, args):
        with contextlib.redirect_stderr(io.StringIO()):
            with self.assertRaises(SystemExit):
                psdownload.parse_args(args)

    def test_build_url_encodes_query_arguments(self):
        url = psdownload.build_url('BR', 0.25, 0.255, 3)
        parsed = urlparse(url)
        query = parse_qs(parsed.query, keep_blank_values=True)

        self.assertEqual(parsed.scheme, 'https')
        self.assertEqual(parsed.netloc, 'www.pricescope.com')
        self.assertEqual(query['shape'], ['BR'])
        self.assertEqual(query['size__gte'], ['0.25'])
        self.assertEqual(query['size__lte'], ['0.255'])
        self.assertEqual(query['page'], ['3'])
        self.assertEqual(query['lab'], ['GIA', 'AGS'])
        self.assertEqual(query['color_p'], ['H+'])

    def test_pricescope_endpoint_requires_https(self):
        with self.assertRaises(ValueError):
            psdownload.pricescope_ajax_url('http://www.pricescope.com/results/ajax/')

        with self.assertRaises(ValueError):
            psdownload.pricescope_ajax_url('https://')

    def test_pricescope_endpoint_rejects_embedded_credentials(self):
        with self.assertRaises(ValueError):
            psdownload.pricescope_ajax_url('https://user:secret@example.test/results/ajax/')

    def test_pricescope_endpoint_rejects_query_strings_and_fragments(self):
        with self.assertRaises(ValueError):
            psdownload.pricescope_ajax_url('https://example.test/results/ajax/?debug=true')

        with self.assertRaises(ValueError):
            psdownload.pricescope_ajax_url('https://example.test/results/ajax/#fragment')

    def test_pricescope_endpoint_allows_trailing_question_mark_for_legacy_overrides(self):
        self.assertEqual(
            psdownload.pricescope_ajax_url(' https://example.test/results/ajax/? '),
            'https://example.test/results/ajax/',
        )

    def test_parse_total_falls_back_on_unexpected_markup(self):
        self.assertEqual(psdownload.parse_total('We have 42 <b>diamonds</b>', 500), 42)
        self.assertEqual(psdownload.parse_total('No count here', 17), 17)

    def test_parse_args_exposes_timeout_and_output_defaults(self):
        args = psdownload.parse_args(['0.25', '0.30'])

        self.assertEqual(args.min_carat, 0.25)
        self.assertEqual(args.max_carat, 0.30)
        self.assertEqual(args.output, 'diamonds.txt')
        self.assertEqual(args.timeout, psdownload.DEFAULT_TIMEOUT)

    def test_parse_args_rejects_invalid_carat_ranges(self):
        self.assertParseArgsExits(['0', '0.30'])
        self.assertParseArgsExits(['0.30', '0.25'])

    def test_parse_args_rejects_non_positive_timeout(self):
        self.assertParseArgsExits(['0.25', '0.30', '--timeout', '0'])

    def test_parse_args_rejects_blank_output_path(self):
        self.assertParseArgsExits(['0.25', '0.30', '--output', ''])
        self.assertParseArgsExits(['0.25', '0.30', '--output', '   '])

    def test_collect_diamonds_validates_arguments_before_network(self):
        with self.assertRaises(ValueError):
            psdownload.collect_diamonds(0.25, 0.30, 0)

    def test_write_diamonds_writes_one_record_per_line(self):
        with tempfile.TemporaryDirectory() as directory:
            output = pathlib.Path(directory) / 'diamonds.txt'
            psdownload.write_diamonds(output, ['first', 'second'])

            self.assertEqual(output.read_text(encoding='utf-8'), 'first\nsecond\n')

    def test_read_lines_handles_url_errors(self):
        original_urlopen = psdownload.urlopen

        def failing_urlopen(url, timeout):
            raise URLError('offline')

        psdownload.urlopen = failing_urlopen
        try:
            self.assertEqual(psdownload.read_lines('https://example.test/', 1), [])
        finally:
            psdownload.urlopen = original_urlopen


if __name__ == '__main__':
    unittest.main()
