# frozen_string_literal: true

# Stores a model in a single row with the id 1, for settings that exist once
# per installation, e.g. the footer. Its table should also check `id = 1`.
#
# Read the record with `instance`, change it through `find_or_create_instance`:
#
#   Footer.instance.copyright
#   Footer.find_or_create_instance.update(copyright: "© Example")
module SingletonRecord
  extend ActiveSupport::Concern

  ID = 1

  included do
    attribute :id, default: ID

    after_commit { Current.singleton_records&.delete(self.class.name) }
  end

  class_methods do
    # Returns the record, loaded once per request, as most pages read it.
    def instance
      (Current.singleton_records ||= {})[name] ||= find_or_create_instance
    end

    # Returns the record from the database, for changing it. A change that
    # fails validation then doesn't show up in the record the page renders.
    #
    # Creates the record with its defaults when it doesn't exist yet. Another
    # request may create it at the same time, which `create_or_find_by!`
    # handles by loading that record instead.
    def find_or_create_instance
      find_by(id: ID) || create_or_find_by!(id: ID)
    end
  end
end
