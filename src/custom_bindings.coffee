
hideElement = (el) ->
    el.attr('opacity', 0.0)

showElement = (el) ->
    el.attr('opacity', 1.0)


class CustomBindings

    constructor: ->
        @manualOutputBindings = []


    bindVisible: (selector, observable) ->
        el = d3.select(selector)

        thisobj = this
        setter = (newVal) ->
            if newVal
                showElement(el)
            else
                hideElement(el)

        observable.subscribe(setter)
        setter(observable())


    bindAttr: (selector, attr, observable, mapping) ->

        el = d3.select(selector)
        console.log(el)

        setter = (newVal) ->
            el.attr(attr, mapping(newVal))

        observable.subscribe(setter)
        setter(observable())

    bindMultiState: (selectorMap, observable) ->
        keys = Object.keys(selectorMap)
        values = (selectorMap[k] for k in keys)
        elements = (d3.select(s) for s in keys)

        setter = (val) ->
            # hide all of the alternatives
            hideElement(el) for el in elements

            matchSelectors = (keys[i] for i in [0 .. keys.length] when values[i] == val)
            matchElements = (d3.select(s) for s in matchSelectors)
            showElement(el) for el in matchElements

        observable.subscribe(setter)

        setter(observable())

    exposeOutputBindings: (sourceObj, keys, viewModel) ->
        @manualBindOutput(sourceObj, key, viewModel) for key in keys

    manualBindOutput: (sourceObj, key, viewModel) ->
        viewModel[key] = ko.observable(sourceObj[key])
        @manualOutputBindings.push([sourceObj, key, viewModel[key]])

    updateOutputBindings: ->
        obs(sourceObj[key]) for [sourceObj, key, obs] in @manualOutputBindings

    manualBindInput: (sourceObj, key, viewModel) ->
        viewModel[key] = ko.observable(sourceObj[key])
        viewModel[key].subscribe((newVal) ->
            sourceObj[key] = newVal)

    exposeInputBindings: (sourceObj, keys, viewModel) ->
        @manualBindInput(sourceObj, key, viewModel) for key in keys

root = window ? exports
root.bindings = new CustomBindings