using Toybox.Activity;
using Toybox.ActivityRecording;
using Toybox.Attention;
using Toybox.Application;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.Timer;
using Toybox.WatchUi;

class TmptApp extends Application.AppBase {
    var model;
    var view;
    var session = null;
    var tickTimer;
    var lastAlertLevel = 0;

    function initialize() {
        AppBase.initialize();
        model = new TmptModel();
        tickTimer = new Timer.Timer();
    }

    function onStart(state) {
        tickTimer.start(method(:onTick), 1000, true);
        if (model.started && !model.finished) {
            enableTracking();
        }
    }

    function onStop(state) {
        tickTimer.stop();
        Sensor.enableSensorEvents(null);
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
    }

    function getInitialView() {
        view = new TmptView(model);
        return [view, new TmptDelegate(self, model)];
    }

    function startDay() {
        if (model.started && !model.finished) { return; }
        model.begin();
        lastAlertLevel = 0;
        enableTracking();
        WatchUi.requestUpdate();
    }

    function enableTracking() {
        if (Toybox has :ActivityRecording) {
            session = ActivityRecording.createSession({
                :name => "TMPT Training",
                :sport => Activity.SPORT_TACTICAL,
                :subSport => Activity.SUB_SPORT_GENERIC
            });
            if (!session.isRecording()) {
                session.start();
            }
        }

        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    function onSensor(info as Sensor.Info) as Void {
        if (info != null && info.heartRate != null) {
            model.heartRate = info.heartRate;
        }
    }

    function onPosition(info as Position.Info) as Void {
        // Location events keep GPS active. Route data is stored in the FIT activity.
    }

    function onTick() {
        if (model.started && !model.finished) {
            var info = Activity.getActivityInfo();
            if (info != null) {
                model.heartRate = info.currentHeartRate == null ? model.heartRate : info.currentHeartRate;
                model.speedKmh = info.currentSpeed == null ? 0.0 : info.currentSpeed * 3.6;
                model.averageSpeedKmh = info.averageSpeed == null ? 0.0 : info.averageSpeed * 3.6;
                model.distanceKm = info.elapsedDistance == null ? 0.0 : info.elapsedDistance / 1000.0;
            }
            checkTimeAlert(model.remainingSeconds());
        }
        WatchUi.requestUpdate();
    }

    function checkTimeAlert(remaining) {
        var level = 0;
        if (remaining <= 3600) { level = 1; }
        if (remaining <= 1800) { level = 2; }
        if (remaining <= 900) { level = 3; }
        if (remaining <= 300) { level = 4; }
        if (remaining <= 0) { level = 5; }

        if (level > lastAlertLevel) {
            lastAlertLevel = level;
            Attention.vibrate([new Attention.VibeProfile(level >= 4 ? 100 : 70, level >= 4 ? 800 : 400)]);
        }
    }

    function finishDay() {
        if (session != null) {
            if (session.isRecording()) { session.stop(); }
            session.save();
            session = null;
        }
        model.markFinished();
        Sensor.enableSensorEvents(null);
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        WatchUi.requestUpdate();
    }

    function discardDay() {
        if (session != null) {
            if (session.isRecording()) { session.stop(); }
            session.discard();
            session = null;
        }
        model.reset();
        Sensor.enableSensorEvents(null);
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        WatchUi.requestUpdate();
    }
}
