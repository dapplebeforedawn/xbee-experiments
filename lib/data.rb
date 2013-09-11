module XbeeUtils
  def unpack
    @msg.unpack('H*').first
  end
  private :unpack
end

class Raw
  include XbeeUtils
  def initialize(msg)
    @msg      = msg
    @options  = Options.get
  end

  def to_s
    unpack.scan(/../).join(' ').upcase
  end

  def self.handle?
    true
  end
end

Calibration = Struct.new(:ref_volts, :ref_pounds, :tare) do
  def factor(value)
    eng_val = ((value-tare) * ref_pounds / ref_volts) * -1
    eng_val + 0 # Scrub -0s -- WAT?!
  end
end

class Eng
  include XbeeUtils
  def initialize(msg)
    @msg      = msg
    @options  = Options.get
  end

  def get_value
    unpack.slice(-4..-1).hex
  end
  private :get_value

  def engineering
    cal = Calibration.new(@options.ref_voltage, @options.ref_pounds, @options.ref_tare)
    cal.factor(get_value)
  end
  private :engineering

  def to_s
    "#{sprintf('%0.3f', engineering).rjust(6, '0')} (lbs)"
  end

  def self.handle?
    !!(Options.get.ref_voltage && Options.get.ref_pounds)
  end
end
