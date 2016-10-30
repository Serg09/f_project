describe 'paymentController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $httpBackend = null
  $controller = null
  hostedFields = null
  $scope = null
  ORDER_ID = 101
  PAYMENT_TOKEN = 'abc123'
  beforeEach ->
    inject (_$rootScope_, _$controller_, _$httpBackend_, _$q_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $scope = $rootScope.$new()
      $controller = _$controller_
    $rootScope.order =
      id: ORDER_ID
      shipping_address:
        recipient: 'John Doe'
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
      [200, {token: PAYMENT_TOKEN}]
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
    describe 'on success', ->
      controller = null
      beforeEach ->
        $httpBackend.whenGET('http://localhost:3030/api/v1/payments/token').respond (method, url) ->
          [200, 'abc123']
        $httpBackend.whenPATCH('http://localhost:3030/api/v1/orders/' + ORDER_ID).respond ->
          [200,
            id: ORDER_ID
            shipping_address:
              recipient: 'John Doe'
          ]
        controller = $controller 'paymentController',
          $scope: $scope
        $httpBackend.flush()
        $scope.submitPayment()

      it 'indicates the submission is being processed', ->
        expect($rootScope.submission.isInProgress()).toBe true

      it 'tokenizes the payment', ->
        expect(hostedFields.tokenize).toHaveBeenCalled()

      it 'updates the order'

      it 'creates the payment'

      it 'submits the order'

      it 'hides the progress widget'
      it 'renders a confirmation number'

    describe 'on failure to submit the order', ->
      it 'renders an error message'
      it 'indicates submission failure'

    describe 'on failure to create a payment', ->
      it 'renders an error message'
      it 'indicates submission failure'

    describe 'on failure to update the order', ->
      it 'renders an error message'
      it 'indicates submission failure'

    describe 'on unsuccessful tokenization', ->
      it 'renders an error message'
      it 'indicates submission failure'

