# Imports
root = window ? exports

#<< custom_bindings
b = root.bindings

#<< oscilloscope
Oscilloscope = root.Oscilloscope


oscope = null
simulation = null


# Just a dummy for now
class HHSimulation
    constructor: ->
        @time = 0.0
        @timeStep = 0.1
        @membranePotential = 0.0

    update: ->
        @time += @timeStep
        @membranePotential = Math.sin(@time)


class HHViewModel
    constructor: ->
        @membranePotential = ko.observable(-70.0)
        @NaChannelVisible = ko.observable(true)
        @KChannelVisible = ko.observable(true)
        @OscilloscopeVisible = ko.observable(false)


svgDocumentReady = (xml) ->

    # attach the SVG to the DOM in the appropriate place
    importedNode = document.importNode(xml.documentElement, true)
    d3.select('#art').node().appendChild(importedNode)

    # build a simulation object
    simulation = new HHSimulation()

    # Build a view model obj & set the Knockout.js bindings in motion
    viewModel = new HHViewModel()
    ko.applyBindings(viewModel)

    # bind data to the svg
    b.bindVisible('#NaChannel', viewModel.NaChannelVisible)
    b.bindVisible('#KChannel', viewModel.KChannelVisible)

    oscope = new Oscilloscope(d3.select('#art svg'), d3.select('#oscope'))
    oscope.pushData(0.1, 0.5)

    update = ->
        simulation.update()
        viewModel.membranePotential(simulation.membranePotential)
        oscope.pushData(simulation.time, simulation.membranePotential)

    # update() for i in [1..200]

    setInterval(update, 50)


$ ->
	# load the svg artwork and hook everything up
	d3.xml('svg/membrane_hh.svg', 'image/svg+xml', svgDocumentReady)
