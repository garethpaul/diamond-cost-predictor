#!/usr/bin/env python3
import importlib.util
import pathlib
import unittest


ROOT_DIR = pathlib.Path(__file__).resolve().parents[1]
CSV_MODULE_PATH = ROOT_DIR / 'csv.py'


def load_csv_module():
    spec = importlib.util.spec_from_file_location('diamond_csv', CSV_MODULE_PATH)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


diamond_csv = load_csv_module()


class SafeParsingTests(unittest.TestCase):
    def test_parses_and_formats_supported_record(self):
        line = (
            "{'shape': 'PR', 'vendor_id': '42', 'carat': '0.20', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '225'}"
        )

        record = diamond_csv.parse_diamond_line(line)

        self.assertEqual(record['shape'], 2)
        self.assertEqual(record['vendor_id'], 42)
        self.assertEqual(record['color'], 4)
        self.assertEqual(record['clarity'], 8)
        self.assertEqual(record['sym'], 2)
        self.assertEqual(record['pol'], 1)
        self.assertEqual(
            diamond_csv.format_record(record),
            '2,42,0.20,4,8,71.9,74,2,1,225',
        )

    def test_rejects_non_literal_input_instead_of_executing_it(self):
        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line("__import__('os').system('echo unsafe')")

    def test_rejects_missing_fields(self):
        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line("{'shape': 'PR'}")

    def test_rejects_unknown_codes(self):
        line = (
            "{'shape': 'BAD', 'vendor_id': '42', 'carat': '0.28', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '225'}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)


if __name__ == '__main__':
    unittest.main()
