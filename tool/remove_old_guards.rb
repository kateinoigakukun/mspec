# Removes old version guards in ruby/spec.
# Run it from the ruby/spec repository root.
# The argument is the new minimum supported version.

def dedent(line)
  if line.start_with?("  ")
    line[2..-1]
  else
    line
  end
end

def remove_guards(guard, keep)
  Dir["*/**/*.rb"].each do |file|
    contents = File.binread(file)
    if contents =~ guard
      puts file
      lines = contents.lines.to_a
      while first = lines.find_index { |line| line =~ guard }
        indent = lines[first][/^(\s*)/, 1].length
        last = (first+1...lines.size).find { |i|
          space = lines[i][/^(\s*)end$/, 1] and space.length == indent
        }
        raise file unless last
        if keep
          lines[first..last] = lines[first+1..last-1].map { |l| dedent(l) }
        else
          if first > 0 and lines[first-1] == "\n"
            first -= 1
          elsif lines[last+1] == "\n"
            last += 1
          end
          lines[first..last] = []
        end
      end
      File.binwrite file, lines.join
    end
  end
end

version = ARGV.fetch(0)
remove_guards(/ruby_version_is ["']#{version}["'] do/, true)
remove_guards(/ruby_version_is ["'][0-9.]*["']...["']#{version}["'] do/, false)
