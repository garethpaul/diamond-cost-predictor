import sys

from model_input import load_model_rows


def main(argv):
    if len(argv) > 4:
        ycar = float(argv[1])
        ycol = int(argv[2])
        ycla = int(argv[3])
        ypri = float(argv[4])

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

    if len(argv) > 4:
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
