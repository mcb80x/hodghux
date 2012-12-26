
class CustomBindings

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


root = window ? exports
root.bindings = new CustomBindings