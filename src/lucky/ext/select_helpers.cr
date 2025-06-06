module Lucky::SelectHelpers
  def select_input(field : Avram::PermittedAttribute, attrs : Array(Symbol) = [] of Symbol, **html_options, &) : Nil
    select_tag attrs, merge_options(html_options, {"id" => input_id(field), "name" => input_name(field)}) do
      yield
    end
  end

  def multi_select_input(field : Avram::PermittedAttribute(Array), attrs : Array(Symbol) = [] of Symbol, **html_options, &) : Nil
    merged_attrs = [:multiple].concat(attrs)
    select_tag merged_attrs, merge_options(html_options, {"id" => input_id(field), "name" => input_name(field)}) do
      yield
    end
  end

  def options_for_select(field : Avram::PermittedAttribute(T), select_options : Array(Tuple(String, T?)), **html_options) : Nil forall T
    select_options.each do |option_name, option_value|
      attributes = {"value" => option_value.to_s}
      bool_attrs = [] of Symbol

      is_selected = option_value.to_s == field.param.to_s
      bool_attrs << :selected if is_selected

      option(option_name, attrs: bool_attrs, options: merge_options(html_options, attributes))
    end
  end

  def options_for_select(field : Avram::PermittedAttribute(Array(T)), select_options : Array(Tuple(String, T)), **html_options) : Nil forall T
    select_options.each do |option_name, option_value|
      attributes = {"value" => option_value.to_s}
      bool_attrs = [] of Symbol

      if value = field.value
        is_selected = value.includes?(option_value)
        bool_attrs << :selected if is_selected
      end

      option(option_name, attrs: bool_attrs, options: merge_options(html_options, attributes))
    end
  end

  # Renders an <option> HTML tag with no value
  # The text is set to `label`.
  def select_prompt(label : String) : Nil
    option(label, value: "")
  end

  private def input_id(field : Avram::PermittedAttribute)
    "#{field.param_key}_#{field.name}"
  end

  private def input_id(field : Avram::PermittedAttribute(Array))
    "#{field.param_key}_#{field.name}_#{array_id_counter[field.name]}"
  end

  private def input_name(field : Avram::PermittedAttribute)
    "#{field.param_key}:#{field.name}"
  end

  private def input_name(field : Avram::PermittedAttribute(Array))
    "#{field.param_key}:#{field.name}[]"
  end
end
