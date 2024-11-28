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
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 2,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 3,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 4,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 5,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 6,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 7,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 8,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 9,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 10,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 11,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 12,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 13,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 14,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 15,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 16,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 17,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 18,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 19,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 20,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 21,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 22,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 23,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 24,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 25,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 26,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 27,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 28,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 29,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 30,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 31,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 32,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 33,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 34,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 35,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 36,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 37,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 38,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 39,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 40,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 41,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 42,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 43,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 44,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 45,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 46,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 47,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 48,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 49,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 50,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 51,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 52,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
      {
        id: 53,
        name: "Inception",
        release_date: "2010-07-16",
      },
      {
        id: 54,
        name: "The Dark Knight",
        release_date: "2008-07-18",
      },
      {
        id: 55,
        name: "Interstellar",
        release_date: "2014-11-07",
      },
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
