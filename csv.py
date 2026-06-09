from __future__ import print_function

import ast
import math
import sys
from operator import itemgetter


SHAPES = {
    'BR': 1,
    'PR': 2,
    'EM': 3,
    'OV': 4,
    'MQ': 5,
    'PS': 6,
    'AS': 7,
    'CU': 8,
    'RA': 9,
    'HS': 10,
}

COLORS = {
    'D': 1,
    'E': 2,
    'F': 3,
    'G': 4,
    'H': 5,
    'I': 6,
    'J': 7,
    'K': 8,
    'FC': 100,
    'FIY': 100,
}

CLARITIES = {
    'F': 1,
    'FL': 1,
    'IF': 2,
    'VVS1': 3,
    'VVS2': 4,
    'VS1+': 5,
    'VS1': 5,
    'VS2+': 6,
    'VS2': 6,
    'SI1': 7,
    'SI1+': 7,
    'SI2': 8,
    'SI2+': 8,
    'SI3': 9,
    'I1': 10,
    'I2': 11,
    'I3': 12,
}

QUALITIES = {
    'X': 1,
    'ID': 1,
    'VG': 2,
    'G': 3,
    'F': 4,
    'P': 5,
    'N': 6,
}

REQUIRED_FIELDS = (
    'shape',
    'vendor_id',
    'carat',
    'color',
    'clarity',
    'depth',
    'table',
    'sym',
    'pol',
    'price',
)


def shape(value):
    return lookup(SHAPES, value, 'shape')


def color(value):
    return lookup(COLORS, value, 'color')


def clarity(value):
    return lookup(CLARITIES, value, 'clarity')


def quality(value):
    return lookup(QUALITIES, value, 'quality')


def lookup(mapping, value, field_name):
    try:
        return mapping[value]
    except KeyError:
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))


def require_fields(record):
    missing = [field for field in REQUIRED_FIELDS if field not in record]
    if missing:
        raise ValueError('Diamond record is missing required fields: {0}'.format(', '.join(missing)))


def parse_diamond_line(line):
    try:
        record = ast.literal_eval(line)
    except (SyntaxError, ValueError):
        raise ValueError('Diamond record is not a Python literal dictionary')

    if not isinstance(record, dict):
        raise ValueError('Diamond record must be a dictionary')

    require_fields(record)
    return {
        'shape': shape(record['shape']),
        'vendor_id': positive_int(record['vendor_id'], 'vendor_id'),
        'carat': numeric_text(record['carat'], 'carat'),
        'color': color(record['color']),
        'clarity': clarity(record['clarity']),
        'depth': numeric_text(record['depth'], 'depth'),
        'table': numeric_text(record['table'], 'table'),
        'sym': quality(record['sym']),
        'pol': quality(record['pol']),
        'price': positive_int(record['price'], 'price'),
    }


def numeric_text(value, field_name):
    if isinstance(value, bool):
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))
    try:
        number = float(value)
    except (TypeError, ValueError):
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))
    if not math.isfinite(number) or number <= 0:
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))
    return str(value)


def positive_int(value, field_name):
    if isinstance(value, bool):
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))
    try:
        number = int(value)
    except (TypeError, ValueError):
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))
    if number <= 0:
        raise ValueError('Unsupported {0}: {1!r}'.format(field_name, value))
    return number


def load_records(path):
    records = []
    with open(path, 'r') as handle:
        for line_number, line in enumerate(handle, 1):
            stripped = line.strip()
            if not stripped:
                continue
            try:
                records.append(parse_diamond_line(stripped))
            except ValueError as exc:
                raise ValueError('{0}:{1}: {2}'.format(path, line_number, exc))

    return sorted(records, key=itemgetter('price'))


def format_record(record):
    return ','.join([
        str(record['shape']),
        str(record['vendor_id']),
        record['carat'],
        str(record['color']),
        str(record['clarity']),
        record['depth'],
        record['table'],
        str(record['sym']),
        str(record['pol']),
        str(record['price']),
    ])


def main(argv):
    input_path = argv[1] if len(argv) > 1 else 'diamonds.txt'
    for record in load_records(input_path):
        if record['color'] > 8:
            continue
        print(format_record(record))


if __name__ == '__main__':
    main(sys.argv)
