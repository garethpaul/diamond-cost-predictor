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
sys.path.insert(0, str(ROOT))
try:
    GRAPH_SPEC = importlib.util.spec_from_file_location('graph', ROOT / 'graph.py')
    GRAPH = importlib.util.module_from_spec(GRAPH_SPEC)
    GRAPH_SPEC.loader.exec_module(GRAPH)
finally:
    sys.path.pop(0)


VALID_ROW = '1,42,0.75,4,5,61.2,57,2,3,1250\n'


class ModelInputTests(unittest.TestCase):
    def test_graph_prediction_args_accept_none_or_four_valid_values(self):
        self.assertIsNone(GRAPH.parse_prediction_args(['graph.py']))
        for color, clarity in ((1, 1), (4, 5), (6, 8)):
            with self.subTest(color=color, clarity=clarity):
                self.assertEqual(
                    GRAPH.parse_prediction_args([
                        'graph.py', '0.75', str(color), str(clarity), '1250'
                    ]),
                    (0.75, color, clarity, 1250.0),
                )

    def test_graph_prediction_args_reject_partial_and_extra_values(self):
        for argv in (
            ['graph.py', '0.75'],
            ['graph.py', '0.75', '4', '5'],
            ['graph.py', '0.75', '4', '5', '1250', 'extra'],
        ):
            with self.subTest(argv=argv):
                with self.assertRaisesRegex(ValueError, 'expected either no prediction values'):
                    GRAPH.parse_prediction_args(argv)

    def test_graph_prediction_args_reject_invalid_numeric_values(self):
        cases = (
            (['graph.py', 'nan', '4', '5', '1250'], 'carat must be finite and positive'),
            (['graph.py', '0', '4', '5', '1250'], 'carat must be finite and positive'),
            (['graph.py', '0.75', '0', '5', '1250'], 'color must be between 1 and 6'),
            (['graph.py', '0.75', '7', '5', '1250'], 'color must be between 1 and 6'),
            (['graph.py', '0.75', '4.5', '5', '1250'], 'values must be numeric'),
            (['graph.py', '0.75', '4', '0', '1250'], 'clarity must be between 1 and 8'),
            (['graph.py', '0.75', '4', '9', '1250'], 'clarity must be between 1 and 8'),
            (['graph.py', '0.75', '4', '5', 'inf'], 'price must be finite and positive'),
            (['graph.py', '0.75', '4', '5', '0'], 'price must be finite and positive'),
        )
        for argv, message in cases:
            with self.subTest(argv=argv):
                with self.assertRaisesRegex(ValueError, message):
                    GRAPH.parse_prediction_args(argv)

    def test_graph_rejects_invalid_prediction_args_before_input_or_rpy2(self):
        cases = (
            (['0.75', '7', '5', '1250'], 'prediction color must be between 1 and 6'),
            (['0.75', '4', '5', '0'], 'prediction price must be finite and positive'),
        )
        for prediction_args, message in cases:
            with self.subTest(prediction_args=prediction_args):
                with tempfile.TemporaryDirectory() as directory:
                    result = subprocess.run(
                        [sys.executable, str(ROOT / 'graph.py')] + prediction_args,
                        cwd=directory,
                        capture_output=True,
                        text=True,
                        check=False,
                    )

                self.assertNotEqual(result.returncode, 0)
                self.assertIn(message, result.stderr)
                self.assertNotIn('Opening File', result.stdout)
                self.assertNotIn('output.csv', result.stderr)
                self.assertNotIn("No module named 'rpy2'", result.stderr)

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

    def test_model_rows_accept_category_boundaries(self):
        for color, clarity in ((1, 1), (6, 8)):
            with self.subTest(color=color, clarity=clarity):
                fields = VALID_ROW.rstrip().split(',')
                fields[3] = str(color)
                fields[4] = str(clarity)

                row = MODEL_INPUT.parse_model_row(','.join(fields))

                self.assertEqual((row.color, row.clarity), (color, clarity))

    def test_rejects_out_of_range_model_categories(self):
        for index, value, message in (
            (3, '7', 'color must be between 1 and 6'),
            (4, '9', 'clarity must be between 1 and 8'),
        ):
            with self.subTest(index=index, value=value):
                fields = VALID_ROW.rstrip().split(',')
                fields[index] = value
                with self.assertRaisesRegex(ValueError, message):
                    MODEL_INPUT.parse_model_row(','.join(fields))

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

    def test_load_model_rows_reports_out_of_range_category_line(self):
        with tempfile.TemporaryDirectory() as directory:
            path = pathlib.Path(directory) / 'output.csv'
            invalid_row = VALID_ROW.replace(',4,5,', ',7,5,')
            path.write_text(VALID_ROW + invalid_row, encoding='utf-8')

            with self.assertRaisesRegex(
                ValueError,
                r'output\.csv:2: color must be between 1 and 6',
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
