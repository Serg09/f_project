describe 'paymentController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $httpBackend = null
  $controller = null
  beforeEach ->
    inject (_$rootScope_, _$controller_, _$httpBackend_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $controller = _$controller_
    window.braintree =
      client:
        create: ->

  it 'creates a payment token', ->
    $httpBackend.expectGET('http://localhost:3030/api/v1/payments/token').respond (method, url) ->
      [200, 'abc123']
    $controller 'paymentController',
      $scope: {}
    $httpBackend.flush()
    expect(1).toEqual 1

  it 'sets up the braintree form'

  describe 'on submit', ->
    it 'displays a progress widget'
    it 'tokenizes the payment'

    describe 'on successful tokenization', ->
      it 'updates the order'

      describe 'on successful order update', ->
        it 'creates the payment'

        describe 'on successful payment creation', ->
          it 'submits the order'

          describe 'on successful order submission', ->
            it 'hides the progress widget'
            it 'renders a confirmation number'

          describe 'on failure to submit the order', ->
            it 'does not render a confirmation number'
            it 'renders an error message'
            it 'hides the progress widget'

        describe 'on failure to create a payment', ->
          it 'does not submit the order'
          it 'renders an error message'

      describe 'on failure to update the order', ->
        it 'does not create the payment'
        it 'renders an error message'

    describe 'on unsuccessful tokenization', ->
      it 'does not update the order'
      it 'renders an error message'

