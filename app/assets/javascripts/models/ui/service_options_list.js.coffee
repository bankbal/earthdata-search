ns = @edsc.models.ui

ns.ServiceOptionsList = do (ko, $=jQuery) ->
  class ServiceOptionsList
    constructor: (@accountForm, @project) ->
      @activeIndex = ko.observable(0)
      @showGranules = ko.observable(false)
      @needsContactInfo = ko.computed =>
        for collection in @project.accessCollections()
          for m in collection.serviceOptions.accessMethod()
            method = m.method()
            return true if method? && method != 'Download'
        false
      @isLastOption = ko.computed =>
        collections = @project.accessCollections()
        @activeIndex() == collections.length - 1 && !@needsContactInfo()

    showNext: =>
      @_moveActiveIndex(@activeIndex() + 1)

    showPrevious: =>
      @_moveActiveIndex(@activeIndex() - 1)

    _moveActiveIndex: (newIndex) =>
      if @showGranules()
        @_currentCollection().notifyRenderers('endAccessPreview')
      @activeIndex(newIndex)
      if @showGranules()
        @_currentCollection().notifyRenderers('startAccessPreview')

    submitRequest: =>
      $('.access-submit').prop('disabled', true)
      if @needsContactInfo() && @accountForm.isEditingNotificationPreference()
        @accountForm.saveAccountEdit =>
          @downloadProject()
        # re-enable button if saveAccountEdit fails
        $('.access-submit').prop('disabled', false)
      else
        @downloadProject()

    showGranuleList: =>
      @showGranules(true)
      @_currentCollection().notifyRenderers('startAccessPreview')

    hideGranuleList: =>
      @_currentCollection().notifyRenderers('endAccessPreview')
      @showGranules(false)

    scrolled: (data, event) =>
      elem = event.target
      if (elem.scrollTop > (elem.scrollHeight - elem.offsetHeight - 40))
        collection = @project.accessCollections()[@activeIndex()].collection
        collection.granuleDatasource().data().loadNextPage()

    downloadProject: ->
      $project = $('#data-access-project')

      $project.val(JSON.stringify(@project.serialize()))
      $('#data-access').submit()

    _currentCollection: ->
      @project.accessCollections()[@activeIndex()].collection


  exports = ServiceOptionsList
