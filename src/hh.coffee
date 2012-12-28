# ----------------------------------------------------
# Imports (using coffee-toaster directives)
# ----------------------------------------------------

root = window ? exports

#<< custom_bindings
bindings = root.bindings

#<< oscilloscope
Oscilloscope = root.Oscilloscope

#<< hh_rk
HHSimulationRK4 = root.HHSimulationRK4

#<< util
util = root.util

# ----------------------------------------------------



# ----------------------------------------------------
# Globals
# ----------------------------------------------------

oscope = null
simulation = null


# A Knockout.js-compatible View Model
class HHViewModel
    constructor: ->
        @manualBindings = []

        # View parameters
        @NaChannelVisible = ko.observable(true)
        @KChannelVisible = ko.observable(true)
        @OscilloscopeVisible = ko.observable(false)

        # @NaChannelOpen = ko.observable(true)

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

    # Build a view model obj to manage KO bindings
    viewModel = new HHViewModel()

    # Bind variables from the simulation to the view model
    bindings.exposeOutputBindings(sim, ['t', 'v', 'm', 'n', 'h', 'I_Na', 'I_K', 'I_L'], viewModel)
    bindings.exposeInputBindings(sim, ['g_Na_max', 'g_K_max', 'g_L_max'], viewModel)
    sim.stepCallback = bindings.update

    # Add a few computed / derivative observables
    viewModel.NaChannelOpen = ko.computed(-> (viewModel.m() > 0.5))
    viewModel.KChannelOpen = ko.computed(-> (viewModel.n() > 0.65))
    viewModel.BallAndChainOpen = ko.computed(-> (viewModel.h() > 0.3))

    # Bind data to the svg to marionette parts of the artwork
    bindings.bindVisible('#NaChannel', viewModel.NaChannelVisible)
    bindings.bindVisible('#KChannel', viewModel.KChannelVisible)
    bindings.bindMultiState({'#NaChannelClosed':false, '#NaChannelOpen':true}, viewModel.NaChannelOpen)
    bindings.bindMultiState({'#KChannelClosed':false, '#KChannelOpen':true}, viewModel.KChannelOpen)
    bindings.bindMultiState({'#BallAndChainClosed':false, '#BallAndChainOpen':true}, viewModel.BallAndChainOpen)

    bindings.bindAttr('#NaArrow', 'opacity', viewModel.I_Na, d3.scale.linear().domain([0, -100]).range([0, 1.0]))
    bindings.bindAttr('#KArrow', 'opacity', viewModel.I_K, d3.scale.linear().domain([20, 100]).range([0, 1.0]))

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
        sim.step()

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

    heartbeat = ->
        if not runSimulation
            clearInterval(updateTimer)
    setInterval(heartbeat, 500)


$ ->
	# load the svg artwork and hook everything up
	d3.xml('svg/membrane_hh_raster_shadows_embedded.svg', 'image/svg+xml', svgDocumentReady)
