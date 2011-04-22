class OperationLog < ActiveRecord::Base
  symbolize :level, :in => [:warning, :serious, :ok, :unknown]
  symbolize :description

  before_validation_on_create :ensure_level

  protected

  def ensure_level
    self.level = :unknown if self.level.nil?
  end
end
