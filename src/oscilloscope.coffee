# A d3.js-based oscilloscope

class Oscilloscope

    constructor: (@svg, @frame) ->

        @data = []

        # Data bounds
        @minX = 0.0
        @maxX = 10.0
        @minY = -90.0
        @maxY = 50.0

        @dataXOffset = 0.0


        # Frame bounds
        @margin = {top: 5.0, right: 5.0, bottom: 5.0, left: 5.0}
        @width = Number(@frame.attr('width')) - @margin.left - @margin.right
        @height = Number(@frame.attr('height')) - @margin.top - @margin.bottom

        @frameXOffset = Number(@frame.attr('x'))
        @frameYOffset = Number(@frame.attr('y'))

        @setScales()

        o = this
        @line = d3.svg.line()
                    .x((d,i) -> o.xScale(d.x))
                    .y((d,i) -> o.yScale(d.y))

        left = @margin.left + @xOffset
        top = @margin.top + @yOffset

        @plot = svg.insert('g', '#oscope')

        @path = @plot.append('path')
                    .data([@data])
                    .attr('class', 'line')
                    .attr('d', @line)



    setScales: () ->
        @xScale = d3.scale.linear()
                    .domain([@minX, @maxX])
                    .range([@frameXOffset+@margin.left, @frameXOffset+@margin.left+@width])

        @yScale = d3.scale.linear()
                    .domain([@minY, @maxY])
                    .range([@frameYOffset + @height + @margin.top, @frameYOffset + @margin.top]);


    reset: () ->
        @data.pop() for t in @data
        @data.pop()
        @dataXOffset = 0.0
        @setScales()


    pushData: (x, y) ->

        xval = x - @dataXOffset

        if xval > @maxX
            @data.pop() for t in @data
            @data.pop()
            @dataXOffset = x
            xval = 0.0

        @data.push({x:xval,y:y})

        @path.attr('d', @line)


root = window ? exports
root.Oscilloscope = Oscilloscope
