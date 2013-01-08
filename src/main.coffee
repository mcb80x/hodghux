#<< mcb80x/timeline
#<< mcb80x/lesson_plan
#<< hodghux


# Script

scene('Action Potential Generation', 'hodgkinhuxley') ->

    interactive('Basic action walk-through') ->
        stage 'hodghux'
        duration 10

        wait 500

        line 'ap_line1',
            "We're now going to let the simulation run for three iterations.  Of course, more sophisticated scripting is also possible",
            {'NaChannelVisible': true, 'KChannelVisible': false} # <-- settings for the stage

        play 'beginning'

        goal ->
            initial:
                transition: ->
                    if @stage.iterations >= 3
                        return 'continue'
            hint1:
                action: ->
                    line 'hint1', "This message will pop up after 10 seconds, just ignore it"

                transition: -> 'initial'

        line 'ap_line1',
            "That's it!"


$ ->

	t = new mcb80x.Timeline('#timeline', scenes.hodgkinhuxley)
	scenes.hodgkinhuxley.run(-> alert('done'))
