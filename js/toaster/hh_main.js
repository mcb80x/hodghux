(function() {
  var HHSimulationRK4, SquareWavePulse, b, initializeSimulation, svgDocumentReady;

  b = bindings;

  HHSimulationRK4 = common.sim.HHSimulationRK4;

  SquareWavePulse = common.sim.SquareWavePulse;

  initializeSimulation = function() {
    var maxSimTime, oscope, pulse, runSimulation, sim, update, updateTimer, viewModel, watchDog;
    sim = new HHSimulationRK4();
    pulse = new SquareWavePulse([0.0, 1.0], 15.0);
    viewModel = {
      NaChannelVisible: ko.observable(true),
      KChannelVisible: ko.observable(true),
      OscilloscopeVisible: ko.observable(false)
    };
    b.exposeOutputBindings(sim, ['t', 'v', 'm', 'n', 'h', 'I_Na', 'I_K', 'I_L'], viewModel);
    b.exposeInputBindings(sim, ['g_Na_max', 'g_K_max', 'g_L_max', 'I_ext'], viewModel);
    b.bindOutput(pulse, 'I_stim', viewModel, 'I_ext');
    b.bindInput(pulse, 't', viewModel, 't', function() {
      return pulse.update();
    });
    viewModel.NaChannelOpen = ko.computed(function() {
      return viewModel.m() > 0.5;
    });
    viewModel.KChannelOpen = ko.computed(function() {
      return viewModel.n() > 0.65;
    });
    viewModel.BallAndChainOpen = ko.computed(function() {
      return viewModel.h() > 0.3;
    });
    b.bindVisible('#NaChannel', viewModel.NaChannelVisible);
    b.bindVisible('#KChannel', viewModel.KChannelVisible);
    b.bindMultiState({
      '#NaChannelClosed': false,
      '#NaChannelOpen': true
    }, viewModel.NaChannelOpen);
    b.bindMultiState({
      '#KChannelClosed': false,
      '#KChannelOpen': true
    }, viewModel.KChannelOpen);
    b.bindMultiState({
      '#BallAndChainClosed': false,
      '#BallAndChainOpen': true
    }, viewModel.BallAndChainOpen);
    b.bindAttr('#NaArrow', 'opacity', viewModel.I_Na, d3.scale.linear().domain([0, -100]).range([0, 1.0]));
    b.bindAttr('#KArrow', 'opacity', viewModel.I_K, d3.scale.linear().domain([20, 100]).range([0, 1.0]));
    ko.applyBindings(viewModel);
    oscope = oscilloscope('#art svg', '#oscope').data(function() {
      return [sim.t, sim.v];
    });
    util.floatOverRect('#art svg', '#floatrect', '#floaty');
    runSimulation = true;
    maxSimTime = 10.0;
    oscope.maxX = maxSimTime;
    update = function() {
      sim.step();
      b.update();
      if (isNaN(sim.v)) {
        runSimulation = false;
        return;
      }
      oscope.plot();
      if (sim.t >= maxSimTime) {
        sim.reset();
        return oscope.reset();
      }
    };
    updateTimer = setInterval(update, 100);
    watchDog = function() {
      if (!runSimulation) {
        return clearInterval(updateTimer);
      }
    };
    return setInterval(watchDog, 500);
  };

  svgDocumentReady = function(xml) {
    var importedNode;
    importedNode = document.importNode(xml.documentElement, true);
    d3.select('#art').node().appendChild(importedNode);
    return initializeSimulation();
  };

  $(function() {
    return d3.xml('svg/membrane_hh_raster_shadows_embedded.svg', 'image/svg+xml', svgDocumentReady);
  });

}).call(this);
