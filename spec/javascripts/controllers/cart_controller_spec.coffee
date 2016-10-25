describe 'cartController', ->
  beforeEach module('crowdscribed')

  $rootScope = null
  $scope = null
  controller = null
  $httpBackend = null
  $cookies = null
  $location = null
  beforeEach ->
    inject (_$rootScope_, _$cookies, _$location_, _$controller_, _$httpBackend_) ->
      $httpBackend = _$httpBackend_
      $rootScope = _$rootScope_
      $scope = $rootScope.$new()
      $cookies = _$cookies_
      $location = _$location_
      controller = _$controller_ 'purchaseTileController',
        $scope: $scope

  describe 'when an order ID is present in the cookies', ->
    it 'sets the rootScope.order to the specified order'
  describe 'when an order ID is not present in the cookies', ->
    it 'creates a new order and sets rootScope.order'
  describe 'when a SKU is present on the query string', ->
    describe 'and not present in the order', ->
      it 'adds the specified item to the order'
    describe 'and present in the order', ->
      it 'does not add anything to the order'
  describe 'always', ->
    it 'sets the rootScope.orderTotal value'
