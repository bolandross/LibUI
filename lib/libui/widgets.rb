# frozen_string_literal: true

require_relative '../libui'

module LibUI
  # cat lib/libui/ffi.rb  | grep -oP '(?<=New).*(?=\()'
  widget_names = %w[
    Window
    Button
    HorizontalBox
    VerticalBox
    Checkbox
    Entry
    PasswordEntry
    SearchEntry
    Label
    Tab
    Group
    Spinbox
    Slider
    ProgressBar
    HorizontalSeparator
    VerticalSeparator
    Combobox
    EditableCombobox
    RadioButtons
    DateTimePicker
    DatePicker
    TimePicker
    MultilineEntry
    NonWrappingMultilineEntry
    Menu
    Area
    ScrollingArea
    Path
    Figure
    FigureWithArc
    FamilyAttribute
    SizeAttribute
    WeightAttribute
    ItalicAttribute
    StretchAttribute
    ColorAttribute
    BackgroundAttribute
    UnderlineAttribute
    UnderlineColorAttribute
    OpenTypeFeatures
    FeaturesAttribute
    AttributedString
    TextLayout
    FontButton
    ColorButton
    Form
    Grid
    Image
    TableValueString
    TableValueImage
    TableValueInt
    TableValueColor
    TableModel
    Table
  ]

  h1 = Hash.new([])
  FFI.ffi_methods.each do |m|
    h2[m] = widget_names.select do |n|
      m.match(/ui#{n}/)
    end.max_by { |n| n.length }
  end

  # invert
  h2 = h2.each_key.group_by do |key|
    h2[key]
  end

  h2.each do |widget_name, method_names|
    next if widget_name.nil?

    const_set(
      widget_name,
      Class.new do
        define_method 'initialize' do |*args|
          @ptr = LibUI.public_send("new_#{LibUI::Utils.underscore(widget_name)}", *args)
        end

        def to_ptr
          @ptr
        end

        method_names.each do |original_method_name|
          m = 'ui' + original_method_name[(2 + widget_name.size)..-1]
          method_name = Utils.convert_to_ruby_method(m)
          define_method(method_name) do |*args|
            LibUI.public_send(Utils.convert_to_ruby_method(original_method_name), self, *args)
          end
        end
      end
    )
  end
end
