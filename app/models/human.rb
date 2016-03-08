class Human < MuRecord::Base
  has_many :cats

  self.finalize!
end
