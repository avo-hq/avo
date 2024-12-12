require "ostruct"

class Avo::Resources::Movie < Avo::Resources::ArrayResource
  # self.includes = []
  # self.attachments = []
  # self.search = {
  #   query: -> { query.ransack(id_eq: params[:q], m: "or").result(distinct: false) }
  # }

  # TODO: make this automatic for array resources
  self.pagination = {
    type: :array
  }

  def itemss
    [
      {
        id: 1,
        name: 'The Shawshank Redemption',
        release_date: '1994-09-23'
      },
      {
        id: 2,
        name: 'The Godfather',
        release_date: '1972-03-24'
      },
      {
        id: 3,
        name: 'Pulp Fiction',
        release_date: '1994-10-14'
      },
      {
        id: 4,
        name: 'The Dark Knight',
        release_date: '2008-07-18'
      },
      {
        id: 5,
        name: 'Fight Club',
        release_date: '1999-10-15'
      },
      {
        id: 6,
        name: 'Inception',
        release_date: '2010-07-16'
      },
      {
        id: 7,
        name: 'The Matrix',
        release_date: '1999-03-31'
      },
      {
        id: 8,
        name: 'Goodfellas',
        release_date: '1990-09-19'
      },
      {
        id: 9,
        name: 'The Silence of the Lambs',
        release_date: '1991-02-14'
      },
      {
        id: 10,
        name: 'Interstellar',
        release_date: '2014-11-07'
      },
      {
        id: 11,
        name: 'The Lion King',
        release_date: '1994-06-24'
      },
      {
        id: 12,
        name: 'Forrest Gump',
        release_date: '1994-07-06'
      },
      {
        id: 13,
        name: 'Jurassic Park',
        release_date: '1993-06-11'
      },
      {
        id: 14,
        name: 'Titanic',
        release_date: '1997-12-19'
      },
      {
        id: 15,
        name: 'Avatar',
        release_date: '2009-12-18'
      },
      {
        id: 16,
        name: 'The Avengers',
        release_date: '2012-05-04'
      },
      {
        id: 17,
        name: 'Star Wars: Episode IV - A New Hope',
        release_date: '1977-05-25'
      },
      {
        id: 18,
        name: 'Back to the Future',
        release_date: '1985-07-03'
      },
      {
        id: 19,
        name: 'Gladiator',
        release_date: '2000-05-05'
      },
      {
        id: 20,
        name: 'The Lord of the Rings: The Fellowship of the Ring',
        release_date: '2001-12-19'
      },
      {
        id: 21,
        name: 'The Departed',
        release_date: '2006-10-06'
      },
      {
        id: 22,
        name: 'Schindler\'s List',
        release_date: '1993-12-15'
      },
      {
        id: 23,
        name: 'The Green Mile',
        release_date: '1999-12-10'
      },
      {
        id: 24,
        name: 'Saving Private Ryan',
        release_date: '1998-07-24'
      },
      {
        id: 25,
        name: 'The Social Network',
        release_date: '2010-10-01'
      },
      {
        id: 26,
        name: 'The Prestige',
        release_date: '2006-10-20'
      },
      {
        id: 27,
        name: 'The Grand Budapest Hotel',
        release_date: '2014-03-07'
      },
      {
        id: 28,
        name: 'La La Land',
        release_date: '2016-12-09'
      },
      {
        id: 29,
        name: 'Get Out',
        release_date: '2017-02-24'
      },
      {
        id: 30,
        name: 'Parasite',
        release_date: '2019-10-11'
      },
      {
        id: 31,
        name: 'Whiplash',
        release_date: '2014-10-10'
      },
      {
        id: 32,
        name: 'Mad Max: Fury Road',
        release_date: '2015-05-15'
      },
      {
        id: 33,
        name: 'The Shape of Water',
        release_date: '2017-12-01'
      },
      {
        id: 34,
        name: 'Black Panther',
        release_date: '2018-02-16'
      },
      {
        id: 35,
        name: 'Moonlight',
        release_date: '2016-10-21'
      },
      {
        id: 36,
        name: 'A Beautiful Mind',
        release_date: '2001-12-21'
      },
      {
        id: 37,
        name: 'The Wolf of Wall Street',
        release_date: '2013-12-25'
      },
      {
        id: 38,
        name: 'No Country for Old Men',
        release_date: '2007-11-09'
      },
      {
        id: 39,
        name: 'There Will Be Blood',
        release_date: '2007-12-26'
      },
      {
        id: 40,
        name: 'The Revenant',
        release_date: '2015-12-25'
      },
      {
        id: 41,
        name: 'Django Unchained',
        release_date: '2012-12-25'
      },
      {
        id: 42,
        name: 'Inglourious Basterds',
        release_date: '2009-08-21'
      },
      {
        id: 43,
        name: 'The Pianist',
        release_date: '2002-09-24'
      },
      {
        id: 44,
        name: 'A Clockwork Orange',
        release_date: '1971-12-19'
      },
      {
        id: 45,
        name: 'The Big Lebowski',
        release_date: '1998-03-06'
      },
      {
        id: 46,
        name: 'Eternal Sunshine of the Spotless Mind',
        release_date: '2004-03-19'
      },
      {
        id: 47,
        name: 'The Sixth Sense',
        release_date: '1999-08-06'
      },
      {
        id: 48,
        name: 'Memento',
        release_date: '2000-09-05'
      },
      {
        id: 49,
        name: 'American Beauty',
        release_date: '1999-09-15'
      },
      {
        id: 50,
        name: 'Good Will Hunting',
        release_date: '1997-12-05'
      }
    ].map do |item|
      CustomObject.new(item)
    end
  end

  def fields
    field :id, as: :id
    field :name, as: :text
    field :release_date, as: :date
  end
end

class CustomObject
  include ActiveModel::Model

  attr_accessor :id, :name, :release_date

  def to_param
    id
  end
end
