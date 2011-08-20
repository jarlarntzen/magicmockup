$ = @jQuery

@magicmockup = do ->
  inkNS = 'http://www.inkscape.org/namespaces/inkscape'
  $doc = $(@document)
  views = {}


  # Do the heavy lifting
  # (right now, there's only "next" for switching pages; more to come)
  _dispatch = (context, [command, id]) ->
    act =
      next: ->
        # Hide the current visible view
        $(context).parents('g:visible').last().hide()
        # Show the specified view
        $(views[id]).show?()

    act[command]?()


  # Add each view to the view object (if it contains a an Inkscape label)
  _addViews = ($views) ->
    $views.each ->
      label = @getAttributeNS(inkNS, 'label')
      views[label] = @ if label
    return


  # Handle clicks on items with instructions
  _handleClick = (e) ->
    actions = _getDescription(e.currentTarget)

    # Skip if there's no description
    return unless actions

    for action in actions.split /([\s\n]+)/
      _dispatch(@, action.split /\=/)

    return


  # Change the cursor for interactive elements
  _handleHover = (e) ->
    $this = $(this)

    # Skip if already hoverable
    return if $this.data('hoverable')

    # We're handling the hoverable state now
    $this.data('hoverable', true)

    # Skip if there's no description
    return unless _getDescription(e.currentTarget)

    $this.css(cursor: 'pointer')
    return


  # Return the description for an element
  _getDescription = (el) ->
    $(el).children('desc').text()


  init = (loadEvent) ->
    _addViews $('g')

    $doc.delegate 'g'
      click    : _handleClick
      mouseover: _handleHover


  {init} # Public exports


# Dummy function to handle the inline JS
# (FIXME: The dummy JS should be removed from the SVG)
@nextScreen = (e) ->

# Hack to attach the init to <svg/> for an unobtrusive SVG onload
$('svg').attr onload: 'magicmockup.init()'
