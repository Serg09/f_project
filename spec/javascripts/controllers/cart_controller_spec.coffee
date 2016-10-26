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
    beforeEach ->
      spyOn($cookies, 'get').and.returnValue '101'
      spyOn($location, 'search').and.returnValue
        sku: '123456'
    describe 'and not present in the order', ->
      beforeEach ->
        $httpBackend.whenGET('http://localhost:3030/api/v1/orders/101').respond ->
          [200,
            id: 101
          ]
        $httpBackend.whenPOST('http://localhost:3030/api/v1/orders/101/items').respond ->
          [200,
            sku: '123456'
            description: 'Deluxe Widget'
            unit_price: 19.99
            quantity: 1
            extended_price: 19.99
          ]
        controller = $controller 'cartController',
          $scope: $scope
          $cookies: $cookies
          $location: $location
      it 'adds the specified item to the order', ->
        $httpBackend.flush()
        expect($rootScope.order.items.length).toEqual 1
        if $rootScope.order.items.length == 1
          item = $rootScope.order.items[0]
          expect(item.sku).toEqual '123456'
          expect(item.description).toEqual 'Deluxe Widget'
          expect(item.unit_price).toEqual 19.99
          expect(item.quantity).toEqual 1
          expect(item.extended_price).toEqual 19.99

    describe 'and present in the order', ->
      beforeEach ->
        $httpBackend.whenGET('http://localhost:3030/api/v1/orders/101').respond ->
          [200,
            id: 101
            items: [
              sku: '123456'
              description: 'Deluxe Widget'
              unit_price: 14.99
              quantity: 2
              extended_price: 29.98
            ]
          ]
        controller = $controller 'cartController',
          $scope: $scope
          $cookies: $cookies
          $location: $location

      it 'does not add anything to the order', ->
        $httpBackend.flush()
        expect($rootScope.order.items.length).toEqual 1
        item = $rootScope.order.items[0]
        expect(item.sku).toEqual '123456'
        expect(item.description).toEqual 'Deluxe Widget'
        expect(item.unit_price).toEqual 14.99
        expect(item.quantity).toEqual 2
        expect(item.extended_price).toEqual 29.98

  describe 'always', ->
    it 'sets the rootScope.orderTotal value'
