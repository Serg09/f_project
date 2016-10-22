describe 'purchaseTileController', ->
  beforeEach module('crowdscribed')

  beforeEach ->
    module (_$provide_) ->
      _$provide_.value 'cs',
        getProduct: (sku) ->
          console.log "get product " + sku
          price: 19.99

  rootScope = null
  scope = {}
  controller = null
  beforeEach(inject((_$rootScope_) ->
      console.log _$rootScope_
  ))

  describe 'sku', ->
    it 'looks up the product and sets the price', ->
      console.log 'scope - inside spec'
      console.log scope
      expect(true).toEqual false

      #scope.sku = '123456'
      ##scope.$digest
      #expect(scope.price).toEqual 19.99
