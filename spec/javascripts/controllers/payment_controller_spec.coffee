describe 'paymentController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $httpBackend = null
  $controller = null
  hostedFields = null
  $scope = null
  beforeEach ->
    inject (_$rootScope_, _$controller_, _$httpBackend_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $scope = $rootScope.$new()
      $controller = _$controller_
    hostedFields = jasmine.createSpyObj('hostedFields', ['tokenize'])
    window.braintree =
      client:
        create: (token, callback)->
          callback null, {}
      hostedFields:
        create: (settings, callback)->
          callback null, hostedFields

  it 'creates a payment token', ->
    $httpBackend.expectGET('http://localhost:3030/api/v1/payments/token').respond (method, url) ->
      [200, 'abc123']
    $controller 'paymentController',
      $scope: $scope
    $httpBackend.flush()
    expect(1).toEqual 1

  it 'sets up the braintree form', ->
    $httpBackend.whenGET('http://localhost:3030/api/v1/payments/token').respond (method, url) ->
      [200, 'abc123']
    spyOn(braintree.client, 'create')
    $controller 'paymentController',
      $scope: $scope
    $httpBackend.flush()
    expect(braintree.client.create).toHaveBeenCalled()


  describe 'on submit', ->
    controller = null
    beforeEach ->
      $httpBackend.whenGET('http://localhost:3030/api/v1/payments/token').respond (method, url) ->
        [200, 'abc123']
      controller = $controller 'paymentController',
        $scope: $scope
      $httpBackend.flush()
      $scope.submitPayment()

    it 'displays a progress widget'

    it 'tokenizes the payment', ->
      expect(hostedFields.tokenize).toHaveBeenCalled()

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

