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

        # Simulation parameters
        # must be set manually from the 
        @membranePotential = ko.observable(-70.0)

        # View parameters
        @NaChannelVisible = ko.observable(true)
        @KChannelVisible = ko.observable(true)
        @OscilloscopeVisible = ko.observable(false)


# Main initialization function; triggered after the SVG doc is
# loaded
svgDocumentReady = (xml) ->

    # Attach the SVG to the DOM in the appropriate place
    importedNode = document.importNode(xml.documentElement, true)
    d3.select('#art').node().appendChild(importedNode)

    # Build a new simulation object
    sim = new HHSimulationRK4()

    # Build a view model obj
    viewModel = new HHViewModel()

    # Bind variables from the simulation to the view model
    bindings.exposeOutputBindings(sim, ['v', 'm', 'n', 'h', 'I_Na', 'I_K', 'I_L'], viewModel)
    bindings.exposeInputBindings(sim, ['g_Na_max', 'g_K_max', 'g_L_max'], viewModel)

    # Bind data to the svg
    bindings.bindVisible('#NaChannel', viewModel.NaChannelVisible)
    bindings.bindVisible('#KChannel', viewModel.KChannelVisible)

    # Set the html-based Knockout.js bindings in motion
    ko.applyBindings(viewModel)

    oscope = new Oscilloscope(d3.select('#art svg'), d3.select('#oscope'))

    runSimulation = true

    update = ->
        sim.update()
        if isNaN(sim.v)
            runSimulation = false
            return
        bindings.updateOutputBindings()
        viewModel.membranePotential(sim.v)
        oscope.pushData(sim.t, sim.v)

    updateTimer = setInterval(update, 10)

    heartbeat = ->
        if not runSimulation
            clearInterval(updateTimer)
    setInterval(heartbeat, 50)


$ ->
	# load the svg artwork and hook everything up
	d3.xml('svg/membrane_hh.svg', 'image/svg+xml', svgDocumentReady)
