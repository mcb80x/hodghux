(function() {

  common.sim.SquareWavePulse = (function() {

    function SquareWavePulse(interval, amplitude) {
      this.interval = interval;
      this.amplitude = amplitude;
      this.t = 0.0;
      this.I_stim = 0.0;
    }

    SquareWavePulse.prototype.update = function() {
      if (this.t > this.interval[0] && this.t < this.interval[1]) {
        return this.I_stim = this.amplitude;
      } else {
        return this.I_stim = 0.0;
      }
    };

    return SquareWavePulse;

  })();

}).call(this);
