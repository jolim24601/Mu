class Cat < MuRecord::Base
  belongs_to :owner, foreign_key: :owner_id, class_name: "Human"

  self.finalize!
end
