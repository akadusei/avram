struct Float64
  def self.adapter
    Lucky
  end

  module Lucky
    alias ColumnType = ::PG::Numeric | Float64
    include Avram::Type

    def self.criteria(query : T, column : Symbol | String) forall T
      Criteria(T, Float64).new(query, column)
    end

    def from_db!(value : Float64) : Float64
      value
    end

    def from_db!(value : PG::Numeric) : Float64
      value.to_f
    end

    def parse(value : Float64) : SuccessfulCast(Float64)
      SuccessfulCast(Float64).new(value)
    end

    def parse(values : Array(Float64)) : SuccessfulCast(Array(Float64))
      SuccessfulCast(Array(Float64)).new values
    end

    def parse(value : PG::Numeric) : SuccessfulCast(Float64)
      SuccessfulCast(Float64).new(value.to_f)
    end

    def parse(values : Array(PG::Numeric)) : SuccessfulCast(Array(Float64))
      SuccessfulCast(Array(Float64)).new values.map(&.to_f)
    end

    def parse(value : String) : SuccessfulCast(Float64) | FailedCast
      SuccessfulCast(Float64).new value.to_f64
    rescue ArgumentError
      FailedCast.new
    end

    def parse(value : Int32) : SuccessfulCast(Float64)
      SuccessfulCast(Float64).new value.to_f64
    end

    def parse(value : Int64) : SuccessfulCast(Float64)
      SuccessfulCast(Float64).new value.to_f64
    end

    def to_db(value : Float64) : String
      value.to_s
    end

    def to_db(values : Array(Float64))
      PQ::Param.encode_array(values)
    end

    class Criteria(T, V) < Avram::Criteria(T, V)
      include Avram::BetweenCriteria(T, V)

      def select_sum : Float64?
        if sum = super
          sum.as(PG::Numeric).to_f
        end
      end

      def select_sum! : Float64
        select_sum || 0_f64
      end

      define_function_criteria(abs, V)
      define_function_criteria(ceil, V)
      define_function_criteria(floor, V)
    end
  end
end
