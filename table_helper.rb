def base_putt(names, rows)
  headers = names.map { |c| " #{c}" }

  columns = rows.first.size.times.map do |i|
    rows.map { |row| row[i] }
  end

  columns_with_headers = headers.zip(columns).map(&:flatten)

  max_lengths = columns_with_headers.map do |c|
    c.map { |o| o.to_s.size }.max
  end

  headers_with_padding = headers.zip(max_lengths).map do |h, max_length|
    sprintf("%*s", max_length, h)
  end

  puts headers_with_padding.join(" |")
  puts headers_with_padding.map { |c| "-" * (c.length + 1) }.join("+")

  row_strings = rows.map do |row|
    row.zip(max_lengths).map do |val, max_length|
      sprintf("%*s", max_length, val.to_s)
    end.join(" |")
  end

  puts row_strings
end

def putt(t)
  names = t.first.keys
  rows = t.map(&:values)

  base_putt(names, rows)
end

def putj(t)
  names = t.first.map(&:keys).reduce(:+)
  rows = t.map do |joins|
    joins.map(&:values).reduce(:+)
  end

  base_putt(names, rows)
end
