(function() {
  var root;

  common.sim.HHSimulationRK4 = (function() {

    function HHSimulationRK4() {
      this.I_ext = 0.0;
      this.I_a = 0.0;
      this.dt = 0.05;
      this.C_m = 1.0;
      this.g_Na_max = 120;
      this.g_K_max = 36;
      this.g_L_max = 0.3;
      this.E_Na = 115;
      this.E_K = -12;
      this.E_L = 10.6;
      this.V_rest = 0.0;
      this.I_Na = this.I_K = this.I_L = this.g_Na = this.g_K = this.g_L = 0.0;
      this.reset();
      this.rk4 = true;
    }

    HHSimulationRK4.prototype.reset = function() {
      this.v = this.V_rest;
      this.m = this.alphaM(this.v) / (this.alphaM(this.v) + this.betaM(this.v));
      this.n = this.alphaN(this.v) / (this.alphaN(this.v) + this.betaN(this.v));
      this.h = this.alphaH(this.v) / (this.alphaH(this.v) + this.betaH(this.v));
      this.state = [this.v, this.m, this.n, this.h];
      return this.t = 0.0;
    };

    HHSimulationRK4.prototype.unpackState = function() {
      var _ref;
      _ref = this.state, this.v = _ref[0], this.m = _ref[1], this.n = _ref[2], this.h = _ref[3];
      return this.v -= 65.0;
    };

    HHSimulationRK4.prototype.step = function(stepCallback) {
      var i, k1, k2, k3, k4, svars;
      this.t += this.dt;
      svars = [0, 1, 2, 3];
      k1 = this.ydot(this.t, this.state);
      if (this.rk4) {
        k2 = this.ydot(this.t + (this.dt / 2), (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = svars.length; _i < _len; _i++) {
            i = svars[_i];
            _results.push(this.state[i] + (this.dt * k1[i] / 2));
          }
          return _results;
        }).call(this));
        k3 = this.ydot(this.t + this.dt / 2, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = svars.length; _i < _len; _i++) {
            i = svars[_i];
            _results.push(this.state[i] + (this.dt * k2[i] / 2));
          }
          return _results;
        }).call(this));
        k4 = this.ydot(this.t + this.timeStep, (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = svars.length; _i < _len; _i++) {
            i = svars[_i];
            _results.push(this.state[i] + this.dt * k3[i]);
          }
          return _results;
        }).call(this));
        this.state = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = svars.length; _i < _len; _i++) {
            i = svars[_i];
            _results.push(this.state[i] + (this.dt / 6.0) * (k1[i] + 2 * k2[i] + 2 * k3[i] + k4[i]));
          }
          return _results;
        }).call(this);
      } else {
        this.state = (function() {
          var _i, _len, _results;
          _results = [];
          for (_i = 0, _len = svars.length; _i < _len; _i++) {
            i = svars[_i];
            _results.push(this.state[i] + this.dt * k1[i]);
          }
          return _results;
        }).call(this);
      }
      this.unpackState();
      if (stepCallback != null) {
        return stepCallback();
      }
    };

    HHSimulationRK4.prototype.alphaM = function(v) {
      return 0.1 * (25.0 - v) / (Math.exp(2.5 - 0.1 * v) - 1.0);
    };

    HHSimulationRK4.prototype.betaM = function(v) {
      return 4 * Math.exp(-1 * v / 18.0);
    };

    HHSimulationRK4.prototype.alphaN = function(v) {
      return 0.01 * (10 - v) / (Math.exp(1.0 - 0.1 * v) - 1.0);
    };

    HHSimulationRK4.prototype.betaN = function(v) {
      return 0.125 * Math.exp(-v / 80.0);
    };

    HHSimulationRK4.prototype.alphaH = function(v) {
      return 0.07 * Math.exp(-v / 20.0);
    };

    HHSimulationRK4.prototype.betaH = function(v) {
      return 1.0 / (Math.exp(3.0 - 0.1 * v) + 1.0);
    };

    HHSimulationRK4.prototype.ydot = function(t, s) {
      var dh, dm, dn, dv, dy, h, m, n, v;
      v = s[0], m = s[1], n = s[2], h = s[3];
      this.g_Na = this.g_Na_max * Math.pow(m, 3) * h;
      this.g_K = this.g_K_max * Math.pow(n, 4);
      this.g_L = this.g_L_max;
      this.I_Na = this.g_Na * (v - this.E_Na);
      this.I_K = this.g_K * (v - this.E_K);
      this.I_L = this.g_L * (v - this.E_L);
      dv = (this.I_ext + this.I_a - this.I_Na - this.I_K - this.I_L) / this.C_m;
      dm = this.alphaM(v) * (1.0 - m) - this.betaM(v) * m;
      dn = this.alphaN(v) * (1.0 - n) - this.betaN(v) * n;
      dh = this.alphaH(v) * (1.0 - h) - this.betaH(v) * h;
      dy = [dv, dm, dn, dh];
      return dy;
    };

    return HHSimulationRK4;

  })();

  root = typeof window !== "undefined" && window !== null ? window : exports;

  root.HHSimulationRK4 = HHSimulationRK4;

}).call(this);
