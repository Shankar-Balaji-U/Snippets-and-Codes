
class StopWatch extends EventTarget {
    fromTime = null;
    toTime = null;
    isPaused = false;

    totalTime = {
        milliseconds: 0,
        seconds: 0,
        minutes: 0,
        hours: 0
    };

    interval = 10;
    timerID = null;

    _runTimer() {
        var $this = this;
        this.timerID = setInterval(function() {
                $this.addTime($this.interval);
            }, this.interval);
    }
    
    start() {
        if (this.isPaused) {
            return;
        }
        this._runTimer();
        this.fromTime = new Date();
        this.dispatchEvent(new CustomEvent("start"));
    }

    pause() {
        if (this.isPaused) {
            return;
        }
        clearInterval(this.timerID);
        this.isPaused = true;
        this.dispatchEvent(new CustomEvent("pause"));
    }

    play() {
        if (!this.isPaused) {
            return;
        }
        this._runTimer();
        this.isPaused = false;
        this.dispatchEvent(new CustomEvent("play"));
    }

    stop() {
        this.toTime = new Date();
        clearInterval(this.timerID);
        this.dispatchEvent(new CustomEvent("stop"));
        this.totalTime = {
            milliseconds: 0,
            seconds: 0,
            minutes: 0,
            hours: 0
        };
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
