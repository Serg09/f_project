describe 'paymentController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $httpBackend = null
  $controller = null
  hostedFields = null
  $scope = null
  cs = null
  ORDER_ID = 101
  PAYMENT_TOKEN = 'abc123'
  NONCE = '321bca'
  PAYMENT_ID = '201'
  beforeEach ->
    inject (_$rootScope_, _$controller_, _$httpBackend_, _cs_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $scope = $rootScope.$new()
      $controller = _$controller_
      cs = _cs_
    $rootScope.order =
      id: ORDER_ID
      shipping_address:
        recipient: 'John Doe'
    hostedFields =
      tokenize: (callback) ->
        callback(null,
          nonce: NONCE)
    spyOn(hostedFields, 'tokenize').and.callThrough()

    csMethods = ['submitOrder', 'createPayment', 'updateOrder', 'getPaymentToken']
    _.each csMethods, (m)->
      spyOn(cs, m).and.callThrough()
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
        $httpBackend.whenPOST('http://localhost:3030/api/v1/orders/' + ORDER_ID + '/payments').respond ->
          [201,
            id: PAYMENT_ID
          ]
        $httpBackend.whenPATCH('http://localhost:3030/api/v1/orders/' + ORDER_ID + '/submit').respond ->
          [200,
            id: ORDER_ID
            shipping_address:
              recipient: 'John Doe'
          ]
        controller = $controller 'paymentController',
          $scope: $scope
          cs: cs
        $httpBackend.flush()
        $scope.submitPayment()
        $httpBackend.flush()

      it 'indicates the submission is completed', ->
        expect($rootScope.submission.isComplete()).toBe true

      it 'tokenizes the payment', ->
        expect(hostedFields.tokenize).toHaveBeenCalled()

      it 'updates the order', ->
        expect(cs.updateOrder).toHaveBeenCalled()

      it 'creates the payment', ->
        expect(cs.createPayment).toHaveBeenCalled()

      it 'submits the order', ->
        expect(cs.submitOrder).toHaveBeenCalled()

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

