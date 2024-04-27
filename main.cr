require "hardware"
require "clim"
require "climate"
require "colorize"

Climate.configure do |settings|
  settings.styles << Climate::Style.new(
    delimiters: {'<', '>'},
    keep_delimiters: false,
    colors: {
      fore: :green,
      back: :default,
    },
    decoration: :bold
  )

  # and/or configure your own styles
  settings.styles << Climate::Style.new(
    delimiters: {'[', ']'},
    keep_delimiters: false,
    colors: {
      fore: :yellow,
      back: :default,
    },
    decoration: :bold
  )

  settings.styles << Climate::Style.new(
    delimiters: {'(', ']'},
    keep_delimiters: false,
    colors: {
      fore: Colorize::Color256.new(208),
      back: :default,
    },
    decoration: :bold
  )

  settings.styles << Climate::Style.new(
    delimiters: {'(', ')'},
    keep_delimiters: false,
    colors: {
      fore: :red,
      back: :default,
    },
    decoration: :bold
  )
end

def putColor(value : Int)
  outColoryzed = case value
                 when 0...25
                   "<#{value}>"
                 when 25...50
                   "[#{value}]"
                 when 50..70
                   "(#{value}]"
                 else
                   "(#{value})"
                 end

  outColoryzed.climatize
end

class HInfo < Clim
  main do
    desc "tiny utility for display info of cpu and memory"
    usage "hinfo [options] [sub_command] [arguments] ..."
    version "0.1.0", short: "-v"
    option "-t TIME", "--time=TIME", type: Float64, desc: "time interval of monitoring", default: 1.0
    run do |opts, args|
      cpu = Hardware::CPU.new

      loop do
        mem = Hardware::Memory.new
        sleep opts.time
        system("clear")
        cpuUsage = putColor(cpu.usage!.to_i)
        memPercent = putColor(mem.percent.to_i)
        puts "cpu usage: #{cpuUsage}%"
        puts "memory usage: #{memPercent}%"
      end
    end
    sub "process" do
      desc "view process cpu info"
      usage "hinfo process [process_name]"
      argument "processName", type: String, desc: "name of the process"
      option "-t TIME", "--time=TIME", type: Float64, desc: "time interval of monitoring", default: 1.0
      run do |opts, args|
        if args.all_args.size == 0
          raise "process not provided"
          puts opts.help_string
          next
        end
        appStats = args.all_args.map do |arg|
          appPid = Hardware::PID.new(arg)
          {name: appPid.name, stat: appPid.stat}
        end

        loop do
          sleep opts.time
          system("clear")
          appStats.each do |at|
            if(at.nil?)
              next
            end
            appUsage = putColor(at[:stat].cpu_usage!.to_i)
            puts "#{at[:name]}: #{appUsage}%"
          end
        end
      end
    end
  end
end

HInfo.start(ARGV)
