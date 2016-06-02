namespace :threedm do
  desc 'Insert an initial set of books and identifiers'
  task books: :environment do
    client = Client.find_or_create_by(name: '3DM', abbreviation: '3dm')
    data = [
      {
        title: 'Building a Discipling Culture (2nd Edition) Bundle of 10',
        isbn: '0000000000000',
        identifier: 'BDC-10'
      },
      {
        title: "Building a Discipling Culture (2nd Edition)",
        isbn: '0000000000001',
        identifier: 'BDC'
      },
      {
        title: "Five Fold Ministry Survey",
        isbn: '0000000000002',
        identifier: 'FFMS'
      },
      {
        title: "HBUNS Huddle Leader Guide",
        isbn: '0000000000003',
        identifier: 'HLG'
      },
      {
        title: "Huddle Bundle - Standard",
        isbn: '0000000000004',
        identifier: 'HBUNS'
      },
      {
        title: "Huddle Participant Guide",
        isbn: '0000000000005',
        identifier: 'HPG'
      },
      {
        title: "Leading Kingdom Movements",
        isbn: '0000000000006',
        identifier: 'LKM'
      },
      {
        title: "Covenant & Kingdom - The DNA of the Bible",
        isbn: '0000000000007',
        identifier: 'CKP'
      },
      {
        title: "Learning Community Bundle",
        isbn: '0000000000008',
        identifier: 'LCBUN'
      },
      {
        title: "Leading Missional Communities",
        isbn: '0000000000009',
        identifier: 'LMC'
      },
      {
        title: "Multiplying Missional Leaders",
        isbn: '0000000000010',
        identifier: 'MML'
      }
    ]
    defaults = {
      format: 'hardcover'
    }
    data.each do |d|
      id_data = {client: client, code: d[:identifier]}
      book_data = defaults.merge(d.keep(:title, :isbn, :format))
      book = Book.create! book_data
      book.identifiers.create! id_data
    end
  end
end

class Hash
  def keep(*keys)
    keep_if do |key, value|
      keys.include?(key)
    end
  end
end
