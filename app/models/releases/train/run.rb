class Releases::Train::Run < ApplicationRecord
  self.implicit_order_column = :was_run_at

  belongs_to :train, class_name: "Releases::Train"

  enum status: { in_progress: "on_track", error: "error", finished: "finished" }
end