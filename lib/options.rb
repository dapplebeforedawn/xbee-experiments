module Options
  def self.get
    return @o if @o
    @o = Struct.new(:ref_voltage, :ref_pounds, :ref_tare, :hide_count).new
    OptionParser.new do |opts|
      opts.on("-h", "--help", "This help")       { exec "more #{__FILE__}" }

      opts.on("-e", "--ref_voltage [VOLTS]", "") { |arg| @o.ref_voltage = arg.to_f }
      opts.on("-w", "--ref_pounds [POUNDS]", "") { |arg| @o.ref_pounds  = arg.to_f }
      opts.on("-z", "--zero [VOLTS]",        "") { |arg| @o.ref_tare    = arg.to_f }
      opts.on("-c", "--hide_count",          "") { |arg| @o.hide_count  = true     }
    end.parse!
    @o
  end
end
