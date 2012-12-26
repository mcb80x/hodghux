
class CustomBindings

    constructor: ->
        @manualOutputBindings = []

    bindVisible: (selector, observable) ->
        el = d3.select(selector)

        setter = (newVal) ->
            if newVal
                el.attr('opacity', 1.0)
            else
                el.attr('opacity', 0.0)

        observable.subscribe(setter)
        setter(observable())


    bindAttr: (selector, attr, observable) ->

        el = d3.select(selector)
        console.log(el)

        setter = (newVal) ->
            el.attr(attr, newVal)

        observable.subscribe(setter)
        setter(observable())


    exposeOutputBindings: (sourceObj, keys, viewModel) ->
        @manualBindOutput(sourceObj, key, viewModel) for key in keys

    manualBindOutput: (sourceObj, key, viewModel) ->
        console.log(sourceObj)
        
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