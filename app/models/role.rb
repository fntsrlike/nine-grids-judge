class Role < ActiveRecord::Base
  # Relationship
  has_and_belongs_to_many(:users, :join_table => :users_roles)
  belongs_to(:resource, :polymorphic => true)

  # Rolify
  validates(:resource_type,
            :inclusion => { :in => Rolify.resource_types },
            :allow_nil => true)
  scopify
end
