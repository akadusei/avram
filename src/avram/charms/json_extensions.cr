module JSON::Serializable
  macro included
    def self.adapter
      Lucky(self)
    end
  end

  module Lucky(T)
    include Avram::Type

    def self.criteria(query : R, column) forall R
      Criteria(R, T).new(query, column)
    end

    def from_db!(value)
      value
    end

    def parse(value : Array(T))
      SuccessfulCast(Array(T)).new value
    end

    def parse(value : JSON::Serializable) : SuccessfulCast(JSON::Serializable)
      SuccessfulCast(JSON::Serializable).new value
    end

    def to_db(value) : String
      value.to_json
    end

    class Criteria(T, V) < Avram::Criteria(T, V)
    end
  end
end

struct JSON::Any
  def self.adapter
    Lucky
  end

  module Lucky
    alias ColumnType = JSON::Any
    include Avram::Type

    def self.criteria(query : T, column : Symbol | String) forall T
      Criteria(T, JSON::Any).new(query, column)
    end

    def from_db!(value : JSON::Any) : JSON::Any
      value
    end

    def parse(value : JSON::Any) : SuccessfulCast(JSON::Any)
      SuccessfulCast(JSON::Any).new value
    end

    def parse(value : String) : SuccessfulCast(JSON::Any)
      value = begin
        JSON.parse(value)
      rescue JSON::ParseException
        JSON.parse(value.to_json)
      end
      SuccessfulCast(JSON::Any).new value
    end

    def parse(value : Nil) : SuccessfulCast(Nil)
      SuccessfulCast(Nil).new nil
    end

    def parse(value) : SuccessfulCast(JSON::Any)
      SuccessfulCast(JSON::Any).new JSON.parse(value.to_json)
    end

    def to_db(value) : String
      value.to_json
    end

    class Criteria(T, V) < Avram::Criteria(T, V)
      # performs `WHERE jsonb ? string`
      def has_key(value : String) : T
        add_clause(Avram::Where::JsonbHasKey.new(column, value))
      end

      # performs `WHERE jsonb ?| array`
      def has_any_keys(keys : Array(String)) : T
        add_clause(Avram::Where::JsonbHasAnyKeys.new(column, keys))
      end

      # performs `WHERE jsonb ?& array`
      def has_all_keys(keys : Array(String)) : T
        add_clause(Avram::Where::JsonbHasAllKeys.new(column, keys))
      end

      # performs `WHERE jsonb @> other_json`
      def includes(value) : T
        add_clause(Avram::Where::JsonbIncludes.new(column, value.to_json))
      end

      # performs `WHERE jsonb <@ other_json`
      def in(value) : T
        add_clause(Avram::Where::JsonbIn.new(column, value.to_json))
      end
    end
  end
end
