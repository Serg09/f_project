class LsiBatchWriter
  SHIP_METHODS = {
    US:
    {
      BTCONS: 'Baker & Taylor Consolidated shipment',
      UPS3DAS: 'UPS 3 DAY SELECT COMMERCIAL',
      UPS3DASR: 'UPS 3 DAY RESIDENTIAL',
      UPSGSCNA: 'UPS GROUND COMMERCIAL',
      UPSGSRNA: 'UPS GROUND RESIDENTIAL',
      UPSNDA: 'UPS NEXT DAY AIR',
      UPSNDAR: 'UPS NEXT DAY RESIDENTIAL',
      UPSSDA: 'UPS 2ND DAY AIR',
      UPSSDAR: 'UPS 2ND DAY RESIDENTIAL',
      USPS1P: 'USPS PRIORITY (Military APO or FPO)',
      USPSBP: 'USPS MEDIA',
      USPSBPAH: 'USPS AK/HI',
      CANADIAN: 'SHIP METHODS'
    },
    CA:
    {
      PUROGND: 'PURO GROUND(Canada\'s USPS)',
      DHLWPX: 'UPS CANADA EXPRESS SAVER',
      UPSCG: 'UPS CANADA GROUND',
      UPSCGR: 'UPS CANADA GROUND RESIDENTIAL',
      UPSCWEX: 'UPS CANADA EXPRESS',
      UPSCWWX: 'UPS CANADA EXPEDITE'
    },
    INTL:
    {
      DHLMAG: 'IMEX - REST OF WORLD PB',
      DHLWPX: 'DHL - WORLD WIDE PRIORITY',
      IMEXROW: 'IMEX - REST OF WORLD(UPS Mail Innovations)',
      UPSNDS: 'UPS NEXT DAY SAVER COMMERCIAL',
      UPSNDSR: 'UPS NEXT DAY SAVER RES',
      UPSWEXS: 'UPS WW SAVER',
      UPSWWX: 'UPS WW EXPEDITED'
    }
  }

  def initialize(batch)
    @batch = batch
  end

  # Right-pads the value up to the specified
  # length with blank spaces, or truncates the
  # values to the specified length if the
  # values is longer
  def alpha_of_length(value, length)
    result = value.upcase
    return result if result.length == length
    if result.length < length
      "#{result}#{" " * (length - result.length)}"
    else
      result.slice(0, length)
    end
  end

  # Left-pads the value up to the specified
  # length with zeros. Raises an exception
  # if the value is longer than the specified
  # length
  def number_of_length(value, length)
    result = value.to_s
    if result.length > length
      raise ArgumentError.new "The value #{value} is longer than the specified length #{length}"
    end

    "#{"0" * (length - result.length)}#{result}"
  end

  def write(io)
    raise 'Batch has no orders' unless @batch.orders.any?

    write_batch_header(io)
    @batch.orders.each{|o| write_order(io, o)}
  end

  private

  def purchase_order_number(order)
    alpha_of_length('%09d' % order.id, 15)
  end

  def write_batch_header(io)
    io.print "$$HDR"
    io.print number_of_length(LSI_CLIENT_ID, 6)
    io.print number_of_length(@batch.id, 10)
    io.print @batch.created_at.strftime('%Y%m%d')
    io.print @batch.created_at.strftime('%H%M%S')
    io.puts ''
  end

  def write_order(io, order)
    write_order_header(io, order)
    write_order_address(io, order)
    write_order_comments(io, order)
    order.items.each{|i| write_order_item(io, i)}
  end

  def write_order_header(io, order)
    io.print 'H1'     # record type
    io.print purchase_order_number(order) # Purchase order number
    io.print order.order_date.strftime('%Y%m%d')    # Order date
    io.print ' ' * 30 # Ref # TODO find out what this is
    io.print 'C'      # Order type
    io.print ' '      # Internal use only
    io.print ' ' * 25 # Secondary purchase order number
    io.print ' ' * 10 # Internal use only
    io.print alpha_of_length('USPS1P', 8) # LSI ship code TODO Is this in the order already?
    io.print ' '      # Internal use only
    io.print ' '      # Blank Fill
    io.print ' ' * 30 # Terms of use, default 'Net 60 Days'
    io.print '0' * 57 # Internal use only
    io.print ' ' * 6  # Internal use only
    io.print ' ' * 30 # Internal use only
    io.print ' ' * 2  # Back order qualifier 'B' = Backorder
    io.print ' ' * 2  # Back order Y or N
    io.print ' ' * 8  # Cancel back order date TODO What if its not back ordered?
    io.print 'USD'    # Currency code
    io.print ' ' * 2  # Rush indicator ('RO')
    io.print ' ' * 2  # consolidation flag (Y or N)
    io.puts ''
  end

  def write_order_address(io, order)
    io.print 'H2'     # record type
    io.print purchase_order_number(order) # Purchase order number
    io.print 'ST'     # Address type, ST = Ship to, RT = Return to, CS = Consolidator
    io.print ' ' * 25 # Internal use only
    io.print alpha_of_length(order.customer_name, 35)
    io.print ' ' * 15 # Internal use only
    io.print alpha_of_length(order.address_1, 35) # address line 1
    io.print ' ' * 15 # Internal use only
    io.print alpha_of_length(order.address_2, 35) # address line 2
    io.print ' ' * 15 # Internal use only
    io.print ' ' * 35 # address line 3
    io.print ' ' * 65 # Internal use only
    io.print alpha_of_length(order.city, 30)        # city
    io.print alpha_of_length(order.state, 2)        # state
    io.print alpha_of_length(order.postal_code, 9)  # postal code
    io.print alpha_of_length(order.country_code, 3) # country code
    io.print alpha_of_length(order.telephone.gsub(/\D/, ''), 15)   # phone number
    io.print ' ' * 5  # Internal use only
    io.puts ''
  end

  def write_order_comments(io, order)
    # may implement this later if needed
  end

  def write_order_item(io, item)
    io.print 'D1'     # record type
    io.print purchase_order_number(item.order)       # purchase order number
    io.print ' ' * 25 # Customer PO number
    io.print number_of_length(item.line_item_no, 5)  # line item number
    io.print ' ' * 3  # Internal use only
    io.print ' ' * 8  # Internal use only

    isbn = item.sku.gsub(/[^0-9a-z]/i, '').upcase
    if isbn.length <= 10                             # Title (ISBN) 10-digit
      io.print alpha_of_length(isbn, 10) 
    else
      io.print ' ' * 10
    end

    io.print ' ' * 78 # Internal use only
    io.print number_of_length(item.quantity, 7)      # quantity
    io.print ' ' * 21 # Internal use only
    io.print ' '      # Internal use only
    io.print ' ' * 9  # price
    io.print ' '      # Internal use only
    io.print ' ' * 5  # Discount percentage
    io.print ' ' * 7  # Internal use only
    io.print number_of_length((item.freight_charge * 100).to_i, 9)  # freight amount
    io.print ' '      # Internal use only
    io.print number_of_length((item.tax * 100).to_i, 9)             # tax amount
    io.print ' '      # Internal use only
    io.print ' ' * 9  # Handling amount

    if isbn.length == 13  # Title ISBN 13-digit
      io.print isbn
    else
      io.print ' ' * 13
    end

    io.print ' ' * 7  # Internal use only

    if isbn.length == 14  # Title prefixed ISGN 13 / VTIN
      io.print isbn
    else
      io.print ' ' * 14
    end

    io.print ' ' * 6  # Internal use only
    io.puts ''
  end
end
