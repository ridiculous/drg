
class MultipleArgs
  def self.__
    ''
  end

  def initialize(name, age = INFINITY, *args)
    @name, @args = name, args
  end
end
