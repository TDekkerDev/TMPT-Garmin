using Toybox.WatchUi;

class TmptDelegate extends WatchUi.BehaviorDelegate {
    var app;
    var model;

    function initialize(anApp, aModel) {
        BehaviorDelegate.initialize();
        app = anApp;
        model = aModel;
    }

    function onSelect() {
        if (!model.started || model.finished) {
            app.startDay();
        } else {
            showFinishMenu();
        }
        return true;
    }

    function onMenu() {
        if (!model.started || model.finished) { return true; }

        var menu = new WatchUi.Menu2({:title => "TIJD AANPASSEN"});
        menu.addItem(new WatchUi.MenuItem("Straftijd +5 min", null, :penalty5, null));
        menu.addItem(new WatchUi.MenuItem("Straftijd +15 min", null, :penalty15, null));
        menu.addItem(new WatchUi.MenuItem("Straftijd +20 min", null, :penalty20, null));
        menu.addItem(new WatchUi.MenuItem("Straftijd +45 min", null, :penalty45, null));
        menu.addItem(new WatchUi.MenuItem("Wachtcorrectie +5", null, :wait5, null));
        menu.addItem(new WatchUi.MenuItem("Wachtcorrectie +15", null, :wait15, null));
        menu.addItem(new WatchUi.MenuItem("Strafronde +1", null, :round1, null));
        menu.addItem(new WatchUi.MenuItem("Laatste ongedaan", null, :undo, null));
        menu.addItem(new WatchUi.MenuItem("Dag afronden", null, :finish, null));
        WatchUi.pushView(menu, new TmptAdjustmentDelegate(app, model), WatchUi.SLIDE_UP);
        return true;
    }

    function onNextPage() {
        app.view.nextPage();
        return true;
    }

    function onPreviousPage() {
        app.view.previousPage();
        return true;
    }

    function onBack() {
        if (model.started && !model.finished) {
            return onMenu();
        }
        return false;
    }

    function showFinishMenu() {
        var menu = new WatchUi.Menu2({:title => "DAG AFRONDEN"});
        menu.addItem(new WatchUi.MenuItem("Opslaan", null, :save, null));
        menu.addItem(new WatchUi.MenuItem("Niet afronden", null, :cancel, null));
        menu.addItem(new WatchUi.MenuItem("Verwijderen", null, :discard, null));
        WatchUi.pushView(menu, new TmptFinishDelegate(app), WatchUi.SLIDE_UP);
    }
}

class TmptAdjustmentDelegate extends WatchUi.Menu2InputDelegate {
    var app;
    var model;

    function initialize(anApp, aModel) {
        Menu2InputDelegate.initialize();
        app = anApp;
        model = aModel;
    }

    function onSelect(item) {
        var id = item.getId();
        if (id == :penalty5) { model.addPenalty(300); }
        else if (id == :penalty15) { model.addPenalty(900); }
        else if (id == :penalty20) { model.addPenalty(1200); }
        else if (id == :penalty45) { model.addPenalty(2700); }
        else if (id == :wait5) { model.addWaitCorrection(300); }
        else if (id == :wait15) { model.addWaitCorrection(900); }
        else if (id == :round1) { model.addPenaltyRound(); }
        else if (id == :undo) { model.undoLast(); }
        else if (id == :finish) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            app.finishDay();
            return;
        }
        app.vibrateAdjustment();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }
}

class TmptFinishDelegate extends WatchUi.Menu2InputDelegate {
    var app;

    function initialize(anApp) {
        Menu2InputDelegate.initialize();
        app = anApp;
    }

    function onSelect(item) {
        var id = item.getId();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        if (id == :save) { app.finishDay(); }
        else if (id == :discard) { app.discardDay(); }
    }
}
