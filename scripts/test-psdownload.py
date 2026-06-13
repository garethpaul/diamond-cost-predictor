#!/usr/bin/env python3
import contextlib
import importlib.util
import io
import pathlib
import tempfile
import unittest
from unittest import mock
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

    def test_parse_args_rejects_excessive_carat_span(self):
        self.assertParseArgsExits(['0.25', '0.751'])

        args = psdownload.parse_args(['0.25', '0.75'])
        self.assertEqual(args.max_carat - args.min_carat, psdownload.MAX_CARAT_SPAN)

    def test_parse_args_rejects_non_finite_carat_ranges(self):
        self.assertParseArgsExits(['nan', '0.30'])
        self.assertParseArgsExits(['0.25', 'inf'])

    def test_parse_args_rejects_non_positive_timeout(self):
        self.assertParseArgsExits(['0.25', '0.30', '--timeout', '0'])

    def test_parse_args_rejects_non_finite_timeout(self):
        self.assertParseArgsExits(['0.25', '0.30', '--timeout', 'nan'])

    def test_parse_args_rejects_blank_output_path(self):
        self.assertParseArgsExits(['0.25', '0.30', '--output', ''])
        self.assertParseArgsExits(['0.25', '0.30', '--output', '   '])

    def test_collect_diamonds_validates_arguments_before_network(self):
        original_read_lines = psdownload.read_lines
        psdownload.read_lines = lambda url, timeout: self.fail('network reached')
        try:
            with self.assertRaises(ValueError):
                psdownload.collect_diamonds(0.25, 0.30, 0)
            with self.assertRaises(ValueError):
                psdownload.collect_diamonds(float('nan'), 0.30, 1)
            with self.assertRaises(ValueError):
                psdownload.collect_diamonds(0.25, 0.751, 1)
        finally:
            psdownload.read_lines = original_read_lines

    def test_drange_rejects_invalid_or_non_advancing_steps(self):
        with self.assertRaises(ValueError):
            list(psdownload.drange(0.25, 0.30, 0))
        with self.assertRaises(ValueError):
            list(psdownload.drange(0.25, 0.30, float('inf')))
        with self.assertRaises(ValueError):
            list(psdownload.drange(1e20, 1e20 + 1e6, psdownload.DEFAULT_STEP))

    def test_write_diamonds_atomically_replaces_output_in_destination_directory(self):
        with tempfile.TemporaryDirectory() as directory:
            output = pathlib.Path(directory) / 'diamonds.txt'
            output.write_text('previous\n', encoding='utf-8')
            staged_directories = []
            original_mkstemp = psdownload.tempfile.mkstemp

            def recording_mkstemp(*args, **kwargs):
                staged_directories.append(pathlib.Path(kwargs['dir']))
                return original_mkstemp(*args, **kwargs)

            with mock.patch.object(psdownload.tempfile, 'mkstemp', recording_mkstemp):
                psdownload.write_diamonds(output, ['first', 'second'])

            self.assertEqual(output.read_text(encoding='utf-8'), 'first\nsecond\n')
            self.assertEqual(staged_directories, [output.parent.resolve()])
            self.assertEqual(list(output.parent.iterdir()), [output])

    def test_write_diamonds_preserves_output_when_record_conversion_fails(self):
        class BrokenRecord:
            def __str__(self):
                raise RuntimeError('cannot serialize')

        with tempfile.TemporaryDirectory() as directory:
            output = pathlib.Path(directory) / 'diamonds.txt'
            output.write_text('previous\n', encoding='utf-8')

            with self.assertRaisesRegex(RuntimeError, 'cannot serialize'):
                psdownload.write_diamonds(output, ['first', BrokenRecord()])

            self.assertEqual(output.read_text(encoding='utf-8'), 'previous\n')
            self.assertEqual(list(output.parent.iterdir()), [output])

    def test_write_diamonds_preserves_output_when_atomic_replace_fails(self):
        with tempfile.TemporaryDirectory() as directory:
            output = pathlib.Path(directory) / 'diamonds.txt'
            output.write_text('previous\n', encoding='utf-8')

            with mock.patch.object(psdownload.os, 'replace', side_effect=OSError('replace failed')):
                with self.assertRaisesRegex(OSError, 'replace failed'):
                    psdownload.write_diamonds(output, ['replacement'])

            self.assertEqual(output.read_text(encoding='utf-8'), 'previous\n')
            self.assertEqual(list(output.parent.iterdir()), [output])

    def test_write_diamonds_rejects_blank_output_path(self):
        with self.assertRaises(ValueError):
            psdownload.write_diamonds('   ', [])

    def test_read_lines_handles_url_errors(self):
        original_urlopen = psdownload.urlopen

        def failing_urlopen(url, timeout):
            raise URLError('offline')

        psdownload.urlopen = failing_urlopen
        try:
            self.assertEqual(psdownload.read_lines('https://example.test/', 1), [])
        finally:
            psdownload.urlopen = original_urlopen

    def test_read_lines_accepts_bounded_utf8_response(self):
        original_urlopen = psdownload.urlopen

        class FakeResponse:
            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc_value, traceback):
                return False

            def read(self, limit):
                self.limit = limit
                return 'first\ncaf\u00e9 \u6771\u4eac\n'.encode('utf-8')

            def geturl(self):
                return 'https://example.test/redirected?page=1'

        response = FakeResponse()
        psdownload.urlopen = lambda url, timeout: response
        try:
            self.assertEqual(
                psdownload.read_lines('https://example.test/', 1),
                ['first', 'caf\u00e9 \u6771\u4eac'],
            )
            self.assertEqual(response.limit, psdownload.MAX_RESPONSE_BYTES + 1)
        finally:
            psdownload.urlopen = original_urlopen

    def test_read_lines_rejects_malformed_utf8_response(self):
        original_urlopen = psdownload.urlopen

        class FakeResponse:
            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc_value, traceback):
                return False

            def read(self, limit):
                return b'valid-prefix\xffprivate-tail'

            def geturl(self):
                return 'https://example.test/'

        psdownload.urlopen = lambda url, timeout: FakeResponse()
        try:
            output = io.StringIO()
            with contextlib.redirect_stdout(output):
                self.assertEqual(psdownload.read_lines('https://example.test/', 1), [])
            self.assertEqual(
                output.getvalue(),
                '   Failed to download page: response was not valid UTF-8\n',
            )
            self.assertNotIn('private-tail', output.getvalue())
        finally:
            psdownload.urlopen = original_urlopen

    def test_read_lines_rejects_oversized_response(self):
        original_urlopen = psdownload.urlopen

        class FakeResponse:
            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc_value, traceback):
                return False

            def read(self, limit):
                return b'x' * limit

            def geturl(self):
                return 'https://example.test/'

        psdownload.urlopen = lambda url, timeout: FakeResponse()
        try:
            with contextlib.redirect_stdout(io.StringIO()):
                self.assertEqual(psdownload.read_lines('https://example.test/', 1), [])
        finally:
            psdownload.urlopen = original_urlopen

    def test_read_lines_rejects_untrusted_response_origins_before_body_read(self):
        original_urlopen = psdownload.urlopen

        class FakeResponse:
            def __init__(self, final_url):
                self.final_url = final_url
                self.read_calls = 0

            def __enter__(self):
                return self

            def __exit__(self, exc_type, exc_value, traceback):
                return False

            def geturl(self):
                return self.final_url

            def read(self, limit):
                self.read_calls += 1
                return b'private response body'

        hostile_urls = [
            'http://example.test/redirected',
            'https://other.test/redirected',
            'https://example.test:444/redirected',
            'https://user:secret@example.test/redirected',
            'https://example.test:invalid/redirected',
        ]
        try:
            for final_url in hostile_urls:
                response = FakeResponse(final_url)
                psdownload.urlopen = lambda url, timeout, response=response: response
                output = io.StringIO()
                with contextlib.redirect_stdout(output):
                    self.assertEqual(psdownload.read_lines('https://example.test/source', 1), [])
                self.assertEqual(response.read_calls, 0)
                self.assertEqual(
                    output.getvalue(),
                    '   Failed to download page: response origin was not trusted\n',
                )
                self.assertNotIn(final_url, output.getvalue())
        finally:
            psdownload.urlopen = original_urlopen

    def test_response_origin_normalizes_default_https_port(self):
        self.assertEqual(
            psdownload.response_origin('https://EXAMPLE.test:443/path'),
            ('example.test', 443),
        )
        psdownload.validate_response_origin(
            'https://example.test/source',
            'https://example.test:443/redirected?next=1',
        )


if __name__ == '__main__':
    unittest.main()
