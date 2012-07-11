$ = @jQuery or require('jquery')


do ->
  lastTime = 0
  vendors = [ "ms", "moz", "webkit", "o" ]
  x = 0

  while x < vendors.length and not window.requestAnimationFrame
    window.requestAnimationFrame = window[vendors[x] + "RequestAnimationFrame"]
    window.cancelAnimationFrame = window[vendors[x] + "CancelAnimationFrame"] or window[vendors[x] + "CancelRequestAnimationFrame"]
    ++x
  unless window.requestAnimationFrame
    window.requestAnimationFrame = (callback, element) ->
      currTime = new Date().getTime()
      timeToCall = Math.max(0, 16 - (currTime - lastTime))
      id = window.setTimeout(->
        callback currTime + timeToCall
      , timeToCall)
      lastTime = currTime + timeToCall
      id
  unless window.cancelAnimationFrame
    window.cancelAnimationFrame = (id) ->
      clearTimeout id
 
 

unless Array::indexOf
  Array::indexOf = (elt) ->
    len = @length
    from = Number(arguments[1]) or 0
    from = (if (from < 0) then Math.ceil(from) else Math.floor(from))
    from += len  if from < 0
    while from < len
      return from  if from of this and this[from] is elt
      from++
    -1
    
Array::shuffle = -> @sort -> 0.5 - Math.random()

class Audio
  constructor:  (@options = {}) ->
    @sound = []
    @sound['ratchet'] = new buzz.sound("audio/ratchet" + @audioExt())
    @sound['ratchet'].load()
  
  audioExt: ->
    if buzz.isOGGSupported()
      return '.ogg'
    else 
      return '.m4a'
      
  stop: ->
    for sound in @sound
      sound.stop(true)
 
class Nums 
  randomPick: (i) -> 
    shuffled = @range[i].shuffle() 
    shuffled.shift()
    
  constructor: (@options = {}) ->
    @picks = []
    @range = []
    arr = []
    numsInfo = MG.api.getDrawInfo() 
    for draw,indx in numsInfo
      @range[indx] = draw[0].range 
  	  for i in [0..draw[0].chances-1]
  	    arr.push
  	      pickId: draw[0].pickId
  	      seqId:  i
  	  @picks[indx] = arr	      
  

     
  getList: (i) => 
    list = []  
    for i in @all 
      if @range.indexOf(i) isnt -1 and Carnival.alreadySelected(i)
      	item = i
      else
        item = '' 
      list.push item: item
    list 
        
	  
class Carnival
  className: 'carnival'
  
  active: null
  
  @selection: []
  
  @alreadySelected: (i) ->
  	Carnival.selection.indexOf(i.toString()) is -1
  	
  events:  
    'click #circle':       			'spin'
    'click div[id^="ticket"]':      'activateTicket'
    'click #numbers li':   			'selectNum'

  @activeTicket: {}
  @isFinished: 13
  @spinnable: ->
    chosen = @.activeTicket.el.find('p:not(".animated")') 
    chosen.length isnt 0 
    
  constructor: (@options = {}) -> 
    @el = $('#gameArea')
    for key, value of @options
      @[key] = value
    
    @ltIE10 = if $.browser.msie and parseInt($.browser.version, 10) < 10 then true else false
    @nums = new Nums
    @audio = new Audio
    @doneSpinning = true
    @delegateEvents @events  
    @guyEl = @el.find '#guy'  
    @spinEl = @el.find '#spin' 
    @wheelEl = @el.find '#wheel' 
    @pointerEl = @el.find '#pointer'
    @numbersEl = @el.find '#numbers li'
    @guyEl.removeClass().addClass 'animated bounceInDown' 
    @classRemover @guyEl
    #@el.addClass(@className)
    #@el.append @padEl
    #@handlePadHiding()
    #@render()
   
  activateTicket: (e) ->
    el = $(e.target)
    el = el.parent() unless el.is('div')
    if Carnival.activeTicket.el is el
      return
    
    active = el.siblings('.active')
    $(active[0]).removeClass('active') 
    el.addClass 'active'
    Carnival.activeTicket.el = el
    Carnival.activeTicket.num = el.attr('id').substr(6) 
    @displayAvailable() 
  
  selectNum: (e) =>
    selectable = Carnival.spinnable() 
    if selectable
      element = $(e.target) 
      pickedNum = element.attr('class').slice(6)
      @handlePicked(pickedNum, element)
    else
      @notSelectable()
   
  notSelectable: ->
    console.log('cant select');
      
  displayAvailable: => 
    i = Carnival.activeTicket.el.attr('id').slice(6)-1 
    listEl = @numbersEl
    wheelListEl = @wheelEl.find('li')
    $(wheelListEl).each ->
      $(this).html('')
    listEl.removeClass()
    @nums.range[i].forEach (num)-> 
      $(listEl[num-1]).addClass 'choose'+num
      $(wheelListEl[num-1]).html num  
    
  spin: -> 
    unless @doneSpinning 
    	return 
    spinnable = Carnival.spinnable()
    if spinnable
      @audio.sound['ratchet'].stop().play()
      @doneSpinning = false 
      @pointerEl.addClass 'ticker'
      spin = 0 
      pickedNum = @nums.randomPick(Carnival.activeTicket.num-1) 
      console.log(pickedNum)
      pickSpin = $(".pick" + pickedNum).data('degree');
      spinBy = -pickSpin + 714
      spinOffset = spin % 360
      startSpin = 0
      spin += spinBy  
      i=30 
      spinWheel = =>
        if(startSpin>spin)
          @rotate(spin) 
          cancelAnimationFrame frame
          @pointerEl.removeClass 'ticker'
          @doneSpinning = true 
          element = $('.choose'+pickedNum)
          @handlePicked(pickedNum, element)
          @audio.sound['ratchet'].stop() 
          return
        frame = requestAnimationFrame spinWheel
        @rotate(startSpin)
        startSpin = startSpin + i
        i -= 0.8
        if i<5
         i = 5 
    else
      @notSelectable()     
    spinWheel()
 
  handlePicked: (num, element) =>  
    element.addClass 'animated rotateOut'
    numEl = $(Carnival.activeTicket.el.find('p:not(".animated")')[0]) 
    numEl.addClass 'num'+num
    numEl.addClass 'animated flip' 
    console.log 'Finished!' unless --Carnival.isFinished  
  
  rotate: (amount) -> 
    @wheelEl.css
      transform: "rotate(" + amount + "deg)"
      "-moz-transform": "rotate(" + amount + "deg)"
      "-o-transform": "rotate(" + amount + "deg)"
      "-webkit-transform": "rotate(" + amount + "deg)"
  	
 	
  classRemover: (el) -> 
  	window.setTimeout(->
      el.removeClass()
    , 1300)	
      
  purchase: ->
    chosenPlank = null 
    options = {}
    @el.find('div[id ^= "plank"]').each ->
      plankEl = $(this)
      if plankEl.hasClass("active")
        chosenPlank = plankEl
      else 
        plankEl.removeClass().addClass('animated bounceOut') 
        
    chosenPlank.removeClass().addClass('animated tada'); 
    chosenValues = [
    	parseInt(chosenPlank.find('.first').html(),10)
    	parseInt(chosenPlank.find('.second').html(),10)
    	parseInt(chosenPlank.find('.third').html(),10)
    	parseInt(chosenPlank.find('.fourth').html(),10)
    	parseInt(chosenPlank.find('.fifth').html(),10)
    ] 
    for pick, i in @nums.picks
       options.pickId = pick.pickId
       options.seqId =  pick.seqId
       options.value =  chosenValues[i]
       @setPick(options)
        
    Carnival.selection.length = 0
    
  generate: -> 
    if @ltIE10 
      @render()
    else
      @el.find('#plank1, #plank2, #plank3, #plank4').each ->
        plankEl = $(this)
        plankEl.removeClass().addClass('animated hinge') 
      window.setTimeout (=>
        @render()
      ), 1600 
  
  setPick: (options) -> 
    res = MG.api.setPick(
      pickId: options.pickId
      seqId: options.seqId
      value: options.value)
     
    if res.returnData.complete
      if @ltIE10
         MG.api.setGameStatus MG.api.GameStatus.COMPLETE
      else 
        window.setTimeout (->
          MG.api.setGameStatus MG.api.GameStatus.COMPLETE
        ), 1200
    
    
  render: ->
    @reset()
    
    for i in [1..4]
      five = @nums.fiveRandom() 
      @el.append(@plankTempl(i, five))
       
    @el.append(@plankTempl('', '')) 
    @purchaseEl = $('<div />').attr('id', 'purchase')
    @generateEl = $('<div />').attr('id', 'generate')
    @padEl = $('<div />').attr('id', 'pad') 
    @el.append(@purchaseEl).append(@padEl).append(@generateEl)  
    
    this
  
  reset: -> 
    @el.empty()
    @active = null
    Carnival.selection.length = 0
    
  hidePurchaseEl: ->
    buyEl = @purchaseEl
    buyEl.hide()
  	
  showPurchaseEl: ->
    buyEl = @purchaseEl
    buyEl.show().addClass('animated bounceIn')
    wait = window.setTimeout(->
      buyEl.removeClass()
    , 1300)

  showPad: (e) =>  
    @active = $(e.target)
    index = @active.data 'index' 
    @padEl.html @updatedPadNumbersTxt index
    @padEl.css
      top: @active.position().top+174,
      left: @active.position().left+374
    @padEl.show()
  	
  updatedPadNumbersTxt: (idx) => 
    $('#numsTemplate').tmpl
      list: @nums.getList(idx) 
  
  selectOne: (e) => 
    selectedNum = $(e.target).html()
    @padEl.hide()
    @active.html selectedNum  
    Carnival.selection = @getSelected()
    @showPurchaseEl() if Carnival.selection.length is 5
    
  getSelected: ->
    Carnival.selection.length = 0
    @el.find('#plank a').each(->
      num = $(this).html()
      Carnival.selection.push num unless num is '?'
    )
    Carnival.selection
  
  plankTempl: (i, five) ->
    $('#plankTemplate').tmpl 
  	  plank: i
  	  a: five[0]
  	  b: five[1]
  	  c: five[2]
  	  d: five[3]
  	  e: five[4]  
  	
  activate: (e) =>
    #e.preventDefault()
    plankEl = $(e.target)
    if e.target.tagName is 'A'
      plankEl = $(e.target).parent()
    return if @selected(plankEl)
    @clearActive()
    plankEl.addClass('active animated pulse')
    if plankEl.attr('id') is 'plank'
      @hidePurchaseEl() unless Carnival.selection.length is 5
    else  
      @showPurchaseEl() 

  clearActive: ->
    $('div[id ^= "plank"]').each ->
      plankEl = $(this)
      plankEl.removeClass()  if plankEl.hasClass("active") 
    
  selected: (plankEl) ->
  	  plankEl.hasClass 'active'  

  delegateEvents: (events) ->
    for key, method of events

      unless typeof(method) is 'function'
        # Always return true from event handlers
        method = do (method) => =>
          @[method].apply(this, arguments)
          true

      match      = key.match(/^(\S+)\s*(.*)$/)
      eventName  = match[1]
      selector   = match[2] 
      if selector is ''
        @el.bind(eventName, method)
      else
        @el.on(eventName, selector, method)

@Carnival = Carnival 