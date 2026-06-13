import math
from collections import namedtuple


EXPECTED_FIELD_COUNT = 10
ModelRow = namedtuple('ModelRow', 'carat color clarity sym pol price')


def positive_float(value, field_name):
    try:
        number = float(value)
    except ValueError:
        raise ValueError('{0} must be a number'.format(field_name))
    if not math.isfinite(number) or number <= 0:
        raise ValueError('{0} must be finite and positive'.format(field_name))
    return number


def positive_int(value, field_name):
    try:
        number = int(value)
    except ValueError:
        raise ValueError('{0} must be an integer'.format(field_name))
    if number <= 0:
        raise ValueError('{0} must be positive'.format(field_name))
    return number


def parse_model_row(line):
    fields = line.rstrip('\r\n').split(',')
    if len(fields) != EXPECTED_FIELD_COUNT:
        raise ValueError(
            'expected {0} comma-separated fields, got {1}'.format(
                EXPECTED_FIELD_COUNT, len(fields)
            )
        )

    return ModelRow(
        carat=positive_float(fields[2], 'carat'),
        color=positive_int(fields[3], 'color'),
        clarity=positive_int(fields[4], 'clarity'),
        sym=positive_int(fields[7], 'symmetry'),
        pol=positive_int(fields[8], 'polish'),
        price=positive_int(fields[9], 'price'),
    )


def load_model_rows(path):
    rows = []
    with open(path, 'r', encoding='utf-8') as handle:
        for line_number, line in enumerate(handle, 1):
            try:
                rows.append(parse_model_row(line))
            except ValueError as exc:
                raise ValueError('{0}:{1}: {2}'.format(path, line_number, exc))

    if not rows:
        raise ValueError('{0}: model input must contain at least one row'.format(path))
    return rows
