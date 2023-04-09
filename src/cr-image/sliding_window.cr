class CrImage::SlidingWindow
  def initialize(
    image : GrayscaleImage,
    @parent : GrayscaleImage,
    *,
    @edge_policy : EdgePolicy = EdgePolicy::Repeat
  )
    @window = UInt8Map.new(image.width, image.gray).as(Map)
  end

  def initialize(
    @window : Map,
    @parent : GrayscaleImage,
    *,
    @edge_policy : EdgePolicy = EdgePolicy::Repeat
  )
    raise Exception.new "Provided window is too big: width #{@window.width} is larger than the parent width #{@parent.width}" if @window.width > @parent.width
    raise Exception.new "Provided window is too big: height #{@window.height} is larger than the parent height #{@parent.height}" if @window.height > @parent.height
  end

  def slide : Float64Map
    half_width = @window.width >> 1
    half_height = @window.height >> 1

    start_x, start_y = (@edge_policy.none? ? {half_width, half_height} : {0, 0})
    end_x, end_y = (@edge_policy.none? ? {@parent.width - half_width - 1, @parent.height - half_height - 1} : {@parent.width - 1, @parent.height - 1})

    ret = Array(Float64).new((end_x - start_x) * (end_y - start_y))

    start_y.upto(end_y).each do |y|
      start_x.upto(end_x).each do |x|
        view = case @edge_policy
               in EdgePolicy::Repeat then RepeatView.new(@window.width, @window.height, @parent, x, y)
               in EdgePolicy::Black  then BlackView.new(@window.width, @window.height, @parent, x, y)
               in EdgePolicy::None   then ErrorView.new(@window.width, @window.height, @parent, x, y)
               end
        # ret << view.sum(1.0 / @window.raw.sum) do |pixel, vx, vy|
        ret << view.sum(1/9) do |pixel, vx, vy|
          @window[vx, vy] * pixel
        end.round
      end
    end

    retf = Float64Map.new(end_x - start_x + 1, ret)
    puts "Original: #{@parent.width}x#{@parent.height}, new: #{retf.width}x#{retf.height}, iterated over #{start_x}-#{end_x}x#{start_y}-#{end_y}, ret size: #{ret.size}, window size: #{@parent.size}"
    retf
  end
end
