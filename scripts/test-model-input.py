import importlib.util
import pathlib
import subprocess
import sys
import tempfile
import unittest


ROOT = pathlib.Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location('model_input', ROOT / 'model_input.py')
MODEL_INPUT = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODEL_INPUT)


VALID_ROW = '1,42,0.75,4,5,61.2,57,2,3,1250\n'


class ModelInputTests(unittest.TestCase):
    def test_parse_model_row_returns_typed_model_fields(self):
        row = MODEL_INPUT.parse_model_row(VALID_ROW)

        self.assertEqual(
            row,
            MODEL_INPUT.ModelRow(
                carat=0.75,
                color=4,
                clarity=5,
                sym=2,
                pol=3,
                price=1250,
            ),
        )

    def test_rejects_truncated_and_extra_rows(self):
        for row in ('1,42,0.75,4', VALID_ROW.rstrip() + ',extra'):
            with self.subTest(row=row):
                with self.assertRaisesRegex(ValueError, 'expected 10 comma-separated fields'):
                    MODEL_INPUT.parse_model_row(row)

    def test_rejects_non_finite_carat(self):
        for value in ('nan', 'inf', '-inf'):
            with self.subTest(value=value):
                row = VALID_ROW.replace('0.75', value)
                with self.assertRaisesRegex(ValueError, 'carat must be finite and positive'):
                    MODEL_INPUT.parse_model_row(row)

    def test_rejects_non_positive_model_values(self):
        for index, field_name in ((2, 'carat'), (3, 'color'), (4, 'clarity'),
                                  (7, 'symmetry'), (8, 'polish'), (9, 'price')):
            with self.subTest(field=field_name):
                fields = VALID_ROW.rstrip().split(',')
                fields[index] = '0'
                with self.assertRaisesRegex(ValueError, field_name):
                    MODEL_INPUT.parse_model_row(','.join(fields))

    def test_rejects_non_integer_model_categories(self):
        for index, field_name in ((3, 'color'), (4, 'clarity'), (7, 'symmetry'),
                                  (8, 'polish'), (9, 'price')):
            with self.subTest(field=field_name):
                fields = VALID_ROW.rstrip().split(',')
                fields[index] = '1.5'
                with self.assertRaisesRegex(ValueError, '{0} must be an integer'.format(field_name)):
                    MODEL_INPUT.parse_model_row(','.join(fields))

    def test_load_model_rows_reports_path_and_line(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'output.csv'
            path.write_text(VALID_ROW + '1,2,3\n', encoding='utf-8')

            with self.assertRaisesRegex(
                ValueError,
                r'output\.csv:2: expected 10 comma-separated fields, got 3',
            ):
                MODEL_INPUT.load_model_rows(path)

    def test_load_model_rows_rejects_blank_rows(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'output.csv'
            path.write_text(VALID_ROW + '\n', encoding='utf-8')

            with self.assertRaisesRegex(ValueError, r'output\.csv:2: expected 10'):
                MODEL_INPUT.load_model_rows(path)

    def test_load_model_rows_rejects_empty_file(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'output.csv'
            path.write_text('', encoding='utf-8')

            with self.assertRaisesRegex(ValueError, 'model input must contain at least one row'):
                MODEL_INPUT.load_model_rows(path)

    def test_graph_rejects_invalid_input_before_rpy2_import(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'output.csv'
            path.write_text('1,2,3\n', encoding='utf-8')

            result = subprocess.run(
                [sys.executable, str(ROOT / 'graph.py')],
                cwd=directory,
                capture_output=True,
                text=True,
                check=False,
            )

            self.assertNotEqual(result.returncode, 0)
            self.assertIn('output.csv:1: expected 10 comma-separated fields, got 3', result.stderr)
            self.assertNotIn("No module named 'rpy2'", result.stderr)


if __name__ == '__main__':
    unittest.main()
