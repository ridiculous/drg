require_relative 'extensions'

Go = Class.new(String) do
  include Extensions
  def now
    'going'
  end
end
