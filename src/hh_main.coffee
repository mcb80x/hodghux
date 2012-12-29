# ----------------------------------------------------
# Imports (using coffee-toaster directives)
# ----------------------------------------------------

root = window ? exports

#<< common/bindings
b = root.bindings

#<< common/oscilloscope

#<< common/sim/hh_rk
HHSimulationRK4 = root.HHSimulationRK4

#<< common/sim/stim
SquareWavePulse = root.SquareWavePulse

#<< common/util
util = root.util


# ----------------------------------------------------


# Main initialization function; triggered after the SVG doc is
# loaded
svgDocumentReady = (xml) ->

    # Attach the SVG to the DOM in the appropriate place
    importedNode = document.importNode(xml.documentElement, true)
    d3.select('#art').node().appendChild(importedNode)

    initializeSimulation()

initializeSimulation = () ->

    # Build a new simulation object
    sim = new HHSimulationRK4()

    # Build a square-wave pulse object
    pulse = new SquareWavePulse([0.0, 1.0], 15.0)

    # Build a view model obj to manage KO bindings
    viewModel =
        @NaChannelVisible: ko.observable(true)
        @KChannelVisible: ko.observable(true)
        @OscilloscopeVisible: ko.observable(false)

    # Bind variables from the simulation to the view model
    b.exposeOutputBindings(sim, ['t', 'v', 'm', 'n', 'h', 'I_Na', 'I_K', 'I_L'], viewModel)
    b.exposeInputBindings(sim, ['g_Na_max', 'g_K_max', 'g_L_max', 'I_ext'], viewModel)

    # Hook up the pulse object
    b.bindOutput(pulse, 'I_stim', viewModel, 'I_ext')
    b.bindInput(pulse, 't', viewModel, 't', -> pulse.update())

    # Add a few computed / derivative observables
    viewModel.NaChannelOpen = ko.computed(-> (viewModel.m() > 0.5))
    viewModel.KChannelOpen = ko.computed(-> (viewModel.n() > 0.65))
    viewModel.BallAndChainOpen = ko.computed(-> (viewModel.h() > 0.3))

    # Bind data to the svg to marionette parts of the artwork
    b.bindVisible('#NaChannel', viewModel.NaChannelVisible)
    b.bindVisible('#KChannel', viewModel.KChannelVisible)
    b.bindMultiState({'#NaChannelClosed':false, '#NaChannelOpen':true}, viewModel.NaChannelOpen)
    b.bindMultiState({'#KChannelClosed':false, '#KChannelOpen':true}, viewModel.KChannelOpen)
    b.bindMultiState({'#BallAndChainClosed':false, '#BallAndChainOpen':true}, viewModel.BallAndChainOpen)

    b.bindAttr('#NaArrow', 'opacity', viewModel.I_Na, d3.scale.linear().domain([0, -100]).range([0, 1.0]))
    b.bindAttr('#KArrow', 'opacity', viewModel.I_K, d3.scale.linear().domain([20, 100]).range([0, 1.0]))

    # Set the html-based Knockout.js bindings in motion
    # This will allow templated 'data-bind' directives to automagically control the simulation / views
    ko.applyBindings(viewModel)

    # Make an oscilloscope and attach it to the svg
    oscope = oscilloscope('#art svg', '#oscope').data(-> [sim.t, sim.v])

    # Float a div over a rect in the svg
    util.floatOverRect('#art svg', '#floatrect', '#floaty')

    runSimulation = true
    maxSimTime = 10.0
    oscope.maxX = maxSimTime

    update = ->

        # Update the simulation
        sim.step(b.update)

        # stop if the result is silly
        if isNaN(sim.v)
            runSimulation = false
            return

        # Tell the oscilloscope to plot
        oscope.plot()

        if sim.t >= maxSimTime
            sim.reset()
            oscope.reset()


    updateTimer = setInterval(update, 100)

    # Start a timer to keep an eye on the simulation
    watchDog = ->
        if not runSimulation
            clearInterval(updateTimer)
    setInterval(watchDog, 500)


$ ->
	# load the svg artwork and hook everything up
	d3.xml('svg/membrane_hh_raster_shadows_embedded.svg', 'image/svg+xml', svgDocumentReady)
