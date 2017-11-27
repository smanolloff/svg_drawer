module Utils
  class ParameterMerger
    ParameterNotFound = Class.new(StandardError)

    def initialize(*sources)
      @sources = sources
    end

    # At least one of the sources must contain some value for the param
    # (even a nil value)
    def param(name)
      source = @sources.find { |s| s.key?(name) }
      raise ParameterNotFound, "No such param: #{name}" unless source
      val = source[name]

      val.is_a?(Hash) ? default_hash(name, val) : val
    end

    def param?(name)
      !!param(name)
    rescue ParameterNotFound
      false
    end

    private

    # When the value is the hash, populate its missing keys (if any)
    # with default values
    def default_hash(name, value)
      @sources.reduce(value) do |hash, source|
        source[name] ? hash.reverse_merge(source[name]) : hash
      end
    end
  end
end
