class SignOff < ApplicationRecord
  belongs_to :sign_off_group
  belongs_to :step, class_name: "Releases::Step", foreign_key: "train_step_id", inverse_of: :sign_offs
  belongs_to :user, class_name: "Accounts::User"
end
