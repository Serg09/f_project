describe 'cartController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $scope = null
  controller = null
  $httpBackend = null
  $cookies = null
  $location = null
  $controller = null
  beforeEach ->
    inject (_$rootScope_, _$controller_, _$httpBackend_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $scope = $rootScope.$new()
      $controller = _$controller_
      $cookies =
        get: ->
        put: ->
      $location =
        search: ->
          {}

  describe 'when an order ID is present in the cookies', ->
    beforeEach ->
      spyOn($cookies, 'get').and.returnValue('123')
      controller = $controller 'cartController',
        $scope: $scope
        $cookies: $cookies
        $location: $location

      $httpBackend.whenGET('http://localhost:3030/api/v1/orders/123').respond ->
        return [200, {id: 123}]

    it 'sets the rootScope.order to the specified order', ->
      $httpBackend.flush()
      expect($rootScope.order).toBeDefined()
      expect($rootScope.order.id).toEqual(123)

  describe 'when an order ID is not present in the cookies', ->
    beforeEach ->
      controller = $controller 'cartController',
        $scope: $scope
        $cookies: $cookies
        $location: $location

      $httpBackend.whenPOST('http://localhost:3030/api/v1/orders').respond ->
        return [201, {id: 321}]

    it 'creates a new order and sets rootScope.order', ->
      $httpBackend.flush()
      expect($rootScope.order).toBeDefined()
      expect($rootScope.order.id).toEqual(321)

  describe 'when a SKU is present on the query string', ->
    describe 'and not present in the order', ->
      it 'adds the specified item to the order'
    describe 'and present in the order', ->
      it 'does not add anything to the order'
  describe 'always', ->
    it 'sets the rootScope.orderTotal value'
