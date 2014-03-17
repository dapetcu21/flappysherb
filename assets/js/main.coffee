require ['jquery', 'anim'], ($) ->

  $(window).ready ->
    xVel = 150
    xBird = 40
    wBird = 92
    hBird = 40
    g = 1000
    flapVel = 350
    groundW = 37
    pipeYmax = 500
    pipeYmin = 200
    pipeOffset = 400
    pipeW = 138
    pipeH = 793
    opening = 140

    yVel = yBird = xOff = distanceToPipe = 0
    scored = score = pipesX = pipesY = 0
    pipesUp = []
    pipesDown = []
    running = false

    first = true
    lastTime = 0

    container = $('.container')
    bird = container.find('.bird')
    ground = container.find('.ground')
    pipes = container.find('.pipes')
    scoreDiv = container.find('.score')
    gameover = container.find('.gameover')

    init = ->
      gameover.removeClass 'on'
      yVel = 0
      yBird = 450
      running = true
      distanceToPipe = container.width() + 100
      scored = 0
      score = 0

      clearArray = (v) ->
        for o, i in v
          do (o, i) ->
            setTimeout ->
              o.addClass 'disappear'
            , 100 * i
            setTimeout ->
              o.remove()
            , 300 + 100 * i
      
      clearArray pipesUp
      clearArray pipesDown

      pipesX = []
      pipesY = []
      pipesDown = []
      pipesUp = []
      first = true
      scoreDiv.html '0'
      requestAnimationFrame f

    onAction = ->
      if running
        yVel = flapVel

    $(window).keypress (e) ->
      if e.which == 13 or e.which == 32
        if running
          onAction()
        else
          init()

    container.on 'mousedown touchstart MSPointerDown', (e) ->
      onAction()
      e.preventDefault()

    gameover.on 'mousedown touchstart MSPointerDown', (e) ->
      init()
      e.preventDefault()

    addTemplate = (up, y) ->
      tmp = '<div class="pipe ' + (if up then 'up' else 'down') + '"></div>'
      a = $(tmp)
      a.appendTo pipes
      a.css 'bottom', if up then y + opening else y - pipeH
      a

    gameOver = (motiv) ->
      running = false
      console.log "Game Over"
      gameover.find('.motiv').html motiv
      gameover.addClass 'on'


    f = (now) ->
      elapsed = Math.round((now - lastTime) * 0.001 / (1.0/60)) * (1.0/60)
      if not first and elapsed == 0
        requestAnimationFrame f
        return
      lastTime = now
      if first
        elapsed = 0
        first = false
      yBird += yVel * elapsed
      yVel -= elapsed * g
      xOff -= elapsed * xVel
      distanceToPipe -= elapsed * xVel

      if yBird <= 128
        gameOver "SHERB SHOULD GLIDE AS LIGHT AS A FEATHER"
        yBird = 128

      while xOff < -groundW
        xOff += groundW

      w = container.width()

      for o, i in pipesX
        pipesX[i] -= elapsed * xVel

      while w >= distanceToPipe
        pipesX.push distanceToPipe
        y = Math.random() * (pipeYmax - pipeYmin) + pipeYmin
        pipesY.push y
        pipesDown.push addTemplate false, y
        pipesUp.push addTemplate true, y
        distanceToPipe += pipeOffset

      idx = 0
      for o, i in pipesX
        if o + pipeW >= 0
          idx = i
          break
        pipesUp[i].remove()
        pipesDown[i].remove()

      pipesX.splice 0, idx
      pipesY.splice 0, idx
      pipesUp.splice 0, idx
      pipesDown.splice 0, idx
      scored -= idx

      while scored < pipesX.length and pipesX[scored] + pipeW < xBird
        scored++
        score++
        scoreDiv.html ''+score

      for o, i in pipesDown
        o.css 'left', pipesX[i]
      for o, i in pipesUp
        o.css 'left', pipesX[i]

      for x, i in pipesX
        if xBird + wBird >= x and xBird <= x + pipeW
          y = pipesY[i]
          if yBird <= y or yBird + hBird >= y + opening
            gameOver "SHERB ISN'T SUPPOSED TO GET A TROPHY"

      bird.css 'bottom', yBird
      ground.css 'background-position-x', xOff

      if running
        requestAnimationFrame f

    init()
