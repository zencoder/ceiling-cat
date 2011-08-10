module CeilingCat
  class User
    attr_accessor :name, :role, :id

    def initialize(name, opts={})
      @name = name
      @id = opts[:id]
      @role = opts[:role] || :guest
    end
    
    def to_s
      short_name
    end
    
    def short_name
      @name.to_s.split.compact.first
    end

    def is_registered?
      @role.to_s.downcase == 'member'
    end

    def is_guest?
      @role.to_s.downcase == 'guest' || @type.to_s.nil?
    end
  end
end