#!/usr/bin/env -S crystal run --no-debug --release

require "../src/cr-image"
require "../src/webp"
require "../src/jpeg"

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

def print_result_table(name : String, results : Array(Result))
  name_rjust = {name.size, results.map(&.name.size).max}.max
  time_ljust = results.map { |res| elapsed_text(res.time).size }.max
  memo_ljust = results.map(&.memory.humanize_bytes.size).max

  # Headers
  table = [
    [name.rjust(name_rjust), "Time".ljust(time_ljust), "Memory".ljust(memo_ljust)],
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
    # string << "\nTotal Time: " << elapsed_text(results.sum(&.time)) << "\n"
    # string << "Total Memory: " << results.sum(&.memory).humanize_bytes
    string << "========================="
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

macro benchmark_mask(&)
  image = CrImage::RGBAImage.open("lib/cr-image-samples/scenic/moon.ppm")
  mask = image.to_gray.threshold(8)
  memory = 0i64
  time = benchmark_time do
    memory = benchmark_memory do
      {{yield}}
    end
  end
  Result.new(name: "{{yield.id.strip.split("\n")[-1].id}}".gsub("mask.", ""), memory: memory, time: time.total_milliseconds)
end

macro benchmark_map(size = 3, &)
  map = CrImage::GrayscaleImage.open("lib/cr-image-samples/scenic/moon.ppm").to_map!.to_i
  template = CrImage::OneMap.new({{size}}, {{size}})
  memory = 0i64
  time = benchmark_time do
    memory = benchmark_memory do
      {{yield}}
    end
  end
  Result.new(name: "{{yield.id.strip.split("\n")[-1].id}}".gsub("map.", "").gsub("template", "template[{{size}}]"), memory: memory, time: time.total_milliseconds)
end

results = [] of Result

results << benchmark { image.bilinear_resize!(640, 480) }
results << benchmark { image.box_blur!(10) }
results << benchmark { image.brightness!(1.4) }
results << benchmark { image.channel_swap!(:red, :blue) }
results << benchmark { image.contrast!(128) }
results << benchmark { image.crop!(300, 250, 100, 100) }
results << benchmark { image.gaussian_blur!(10) }
results << benchmark { image.histogram_equalize! }
results << benchmark { image.horizontal_blur!(10) }
results << benchmark { image.pad!(100) }
results << benchmark { image.rotate!(45) }
results << benchmark { image.vertical_blur!(10) }

print_result_table("Operations", results)
results.clear

results << benchmark { image.draw_square!(100, 100, 100, 100, Color.random) }
results << benchmark { image.draw_square!(100, 100, 100, 100, Color.random, fill: true) }
results << benchmark { image.draw_circle!(100, 100, 100, Color.random) }
results << benchmark { image.draw_circle!(100, 100, 100, Color.random, fill: true) }
results << benchmark { image.draw_line!(100, 100, 100, 100, Color.random) }

print_result_table("Drawing", results)
results.clear

results << benchmark do
  mask = CrImage::Mask.new(image)
  image.apply!(mask)
end
results << benchmark do
  mask = CrImage::Mask.new(image)
  mask.apply(image)
end
results << benchmark { image.to_gray.threshold(8) }
results << benchmark_mask { mask.region }
results << benchmark_mask { mask.segments }
results << benchmark_mask { mask.segments(diagonal: false) }
results << benchmark_mask { mask.dilate! }
results << benchmark_mask { mask.dilate!(diagonal: false) }
results << benchmark_mask { mask.erode! }
results << benchmark_mask { mask.erode!(diagonal: false) }
results << benchmark_mask { mask.opening! }
results << benchmark_mask { mask.opening!(diagonal: false) }
results << benchmark_mask { mask.closing! }
results << benchmark_mask { mask.closing!(diagonal: false) }

print_result_table("Mask", results)
results.clear

results << benchmark_map(3) { map.cross_correlate(template) }
results << benchmark_map(3) { map.cross_correlate_fft(template) }
results << benchmark_map(7) { map.cross_correlate(template) }
results << benchmark_map(7) { map.cross_correlate_fft(template) }
results << benchmark_map(13) { map.cross_correlate(template) }
results << benchmark_map(13) { map.cross_correlate_fft(template) }
results << benchmark_map(17) { map.cross_correlate(template) }
results << benchmark_map(17) { map.cross_correlate_fft(template) }

print_result_table("Map", results)
results.clear

results << benchmark { image.to_gray }
results << benchmark { image.to_ppm(IO::Memory.new) }
# NOTE: to get the benchmark for libspng, you need to:
# require "../src/png"
# Since the perf of both is so close, the default is for the native implementation
results << benchmark { image.to_png(IO::Memory.new) }
results << benchmark { image.to_jpeg(IO::Memory.new) }
results << benchmark { image.to_webp(IO::Memory.new) }
results << benchmark { image.to_webp(IO::Memory.new, lossy: true) }

print_result_table("Conversions", results)
