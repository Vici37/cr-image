#!/usr/bin/env -S crystal run --no-debug --release

require "../src/cr-image"
require "../src/all_formats"

record Result, name : String, time : Float64, memory : Int64
alias Color = CrImage::Color

def benchmark_memory(&)
  bytes_before_measure = GC.stats.total_bytes
  yield
  (GC.stats.total_bytes - bytes_before_measure).to_i64
end

def benchmark_time(&)
  time = Time.monotonic
  yield
  Time.monotonic - time
end

private def elapsed_text(millis)
  return "#{millis.round(2)}ms" if millis >= 1

  "#{(millis * 1000).round(2)}µs"
end

def print_result_table(results : Array(Result))
  name_rjust = results.map(&.name.size).max
  time_ljust = results.map { |res| elapsed_text(res.time).size }.max
  memo_ljust = results.map(&.memory.humanize_bytes.size).max

  # Headers
  table = [
    [" " * name_rjust, "Time".ljust(time_ljust), "Memory".ljust(memo_ljust)],
    ["-" * name_rjust, "-" * time_ljust, "-" * memo_ljust],
  ]

  # Rows
  results.each do |result|
    table << [
      result.name.rjust(name_rjust),
      elapsed_text(result.time).ljust(time_ljust),
      result.memory.humanize_bytes.ljust(memo_ljust),
    ]
  end

  output = String.build do |string|
    table.each do |row|
      string << "| " << row.join(" | ") << " |\n"
    end
    string << "\nTotal Time: " << elapsed_text(results.sum(&.time)) << "\n"
    string << "Total Memory: " << results.sum(&.memory).humanize_bytes
  end

  puts output
end

macro benchmark(&)
  image = CrImage::RGBAImage.open("lib/cr-image-samples/scenic/moon.ppm")
  memory = 0i64
  time = benchmark_time do
    memory = benchmark_memory do
      {{yield}}
    end
  end
  Result.new(name: "{{yield.id.strip.split("\n")[-1].id}}".gsub("image.", ""), memory: memory, time: time.total_milliseconds)
end

results = [] of Result

results << benchmark { image.bilinear_resize!(640, 480) }
results << benchmark { image.brightness!(1.4) }
results << benchmark { image.box_blur!(10) }
results << benchmark { image.channel_swap!(:red, :blue) }
results << benchmark { image.contrast!(128) }
results << benchmark { image.gaussian_blur!(10) }
results << benchmark { image.horizontal_blur!(10) }
results << benchmark { image.vertical_blur!(10) }
results << benchmark { image.crop!(300, 250, 100, 100) }
results << benchmark { image.histogram_equalize! }
results << benchmark { image.pad!(100) }
results << benchmark { image.rotate!(45) }
results << benchmark { image.draw_square!(100, 100, 100, 100, Color.random) }
results << benchmark { image.draw_square!(100, 100, 100, 100, Color.random, fill: true) }
results << benchmark { image.draw_circle!(100, 100, 100, Color.random) }
results << benchmark { image.draw_circle!(100, 100, 100, Color.random, fill: true) }

results << benchmark do
  mask = CrImage::Mask.new(image)
  image.apply!(mask)
end
results << benchmark do
  mask = CrImage::Mask.new(image)
  mask.apply(image)
end
results << benchmark { image.to_gray }
results << benchmark { image.to_gray.threshold(8) }
results << benchmark { image.to_gray.threshold(8).region }
results << benchmark { image.to_gray.threshold(8).segments }
results << benchmark { image.to_gray.threshold(8).segments(diagonal: false) }
results << benchmark { image.to_ppm(IO::Memory.new) }
results << benchmark { image.to_jpeg(IO::Memory.new) }
results << benchmark { image.to_webp(IO::Memory.new) }
results << benchmark { image.to_webp(IO::Memory.new, lossy: true) }

print_result_table(results)
