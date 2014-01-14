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
  [ 200, {'Content-Type'=> CANVAS_TYPES[canvas].last}, chart ]
end

run  Kegmotron
