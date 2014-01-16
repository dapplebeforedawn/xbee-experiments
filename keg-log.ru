require 'open3'

class String; alias :each :each_line; end

CANVAS_TYPES = {
  "html" => ["canvas", "text/html"],
  "png"  => ["png",    "image/png"],
  "svg"  => ["svg",    "image/svg+xml"],
  "txt"  => ["dumb",   "text/plain"],
  "ico"  => ["svg",    "image/svg+xml"],
}

commands = ->(type){
  <<HEREDOC
    set term #{CANVAS_TYPES[type].first}
    set output '/dev/stdout'
    set datafile separator ','
    plot 'keg-log.dat' with lines
HEREDOC
}

Kegmotron = ->(env) do
  canvas   = env["REQUEST_PATH"].split('.').last || "txt"
  chart, _ = Open3.capture2("gnuplot", stdin_data: commands.call(canvas))

  if canvas == "html"
    chart << "<script>" << File.read('/usr/share/gnuplot/4.4/js/canvastext.js') << "</script>"
    chart << "<script>" << File.read('/usr/share/gnuplot/4.4/js/gnuplot_common.js') << "</script>"
    chart << "<style>" << File.read('/usr/share/gnuplot/4.4/js/gnuplot_mouse.css') << "</style>"
  end

  [ 200, {'Content-Type'=> CANVAS_TYPES[canvas].last}, chart ]
end

run  Kegmotron
