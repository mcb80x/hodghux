# ----------------------------------------------------
# Imports (using coffee-toaster directives)
# ----------------------------------------------------

root = window ? exports

#<< custom_bindings
b = root.bindings

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


# # Just a dummy for now
# class HHSimulation
#     constructor: ->
#         @time = 0.0
#         @timeStep = 0.1
#         @membranePotential = 0.0

#     update: ->
#         @time += @timeStep
#         @membranePotential = Math.sin(@time)



# A Knockout.js-compatible View Model
class HHViewModel
    constructor: ->
        @membranePotential = ko.observable(-70.0)
        @NaChannelVisible = ko.observable(true)
        @KChannelVisible = ko.observable(true)
        @OscilloscopeVisible = ko.observable(false)


# Main initialization function; triggered after the SVG doc is
# loaded
svgDocumentReady = (xml) ->

    # attach the SVG to the DOM in the appropriate place
    importedNode = document.importNode(xml.documentElement, true)
    d3.select('#art').node().appendChild(importedNode)

    # build a simulation object
    sim = new HHSimulationRK4()

    # Build a view model obj & set the Knockout.js bindings in motion
    viewModel = new HHViewModel()
    ko.applyBindings(viewModel)

    # bind data to the svg
    b.bindVisible('#NaChannel', viewModel.NaChannelVisible)
    b.bindVisible('#KChannel', viewModel.KChannelVisible)

    oscope = new Oscilloscope(d3.select('#art svg'), d3.select('#oscope'))

    runSimulation = true

    update = ->
        sim.update()
        if isNaN(sim.v)
            runSimulation = false
            return
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
