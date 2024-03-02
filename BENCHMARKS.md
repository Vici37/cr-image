# Benchmarks

This file contains the results of running the benchmarks from

```
make benchmark
```

I run these on a laptop with specs:

* Intel(R) Core(TM) i7-8565U CPU @ 1.80GHz
* 16GB Memory
* Linux Mint 20.3

# Results

## Operations

|                 Operations | Time     | Memory  |
| -------------------------- | -------- | ------- |
| bilinear_resize!(640, 480) | 16.97ms  | 1.17MiB |
|              box_blur!(10) | 6.76ms   | 732kiB  |
|           brightness!(1.4) | 2.85ms   | 0B      |
| channel_swap!(:red, :blue) | 0.08µs   | 0B      |
|             contrast!(128) | 2.51ms   | 0B      |
|  crop!(300, 250, 100, 100) | 28.65µs  | 102kiB  |
|         gaussian_blur!(10) | 20.51ms  | 2.15MiB |
|        histogram_equalize! | 25.79ms  | 236kiB  |
|       horizontal_blur!(10) | 3.13ms   | 366kiB  |
|                  pad!(100) | 581.39µs | 2.54MiB |
|                rotate!(45) | 11.95ms  | 1.43MiB |
|         vertical_blur!(10) | 3.74ms   | 366kiB  |

## Drawing

|                                                    Drawing | Time    | Memory  |
| ---------------------------------------------------------- | ------- | ------- |
|             draw_square!(100, 100, 100, 100, Color.random) | 8.8µs   | 0B      |
| draw_square!(100, 100, 100, 100, Color.random, fill: true) | 23.35µs | 42.9kiB |
|                  draw_circle!(100, 100, 100, Color.random) | 94.71µs | 55.4kiB |
|      draw_circle!(100, 100, 100, Color.random, fill: true) | 82.15µs | 134kiB  |
|               draw_line!(100, 100, 100, 100, Color.random) | 5.05µs  | 0B      |

## Mask Operations

|                      Mask | Time     | Memory  |
| ------------------------- | -------- | ------- |
|              apply!(mask) | 1.45ms   | 45.8kiB |
|         mask.apply(image) | 3.09ms   | 1.48MiB |
|      to_gray.threshold(8) | 3.19ms   | 778kiB  |
|                    region | 441.07µs | 0B      |
|                  segments | 3.46ms   | 100kiB  |
| segments(diagonal: false) | 3.19ms   | 95.5kiB |
|                   dilate! | 6.5ms    | 45.8kiB |
|  dilate!(diagonal: false) | 4.05ms   | 45.8kiB |
|                    erode! | 770.49µs | 45.8kiB |
|   erode!(diagonal: false) | 751.96µs | 45.8kiB |
|                  opening! | 6.8ms    | 91.6kiB |
| opening!(diagonal: false) | 4.01ms   | 91.6kiB |
|                  closing! | 6.76ms   | 91.6kiB |
| closing!(diagonal: false) | 4.02ms   | 91.6kiB |

## Map Operations

For these tests, with `template[n]`, `template = CrImage::OneMap.new(n, n)`

|                               Map | Time     | Memory  |
| --------------------------------- | -------- | ------- |
|      cross_correlate(template[3]) | 46.94ms  | 23.6MiB |
|  cross_correlate_fft(template[3]) | 174.56ms | 29.8MiB |
|      cross_correlate(template[7]) | 151.94ms | 23.6MiB |
|  cross_correlate_fft(template[7]) | 165.78ms | 29.8MiB |
|     cross_correlate(template[13]) | 508.86ms | 23.6MiB |
| cross_correlate_fft(template[13]) | 356.17ms | 53.8MiB |
|     cross_correlate(template[17]) | 969.76ms | 23.6MiB |
| cross_correlate_fft(template[17]) | 438.09ms | 53.8MiB |

## File Writing

|                          Conversions | Time     | Memory  |
| ------------------------------------ | -------- | ------- |
|                              to_gray | 1.95ms   | 732kiB  |
|               to_ppm(IO::Memory.new) | 6.9ms    | 4.01MiB |
|libspng        to_png(IO::Memory.new) | 119.5ms  | 1.55MiB |
|native crystal to_png(IO::Memory.new) | 117.86ms | 1.93MiB |
|              to_jpeg(IO::Memory.new) | 10.24ms  | 1.2MiB  |
|              to_webp(IO::Memory.new) | 213.93ms | 1.5MiB  |
| to_webp(IO::Memory.new, lossy: true) | 38.07ms  | 1.45MiB |
