COLOR_RANGE = (1, 6)
CLARITY_RANGE = (1, 8)


def supports_model_categories(color, clarity):
    return (
        COLOR_RANGE[0] <= color <= COLOR_RANGE[1]
        and CLARITY_RANGE[0] <= clarity <= CLARITY_RANGE[1]
    )
