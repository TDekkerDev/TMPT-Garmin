using Toybox.Application;
using Toybox.Time;

class TmptModel {
    const LIMIT_SECONDS = 36000;

    var started = false;
    var finished = false;
    var startEpoch = 0;
    var finishEpoch = 0;
    var penaltySeconds = 0;
    var waitCorrectionSeconds = 0;
    var penaltyRounds = 0;

    var heartRate = 0;
    var speedKmh = 0.0;
    var averageSpeedKmh = 0.0;
    var distanceKm = 0.0;

    var lastKind = 0;
    var lastValue = 0;

    function initialize() {
        load();
    }

    function load() {
        started = valueOrDefault(Application.Storage.getValue("started"), false);
        finished = valueOrDefault(Application.Storage.getValue("finished"), false);
        startEpoch = valueOrDefault(Application.Storage.getValue("startEpoch"), 0);
        finishEpoch = valueOrDefault(Application.Storage.getValue("finishEpoch"), 0);
        penaltySeconds = valueOrDefault(Application.Storage.getValue("penaltySeconds"), 0);
        waitCorrectionSeconds = valueOrDefault(Application.Storage.getValue("waitCorrectionSeconds"), 0);
        penaltyRounds = valueOrDefault(Application.Storage.getValue("penaltyRounds"), 0);
        lastKind = valueOrDefault(Application.Storage.getValue("lastKind"), 0);
        lastValue = valueOrDefault(Application.Storage.getValue("lastValue"), 0);
    }

    function valueOrDefault(value, fallback) {
        return value == null ? fallback : value;
    }

    function save() {
        Application.Storage.setValue("started", started);
        Application.Storage.setValue("finished", finished);
        Application.Storage.setValue("startEpoch", startEpoch);
        Application.Storage.setValue("finishEpoch", finishEpoch);
        Application.Storage.setValue("penaltySeconds", penaltySeconds);
        Application.Storage.setValue("waitCorrectionSeconds", waitCorrectionSeconds);
        Application.Storage.setValue("penaltyRounds", penaltyRounds);
        Application.Storage.setValue("lastKind", lastKind);
        Application.Storage.setValue("lastValue", lastValue);
    }

    function begin() {
        started = true;
        finished = false;
        startEpoch = Time.now().value();
        finishEpoch = 0;
        penaltySeconds = 0;
        waitCorrectionSeconds = 0;
        penaltyRounds = 0;
        lastKind = 0;
        lastValue = 0;
        save();
    }

    function markFinished() {
        finishEpoch = Time.now().value();
        finished = true;
        save();
    }

    function reset() {
        started = false;
        finished = false;
        startEpoch = 0;
        finishEpoch = 0;
        penaltySeconds = 0;
        waitCorrectionSeconds = 0;
        penaltyRounds = 0;
        heartRate = 0;
        speedKmh = 0.0;
        averageSpeedKmh = 0.0;
        distanceKm = 0.0;
        lastKind = 0;
        lastValue = 0;
        save();
    }

    function addPenalty(seconds) {
        penaltySeconds += seconds;
        lastKind = 1;
        lastValue = seconds;
        save();
    }

    function addWaitCorrection(seconds) {
        waitCorrectionSeconds += seconds;
        lastKind = 2;
        lastValue = seconds;
        save();
    }

    function addPenaltyRound() {
        penaltyRounds += 1;
        lastKind = 3;
        lastValue = 1;
        save();
    }

    function undoLast() {
        if (lastKind == 1) {
            penaltySeconds -= lastValue;
            if (penaltySeconds < 0) { penaltySeconds = 0; }
        } else if (lastKind == 2) {
            waitCorrectionSeconds -= lastValue;
            if (waitCorrectionSeconds < 0) { waitCorrectionSeconds = 0; }
        } else if (lastKind == 3) {
            penaltyRounds -= 1;
            if (penaltyRounds < 0) { penaltyRounds = 0; }
        }
        lastKind = 0;
        lastValue = 0;
        save();
    }

    function elapsedSeconds() {
        if (!started || startEpoch == 0) { return 0; }
        var endEpoch = finished && finishEpoch > 0 ? finishEpoch : Time.now().value();
        var elapsed = endEpoch - startEpoch;
        return elapsed < 0 ? 0 : elapsed;
    }

    function correctedSeconds() {
        var corrected = elapsedSeconds() + penaltySeconds - waitCorrectionSeconds;
        return corrected < 0 ? 0 : corrected;
    }

    function remainingSeconds() {
        return LIMIT_SECONDS - correctedSeconds();
    }
}
