#!/usr/bin/env python3
import contextlib
import importlib.util
import io
import pathlib
import sys
import tempfile
import unittest


ROOT_DIR = pathlib.Path(__file__).resolve().parents[1]
CSV_MODULE_PATH = ROOT_DIR / 'csv.py'
MODEL_INPUT_MODULE_PATH = ROOT_DIR / 'model_input.py'


def load_module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


sys.path.insert(0, str(ROOT_DIR))
try:
    diamond_csv = load_module('diamond_csv', CSV_MODULE_PATH)
    model_input = load_module('diamond_model_input', MODEL_INPUT_MODULE_PATH)
finally:
    sys.path.pop(0)


def source_record(color='I', clarity='SI2', price='225'):
    return {
        'shape': 'PR',
        'vendor_id': '42',
        'carat': '0.20',
        'color': color,
        'clarity': clarity,
        'depth': '71.9',
        'table': '74',
        'sym': 'VG',
        'pol': 'ID',
        'price': price,
    }


def convert_records(directory, records):
    source_path = pathlib.Path(directory) / 'diamonds.txt'
    output_path = pathlib.Path(directory) / 'output.csv'
    source_path.write_text(
        ''.join('{0}\n'.format(record) for record in records),
        encoding='utf-8',
    )

    output = io.StringIO()
    with contextlib.redirect_stdout(output):
        diamond_csv.main(['csv.py', str(source_path)])
    output_path.write_text(output.getvalue(), encoding='utf-8')
    return output_path


class SafeParsingTests(unittest.TestCase):
    def test_conversion_emits_supported_model_boundary(self):
        with tempfile.TemporaryDirectory() as directory:
            output_path = convert_records(directory, [source_record()])

            rows = model_input.load_model_rows(output_path)

            self.assertEqual([(row.color, row.clarity) for row in rows], [(6, 8)])

    def test_conversion_skips_each_category_outside_model_domain(self):
        for field, value in (
            ('color', 'J'),
            ('color', 'K'),
            ('clarity', 'SI3'),
            ('clarity', 'I1'),
        ):
            with self.subTest(field=field, value=value):
                with tempfile.TemporaryDirectory() as directory:
                    excluded = source_record(price='226')
                    excluded[field] = value
                    output_path = convert_records(directory, [source_record(), excluded])

                    rows = model_input.load_model_rows(output_path)

                    self.assertEqual(
                        [(row.color, row.clarity) for row in rows],
                        [(6, 8)],
                    )

    def test_every_emitted_category_combination_is_loadable(self):
        records = []
        price = 100
        colors = ('D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'FC', 'FIY')
        clarities = (
            'F', 'FL', 'IF', 'VVS1', 'VVS2', 'VS1+', 'VS1', 'VS2+',
            'VS2', 'SI1', 'SI1+', 'SI2', 'SI2+', 'SI3', 'I1', 'I2', 'I3',
        )
        for color in colors:
            for clarity in clarities:
                price += 1
                records.append(source_record(color, clarity, str(price)))

        with tempfile.TemporaryDirectory() as directory:
            output_path = convert_records(directory, records)

            rows = model_input.load_model_rows(output_path)

            self.assertEqual(len(rows), 78)

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

    def test_rejects_non_finite_numeric_fields(self):
        line = (
            "{'shape': 'PR', 'vendor_id': '42', 'carat': 'nan', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '225'}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)

    def test_rejects_boolean_numeric_fields(self):
        line = (
            "{'shape': 'PR', 'vendor_id': '42', 'carat': True, "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '225'}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)

    def test_rejects_boolean_integer_fields(self):
        line = (
            "{'shape': 'PR', 'vendor_id': True, 'carat': '0.28', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '225'}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)

    def test_rejects_fractional_integer_fields(self):
        record = {
            'shape': 'PR',
            'vendor_id': 42,
            'carat': '0.28',
            'color': 'G',
            'clarity': 'SI2',
            'depth': '71.9',
            'table': '74',
            'sym': 'VG',
            'pol': 'ID',
            'price': 225,
        }

        for field_name in ('vendor_id', 'price'):
            with self.subTest(field_name=field_name):
                invalid_record = dict(record)
                invalid_record[field_name] = 42.5
                with self.assertRaises(ValueError):
                    diamond_csv.parse_diamond_line(repr(invalid_record))

    def test_rejects_non_finite_integer_fields_as_value_errors(self):
        line = (
            "{'shape': 'PR', 'vendor_id': '42', 'carat': '0.28', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': 1e309}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)

    def test_accepts_integral_float_integer_fields(self):
        line = (
            "{'shape': 'PR', 'vendor_id': 42.0, 'carat': '0.28', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': 225.0}"
        )

        record = diamond_csv.parse_diamond_line(line)

        self.assertEqual(record['vendor_id'], 42)
        self.assertEqual(record['price'], 225)

    def test_rejects_non_positive_price(self):
        line = (
            "{'shape': 'PR', 'vendor_id': '42', 'carat': '0.28', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '0'}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)

    def test_rejects_non_positive_vendor_id(self):
        line = (
            "{'shape': 'PR', 'vendor_id': '0', 'carat': '0.28', "
            "'color': 'G', 'clarity': 'SI2', 'depth': '71.9', "
            "'table': '74', 'sym': 'VG', 'pol': 'ID', 'price': '225'}"
        )

        with self.assertRaises(ValueError):
            diamond_csv.parse_diamond_line(line)


if __name__ == '__main__':
    unittest.main()
