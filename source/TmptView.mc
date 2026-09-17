using Toybox.Graphics;
using Toybox.WatchUi;

class TmptView extends WatchUi.View {
    var model;
    var page = 0;

    function initialize(aModel) {
        View.initialize();
        model = aModel;
    }

    function nextPage() {
        page = (page + 1) % 2;
        WatchUi.requestUpdate();
    }

    function previousPage() {
        page -= 1;
        if (page < 0) { page = 1; }
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var width = dc.getWidth();
        var height = dc.getHeight();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        if (!model.started) {
            drawStartPage(dc, width, height);
            return;
        }

        if (page == 0) {
            drawTimePage(dc, width, height);
        } else {
            drawStatsPage(dc, width, height);
        }
    }

    function drawStartPage(dc, width, height) {
        drawCentered(dc, percent(height, 18), Graphics.FONT_SMALL, "TMPT DAG", Graphics.COLOR_GREEN);
        drawCentered(dc, percent(height, 34), Graphics.FONT_NUMBER_MILD, "10:00:00", Graphics.COLOR_WHITE);
        drawCentered(dc, percent(height, 57), Graphics.FONT_XTINY, "DAGLIMIET", Graphics.COLOR_LT_GRAY);
        drawCentered(dc, percent(height, 73), Graphics.FONT_XTINY, "DRUK START", Graphics.COLOR_WHITE);
    }

    function drawTimePage(dc, width, height) {
        drawCentered(dc, percent(height, 5), Graphics.FONT_SMALL, model.finished ? "TMPT RESULTAAT" : "TMPT DAG", Graphics.COLOR_LT_GRAY);

        var remaining = model.remainingSeconds();
        var color = Graphics.COLOR_GREEN;
        if (remaining <= 3600) { color = Graphics.COLOR_YELLOW; }
        if (remaining <= 900) { color = Graphics.COLOR_RED; }

        drawCentered(dc, percent(height, 17), Graphics.FONT_XTINY, remaining >= 0 ? "RESTEREND" : "OVER TIJD", color);
        drawCentered(dc, percent(height, 25), Graphics.FONT_NUMBER_MILD, formatSignedTime(remaining), color);

        var firstRow = percent(height, 49);
        var rowGap = percent(height, 8);
        drawPair(dc, width, firstRow, "TIJD", formatTime(model.elapsedSeconds()), Graphics.COLOR_WHITE);
        drawPair(dc, width, firstRow + rowGap, "STRAF", "+" + formatShort(model.penaltySeconds), Graphics.COLOR_RED);
        drawPair(dc, width, firstRow + (rowGap * 2), "CORRECTIE", "-" + formatShort(model.waitCorrectionSeconds), Graphics.COLOR_BLUE);
        drawPair(dc, width, firstRow + (rowGap * 3), "RONDES", model.penaltyRounds.toString(), model.penaltyRounds > 0 ? Graphics.COLOR_YELLOW : Graphics.COLOR_WHITE);

        drawCentered(dc, percent(height, 88), Graphics.FONT_XTINY, "1 / 2", Graphics.COLOR_DK_GRAY);
    }

    function drawStatsPage(dc, width, height) {
        drawCentered(dc, percent(height, 6), Graphics.FONT_SMALL, "LIVE GEGEVENS", Graphics.COLOR_LT_GRAY);

        var left = percent(width, 31);
        var right = percent(width, 69);
        var topLabel = percent(height, 23);
        var topValue = percent(height, 31);
        var topUnit = percent(height, 43);
        var bottomLabel = percent(height, 55);
        var bottomValue = percent(height, 63);
        var bottomUnit = percent(height, 75);

        drawMetric(dc, left, topLabel, topValue, topUnit, "HARTSLAG", model.heartRate > 0 ? model.heartRate.toString() : "--", "BPM", Graphics.COLOR_RED);
        drawMetric(dc, right, topLabel, topValue, topUnit, "SNELHEID", model.speedKmh.format("%.1f"), "KM/U", Graphics.COLOR_GREEN);
        drawMetric(dc, left, bottomLabel, bottomValue, bottomUnit, "AFSTAND", model.distanceKm.format("%.2f"), "KM", Graphics.COLOR_WHITE);
        drawMetric(dc, right, bottomLabel, bottomValue, bottomUnit, "GEMIDDELD", model.averageSpeedKmh.format("%.1f"), "KM/U", Graphics.COLOR_BLUE);

        drawCentered(dc, percent(height, 88), Graphics.FONT_XTINY, "2 / 2", Graphics.COLOR_DK_GRAY);
    }

    function drawMetric(dc, x, labelY, valueY, unitY, label, value, unit, color) {
        drawAt(dc, x, labelY, Graphics.FONT_XTINY, label, Graphics.COLOR_LT_GRAY);
        drawAt(dc, x, valueY, Graphics.FONT_SMALL, value, color);
        drawAt(dc, x, unitY, Graphics.FONT_XTINY, unit, Graphics.COLOR_DK_GRAY);
    }

    function drawPair(dc, width, y, label, value, color) {
        var margin = percent(width, 18);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(margin, y, Graphics.FONT_XTINY, label, Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(width - margin, y, Graphics.FONT_XTINY, value, Graphics.TEXT_JUSTIFY_RIGHT);
    }

    function drawCentered(dc, y, font, text, color) {
        drawAt(dc, dc.getWidth() / 2, y, font, text, color);
    }

    function drawAt(dc, x, y, font, text, color) {
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y, font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    function percent(value, part) {
        return (value * part) / 100;
    }

    function formatTime(seconds) {
        var value = seconds.toNumber();
        var hours = value / 3600;
        var minutes = (value % 3600) / 60;
        var secs = value % 60;
        return hours.format("%02d") + ":" + minutes.format("%02d") + ":" + secs.format("%02d");
    }

    function formatSignedTime(seconds) {
        var prefix = seconds < 0 ? "-" : "";
        var value = seconds < 0 ? -seconds : seconds;
        return prefix + formatTime(value);
    }

    function formatShort(seconds) {
        var minutes = seconds / 60;
        var hours = minutes / 60;
        var rest = minutes % 60;
        if (hours > 0) {
            return hours.toString() + "U" + rest.format("%02d");
        }
        return minutes.toString() + " MIN";
    }
}
