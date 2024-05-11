class StopWatch extends EventTarget {
    fromTime = null;
    toTime = null;
    state = null;

    totalTime = {
        milliseconds: 0,
        seconds: 0,
        minutes: 0,
        hours: 0
    };

    interval = 10;
    timerID = null;

    constructor() {
        super();
        this.state = this.STATE.Stopped;
    }

    get STATE() {
        return {
            Started: 0,
            Stopped: 1,
            Played:2,
            Paused: 3
        };
    }

    _runTimer() {
        var $this = this;
        this.timerID = setInterval(function() {
            $this.addTime($this.interval);
        }, this.interval);
    }

    start() {
        if (this.state !== this.STATE.Stopped)
            return;
        this.fromTime = new Date();
        this._runTimer();
        this.state = this.STATE.Started;
        this.dispatchEvent(new CustomEvent("start"));
    }

    pause() {
        if (this.state !== this.STATE.Played)
            return;
        clearInterval(this.timerID);
        this.state = this.STATE.Paused;
        this.dispatchEvent(new CustomEvent("pause"));
    }

    play() {
        if (this.state !== this.STATE.Paused)
            return;
        this._runTimer();
        this.state = this.STATE.Played;
        this.dispatchEvent(new CustomEvent("play"));
    }

    stop() {
        if (this.state !== this.STATE.Started)
            return;
        this.toTime = new Date();
        clearInterval(this.timerID);
        this.state = this.STATE.Stopped;
        this.dispatchEvent(new CustomEvent("stop"));
        this.totalTime = {
            milliseconds: 0,
            seconds: 0,
            minutes: 0,
            hours: 0
        };
        this.timerID = null;
    }

    addTime(milliseconds) {
        if ((this.totalTime.milliseconds + milliseconds) >= 1000) {
            this.totalTime.milliseconds = 0;
            if ((this.totalTime.seconds + 1) >= 60) {
                this.totalTime.seconds = 0;
                if ((this.totalTime.minutes + 1) >= 60) {
                    this.totalTime.minutes = 0;
                    this.totalTime.hours++;
                    this.dispatchEvent(new CustomEvent("counting-hours", { detail: this.totalTime }));
                } else {
                    this.totalTime.minutes++;
                }
                this.dispatchEvent(new CustomEvent("counting-minutes", { detail: this.totalTime }));
            } else {
                this.totalTime.seconds++;
            }
            this.dispatchEvent(new CustomEvent("counting-seconds", { detail: this.totalTime }));
        } else {
            this.totalTime.milliseconds = this.totalTime.milliseconds + milliseconds;
        }
        this.dispatchEvent(new CustomEvent("counting-milliseconds", { detail: this.totalTime }));
    }
}

let counter = new StopWatch();
counter.addEventListener('counting-milliseconds', function(event) {
  console.log(event.detail);
});
counter.start();
