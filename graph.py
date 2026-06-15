import math
import sys

from model_input import load_model_rows


def parse_prediction_args(argv):
    if len(argv) == 1:
        return None
    if len(argv) != 5:
        raise ValueError('expected either no prediction values or carat color clarity price')

    try:
        carat = float(argv[1])
        color = int(argv[2])
        clarity = int(argv[3])
        price = float(argv[4])
    except ValueError:
        raise ValueError('prediction values must be numeric')

    if not math.isfinite(carat) or carat <= 0:
        raise ValueError('prediction carat must be finite and positive')
    if color <= 0:
        raise ValueError('prediction color must be a positive integer')
    if clarity <= 0:
        raise ValueError('prediction clarity must be a positive integer')
    if not math.isfinite(price) or price <= 0:
        raise ValueError('prediction price must be finite and positive')

    return carat, color, clarity, price


def main(argv):
    prediction_args = parse_prediction_args(argv)

    print("Opening File")
    rows = load_model_rows("output.csv")
    print("Finished importing the file")

    import rpy2
    from rpy2.robjects.packages import importr
    import rpy2.robjects as ro

    r_base = importr('base')
    stats = importr('stats')
    graphics = importr('graphics')

    carat = ro.FloatVector([row.carat for row in rows])
    color = ro.IntVector([row.color for row in rows])
    clarity = ro.IntVector([row.clarity for row in rows])
    sym = ro.IntVector([row.sym for row in rows])
    pol = ro.IntVector([row.pol for row in rows])
    price = ro.FloatVector([row.price for row in rows])
    ro.globalenv["carat"] = carat
    ro.globalenv["color"] = color
    ro.globalenv["clarity"] = clarity
    ro.globalenv["sym"] = sym
    ro.globalenv["pol"] = pol
    ro.globalenv["price"] = price

    print("Building Model")
    res = stats.lm("price ~ carat + color + clarity")
    print("Finished building the model")
    print(res)
    print("Building prediction")
    pred = stats.predict(res)
    print("Finished building prediction")
    summary = r_base.summary(res)
    print("Results from prediction")
    print(summary)
    ars = "Adjusted R Squared = " + str(round(summary[8][0], 2))
    print("Finding Coefficients")
    coef = summary.rx2('coefficients')[0:6]
    formula = (
        "Price = " + str(int(round(coef[0]))) + " + " +
        str(int(round(coef[1]))) + "*Carats + " +
        str(int(round(coef[2]))) + "*Color + " +
        str(int(round(coef[3]))) + "*Clarity"
    )
    print(formula)

    print("Comparing Actual to Predicted Price Fit")
    ro.globalenv["pred"] = pred
    comp = stats.lm("pred ~ price")

    print("Writing graph to pdf")
    ro.r.pdf('prediction.pdf')
    ro.r.plot(
        [x for x in pred],
        [y for y in price],
        main="Actual vs Predicted Price",
        xlab="Predicted Price",
        ylab="Actual Price",
        cex=0.5,
    )
    ro.r.abline(comp, col="green", lty="dotted", lwd=3)

    if prediction_args is not None:
        ycar, ycol, ycla, ypri = prediction_args
        ypred = coef[0] + coef[1] * ycar + coef[2] * ycol + coef[3] * ycla
        sdiam = (
            "Your Diamond: " + str(ycar) + " Carats, " + str(ycol) +
            " Color, " + str(ycla) + " Clarity, $" + str(ypri)
        )
        spred = "Predicted Price = $" + str(int(round(ypred)))
        sdiff = "Difference = $" + str(int(ypred - ypri))
        ssavings = "Savings = " + str(int(round(100 * ((ypred - ypri) / ypri)))) + "%"
        ro.r.points(ypred, ypri, col="red", pch='x', cex=1)
        ro.r.legend(
            "bottomright",
            legend=[sdiam, spred, sdiff, ssavings],
            bg="white",
            cex=0.5,
        )

    ro.r.legend(
        "top",
        legend=[formula, ars, "Sample Size = " + str(len(price)) + " Diamonds"],
        bg="white",
    )
    ro.r('dev.off()')
    print("Finished!")


if __name__ == '__main__':
    main(sys.argv)
