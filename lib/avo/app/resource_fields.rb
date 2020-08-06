module Avo
  module Resources
    class Resource
      class << self
        @@fields = {}

        def fields(&block)
          @@fields[self] ||= []
          yield
        end

        def get_fields
          @@fields[self] or []
        end

        def id(name = 'ID', **args)
          @@fields[self].push Avo::Fields::IdField::new(name, **args)
        end

        def text(name, **args, &block)
          @@fields[self].push Avo::Fields::TextField::new(name, **args, &block)
        end

        def password(name, **args, &block)
          @@fields[self].push Avo::Fields::PasswordField::new(name, **args, &block)
        end

        def textarea(name, **args, &block)
          @@fields[self].push Avo::Fields::TextareaField::new(name, **args, &block)
        end

        def number(name, **args, &block)
          @@fields[self].push Avo::Fields::NumberField::new(name, **args, &block)
        end

        def boolean(name, **args, &block)
          @@fields[self].push Avo::Fields::BooleanField::new(name, **args, &block)
        end

        def select(name, **args, &block)
          @@fields[self].push Avo::Fields::SelectField::new(name, **args, &block)
        end

        def date(name, **args)
          @@fields[self].push Avo::Fields::DateField::new(name, **args)
        end

        def datetime(name, **args)
          @@fields[self].push Avo::Fields::DatetimeField::new(name, **args)
        end

        def boolean_group(name, **args, &block)
          @@fields[self].push Avo::Fields::BooleanGroupField::new(name, **args, &block)
        end

        def key_value(name, **args)
          @@fields[self].push Avo::Fields::KeyValueField::new(name, **args)
        end

        def status(name, **args, &block)
          @@fields[self].push Avo::Fields::StatusField::new(name, **args, &block)
        end

        def heading(name, **args)
          @@fields[self].push Avo::Fields::HeadingField::new(name, **args)
        end

        def belongs_to(name, **args)
          @@fields[self].push Avo::Fields::BelongsToField::new(name, **args)
        end

        def has_one(name, **args)
          @@fields[self].push Avo::Fields::HasOneField::new(name, **args)
        end

        def has_many(name, **args)
          @@fields[self].push Avo::Fields::HasManyField::new(name, **args)
        end

        def has_and_belongs_to_many(name, **args)
          @@fields[self].push Avo::Fields::HasAndBelongsToManyField::new(name, **args)
        end

        def file(name, **args)
          @@fields[self].push Avo::Fields::FileField::new(name, **args)
        end

        def files(name, **args)
          @@fields[self].push Avo::Fields::FilesField::new(name, **args)
        end

        def currency(name, **args, &block)
          @@fields[self].push Avo::Fields::CurrencyField::new(name, **args, &block)
        end

        def gravatar(name, **args, &block)
          @@fields[self].push Avo::Fields::GravatarField::new(name, **args, &block)
        end

        def country(name, **args, &block)
          @@fields[self].push Avo::Fields::CountryField::new(name, **args, &block)
        end

        def badge(name, **args, &block)
          @@fields[self].push Avo::Fields::BadgeField::new(name, **args, &block)
        end

        def code(name, **args, &block)
          @@fields[self].push Avo::Fields::CodeField::new(name, **args, &block)
        end

        def hidden(name, **args, &block)
          @@fields[self].push Avo::Fields::HiddenField::new(name, **args, &block)
        end
      end
    end
  end
end
