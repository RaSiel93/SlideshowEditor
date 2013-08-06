class Slide
    constructor: (@id, @effect, @animation, @delay) ->
    replace: (@id, @effect, @animation, @delay) ->
    info: => alert "id: "+@id+"; effect: "+@effect+"; animation: "+@animation+"; delay: "+@delay+";"

class SlideshowEditor
    @arraySlide: []
    @currentSlideIndex: -1

    @init: =>
        Command.addSlide()
        $('#slideshow').sortable({
            start: SlideshowEditor.sortSlideStart
            stop: SlideshowEditor.sortSlideStop
        });
        $('#centerBox').droppable({
            drop: SlideshowEditor.dropInMain
        });
        $('#toolEffect>img').draggable({
            appendTo: 'body'
            helper: 'clone'
            revert: true
            revertDuration: 0
            zIndex: 200
            containment: 'body'
        })

#!
    @addSlide: =>
        if SlideshowEditor.getCountSlide() == 0
            SlideshowEditor.arraySlide.push new Slide('32532','','blind','1000')    
            $("div#slideshow").append("<div id=\"slide\"><div><div></div><img></div></div>")
        else
            SlideshowEditor.arraySlide.splice SlideshowEditor.currentSlideIndex + 1, 0, new Slide('32532','','blind','1000')
            $("div#slideshow>div").eq(SlideshowEditor.currentSlideIndex).after("<div id=\"slide\"><div><div></div><img></div></div>")       

    @generateSlide: =>
        # slideDiv = "<div id=\"slide\"><div id=\""+slide.id+"\" effect=\""+slide.effect+"\" animation=\""+slide.animation+"\" delay=\""+slide.delay+"\"><div><div></div><img></div></div>"
        slideDiv = "<div id=\"slide\"><div><div></div><img></div></div>"
        if SlideshowEditor.currentSlideIndex == -1
            $("div#slideshow").append(slideDiv)
        else
            $("div#slideshow>div").eq(SlideshowEditor.currentSlideIndex).after(slideDiv)            

    @removeSlide: =>
        if SlideshowEditor.getCountSlide() > 1
            $("#slideshow>div").eq(SlideshowEditor.currentSlideIndex).detach()
            SlideshowEditor.arraySlide.splice SlideshowEditor.currentSlideIndex, 1

    @setIndexSlide: (index) =>
        if index >= 0 and index < SlideshowEditor.getCountSlide()
            SlideshowEditor.currentSlideIndex = index

#!
    @deselectSlide: =>
        $("#slideshow>div").removeAttr('class')
    @selectSlide: =>
        $("#slideshow>div").eq(SlideshowEditor.currentSlideIndex).attr('class','selectedSlide')
        SlideshowEditor.updateToolsPanel()
    @recurrentSlide: (event) => 
        SlideshowEditor.currentSlideIndex = $("#slideshow>div>div>div").index($(event.target))
        
    @correctSlideIndex: =>
        if SlideshowEditor.currentSlideIndex == SlideshowEditor.getCountSlide()
            SlideshowEditor.currentSlideIndex = SlideshowEditor.getCountSlide() - 1
        else if SlideshowEditor.currentSlideIndex == -2 
            SlideshowEditor.currentSlideIndex = -1
    @correctSlideshowIndex: =>
        if SlideshowEditor.currentSlideIndex == SlideshowEditor.getCountSlide()
            SlideshowEditor.currentSlideIndex = 0
        else if SlideshowEditor.currentSlideIndex == -1
            SlideshowEditor.currentSlideIndex = SlideshowEditor.getCountSlide() 

#!
    @updateMainSlide: =>
        if SlideshowEditor.getCountSlide() > 0
            sl = SlideshowEditor.getCurrentSlide()
            $("#mainSlide>div").attr('id', sl.id).attr('effect', sl.effect).attr('animation', sl.animation).attr('delay', sl.delay)
            $("#mainSlide>img").attr('src', Oboobs.idToSrc(sl.id))
            SlideshowEditor.alignSlideFirst()

#!
    @replaceCurrentSlide: (slide) =>
        currentSlide = SlideshowEditor.getCurrentSlide()
        currentSlide.id = slide.attr('id')
#!
    @updateCurrentSlide: =>
        if SlideshowEditor.getCountSlide() > 0
            slide = SlideshowEditor.getCurrentSlide()
            $('#slideshow>div>div>img').eq(SlideshowEditor.currentSlideIndex).attr('src', Oboobs.idToSrc(slide.id))
            div = $('#slideshow>div>div>div').eq(SlideshowEditor.currentSlideIndex)
            div.attr("id", slide.id)
            div.attr("effect", slide.effect)
            div.attr("animation", slide.animation)
            div.attr("delay", slide.delay)

    @updateToolsPanel: =>
        slide = SlideshowEditor.getCurrentSlide()
        $('#animation').val(slide.animation)
        $('#delay').val(slide.delay)
#!      
    @bindSlide: =>
        $('#slideshow>div>div').eq(SlideshowEditor.currentSlideIndex).on( "click",
            (event) ->
                Command.selectSlide(event)
            );

    @setEffect: (effect) =>
        SlideshowEditor.arraySlide[SlideshowEditor.currentSlideIndex].effect = effect

    @sortSlideStart: (event, ui) =>
        SlideshowEditor.deselectSlide()
        SlideshowEditor.currentSlideIndex = $("#slideshow>div").index($item = $(ui.item[0]))
        SlideshowEditor.selectSlide()
        SlideshowEditor.updateMainSlide()
    @sortSlideStop: (event, ui) =>
        SlideshowEditor.shiftSlide($("#slideshow>div").index($item = $(ui.item[0])))
    @shiftSlide: (index) =>
        slide = SlideshowEditor.arraySlide.splice SlideshowEditor.currentSlideIndex, 1
        SlideshowEditor.arraySlide.splice index, 0, slide[0]
        SlideshowEditor.currentSlideIndex = index

    @dropInMain: (event, ui) =>
        $div = $(ui.draggable)
        if $div.attr('effect') != undefined
            Command.setEffect($div.attr('effect'))
        else
            Command.selectSlideFromOboobs($div)

    @getCurrentSlide: =>
        SlideshowEditor.arraySlide[SlideshowEditor.currentSlideIndex]

    @getCountSlide: =>
        SlideshowEditor.arraySlide.length

    @clearSlide: =>
        $('#slideshow').empty()

    @regenerateSlide: =>
        for slide in SlideshowEditor.arraySlide
            SlideshowEditor.generateSlide()
            SlideshowEditor.currentSlideIndex++
            SlideshowEditor.updateCurrentSlide()
            SlideshowEditor.bindSlide()

    @alignSlideFirst: =>
        slide = $('#mainSlide img:first')
        width = slide.width()
        height = slide.height()
        containerWidth = $('#mainSlide').width()
        leftIndent = (containerWidth - width) / 2
        slide.attr("style", "left: "+leftIndent+"px")
        $("#mainSlide > div").attr("style", "left: "+leftIndent+"px").width(width).height(height)

    @alignSlideLast: =>
        slide = $('#mainSlide img:last')
        width = slide.width()
        height = slide.height()
        containerWidth = $('#mainSlide').width()
        leftIndent = (containerWidth - width) / 2
        slide.attr("style", "left: "+leftIndent+"px")
        $("#mainSlide > div").attr("style", "left: "+leftIndent+"px").width(width).height(height)


class Oboobs
    @getPhotosIds: =>
        xmlHttp = null
        xmlHttp = new XMLHttpRequest()
        xmlHttp.open("GET", "http://api.oboobs.ru/noise/30/'", false )
        xmlHttp.send( null )
        photosJsonInfo = eval ( "(" + xmlHttp.responseText + ")" )
        (photo.id for photo in photosJsonInfo)

    @idToSrc:(id) =>
        id = String(id)
        id = "0" + id while id.length < 5
        'http://media.oboobs.ru/noise_preview/'+id+'.jpg'

    @getPhotos: =>
        arrayIds = Oboobs.getPhotosIds()
        for id in arrayIds                                                      
            $('#pictures').append('<img id="'+id+'" src="'+Oboobs.idToSrc(id)+'"/>')
        Oboobs.bindPictures()

    @bindPictures: =>
        $('#pictures>img').on( "click", (event) ->
            Command.selectSlideFromOboobs($(event.target))
        );
        $('#pictures>img').draggable({
            appendTo: 'body'
            helper: 'clone'
            revert: true
            revertDuration: 0
            zIndex: 1000
            containment: 'body'
            })

class Command
    @addSlide: =>
        SlideshowEditor.deselectSlide()
        SlideshowEditor.addSlide()
        SlideshowEditor.currentSlideIndex++
        SlideshowEditor.updateCurrentSlide()
        SlideshowEditor.updateMainSlide()
        SlideshowEditor.selectSlide()
        SlideshowEditor.bindSlide()

    @removeSlide: =>
        SlideshowEditor.deselectSlide()
        SlideshowEditor.removeSlide()
        SlideshowEditor.correctSlideIndex()
        SlideshowEditor.updateMainSlide()
        SlideshowEditor.selectSlide()

    @selectSlideFromOboobs: (slide) =>
        SlideshowEditor.replaceCurrentSlide(slide) 
        SlideshowEditor.updateCurrentSlide()
        SlideshowEditor.updateMainSlide()

    @selectSlide: (event) =>
        SlideshowEditor.deselectSlide()
        SlideshowEditor.recurrentSlide(event)
        SlideshowEditor.updateMainSlide()
        SlideshowEditor.selectSlide()

    @previousSlide: =>
        SlideshowEditor.deselectSlide()
        SlideshowEditor.setIndexSlide(SlideshowEditor.currentSlideIndex - 1)
        SlideshowEditor.updateCurrentSlide()
        SlideshowEditor.updateMainSlide()
        SlideshowEditor.selectSlide()

    @nextSlide: =>
        SlideshowEditor.deselectSlide()
        SlideshowEditor.setIndexSlide(SlideshowEditor.currentSlideIndex + 1)
        SlideshowEditor.updateCurrentSlide()
        SlideshowEditor.updateMainSlide()
        SlideshowEditor.selectSlide()

    @setEffect: (effect) =>
        SlideshowEditor.setEffect(effect)
        SlideshowEditor.updateCurrentSlide()
        SlideshowEditor.updateMainSlide()   

    @saveSlideshow: =>
        fileName = prompt('Введите название слайдшоу')
        if fileName != null
            localStorage[fileName] = JSON.stringify(SlideshowEditor.arraySlide);

    @loadSlideshowDialog: =>
        dialog = $("#dialog-modal")
        dialog.empty()
        for key in Object.keys(localStorage)
            button = $('<button>')
            button.text(key)
            button.on("click", (event)->
                Command.loadSlideshow($(this).text())
                dialog.dialog("close")
            )
            $("#dialog-modal").append(button)    
        
        $( "#dialog-modal" ).dialog({
            title: "Выберите слайдшоу"
            modal: true
        });
    
    @loadSlideshow: (key) =>
        SlideshowEditor.arraySlide = JSON.parse(localStorage[key]);
        SlideshowEditor.deselectSlide()
        SlideshowEditor.clearSlide()
        SlideshowEditor.currentSlideIndex = -1
        SlideshowEditor.regenerateSlide()
        SlideshowEditor.currentSlideIndex = 0
        SlideshowEditor.updateCurrentSlide()
        SlideshowEditor.updateMainSlide()   
        SlideshowEditor.selectSlide()

class Presentation
    @currentTimeoutId: 0

    @showSlide: (slide) =>
        $newSlide = $("<img/>")
        $newSlide.attr({
            src: Oboobs.idToSrc(slide.id)
        })
        $("#mainSlide").append($newSlide)
        $("#mainSlide>div").attr('effect', slide.effect)

    @hideLastSlide: =>
        $("#mainSlide img:last").hide()

    @startTransitionEffect: =>
        $("#mainSlide img:first").hide('blind', Presentation.removeFirstSlide)
        $("#mainSlide img:last").show('blind')

    @removeFirstSlide: =>
        $("#mainSlide img:first").remove()

    @slide: =>
        if SlideshowEditor.getCountSlide() == SlideshowEditor.currentSlideIndex + 1
            return
        slide = SlideshowEditor.getCurrentSlide()
        SlideshowEditor.deselectSlide()
        SlideshowEditor.currentSlideIndex++
        SlideshowEditor.selectSlide()
        currentSlide = SlideshowEditor.getCurrentSlide()
        Presentation.showSlide(currentSlide)
        SlideshowEditor.alignSlideLast()
        $("#mainSlide>div").width($("#mainSlide img:last").width())
        $("#mainSlide img:last").hide()
        $("#mainSlide img:first").hide(slide.animation, Presentation.removeFirstSlide)
        $("#mainSlide img:last").show(slide.animation)
        Presentation.currentTimeoutId = setTimeout(Presentation.slide, currentSlide.delay)

    @startPresentation: =>
        currentSlide = SlideshowEditor.getCurrentSlide()
        Presentation.currentTimeoutId = setTimeout(Presentation.slide, currentSlide.delay)

    @stopPresentation: =>
        clearTimeout(Presentation.currentTimeoutId)

$ ->
    SlideshowEditor.init()
    
    Oboobs.getPhotos()
    $('#loadImage').on( "click", 
        ()->
            Oboobs.getPhotos()
    );
    $('#bSaveSlideshow').on( "click", 
        ()->
            Command.saveSlideshow()
    );
    $('#bLoadSlideshow').on( "click", 
        ()->
            Command.loadSlideshowDialog()

    );
    $('#bAddSlide').on( "click", 
        ()->
            Command.addSlide()
    );
    $('#bRemoveSlide').on( "click", 
        ()->
            Command.removeSlide()
    );
    
    $("#bPrevious").on( "click",
        ()->
            Command.previousSlide()
    );
    
    $("#bNext").on( "click",
        ()->
            Command.nextSlide()
    );
    $('img[src="images/eBlackAndWhite.png"]').on( "click",
        ()->
            Command.setEffect('blackAndWhite')
    );
    $('img[src="images/eSepia.png"]').on( "click",
        ()->
            Command.setEffect('sepia')
    );
    $('img[src="images/eVignette.png"]').on( "click",
        ()->
            Command.setEffect('vignette')
    );
    $('img[src="images/remove.png"]').on( "click",
        ()->
            Command.setEffect('')   
    );
    $('#animation').on( "click",
        ()->
            SlideshowEditor.getCurrentSlide().animation = $("#animation option:selected").attr('value') 
    );

    $('#delay').on( "click", 
        ()->
            SlideshowEditor.getCurrentSlide().delay = $("#delay option:selected").attr('value')
    );
    $('#bRunSlideshow').on( "click",
        ()->
            Presentation.startPresentation()
    );
    $('#bStopSlideshow').on( "click",
        ()->
            Presentation.stopPresentation()
    );