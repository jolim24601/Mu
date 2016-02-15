class Cat < MuRecord::Base
  belongs_to :human

  self.finalize!
end
