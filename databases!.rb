# :set scrollbind

# Databases!

# Expressions

1                                             # not quite...
[1]                                           # getting closer...
[{:"?column1?" => 1}]                         # SELECT is a query..
[{:"?column1?" => 1}].find_all { |_| true }

# `find_all` vs `select`

[{number: 1}].find_all { true }
[{sum: 1 + 2}].find_all { |_| true }





[{column1: 1}]
[{column1: 1, column2: "one"}]
[{column1: 1, column2: "one"}, {column1: 2, column2: "two"}]








t = [{column1: 1, column2: "one"}, {column1: 2, column2: "two"}]
t.find_all { |_| true }


t = [{num: 1, word: "one"}, {num: 2, word: "two"}]

t.find_all { |_| true }

t.map { |row| {num: row[:num]} }.
  find_all { |_| true }

t.map { |row| {num: row[:num], neg: -row[:num]} }.
  find_all { |_| true }

t.map { |row| {num: row[:num], neg: -row[:num]} }.
  find_all { |row| row[:num] > 1 }


# Cross product

require './table_helper'


v = [{column1: 1}, {column1: 2}]

putt v.find_all { |_| true }





putj v.product(v).find_all { |_| true }























departments = [
  {id: 31, name: 'Sales'},
  {id: 33, name: 'Engineering'},
  {id: 34, name: 'Clerical'},
  {id: 35, name: 'Marketing'}
]

employees = [
  {name: 'Rafferty', department_id: 31, salary: 95000},
  {name: 'Jones', department_id: 33, salary: 85000},
  {name: 'Heisenberg', department_id: 33, salary: 120000},
  {name: 'Robinson', department_id: 34, salary: 65000},
  {name: 'Smith', department_id: 34, salary: 100000},
  {name: 'Williams', department_id: nil, salary: 75000}
]















res = departments.product(employees).
  find_all { |d, e| d[:id] == e[:department_id] }
putj res



















res = departments.product(employees).find_all do |d, e|
  d[:id] == e[:department_id] && d[:name] == "Engineering"
end.map { |d, e| e }
putt res


res = departments.product(employees).find_all do |d, e|
  d[:id] == e[:department_id] && d[:name] == "Engineering"
end.map do |_, employee|
  employee
end.sort { |e1, e2| e2[:salary] <=> e1[:salary] }
putt res

res = departments.product(employees).find_all do |d, e|
  d[:id] == e[:department_id] && d[:name] == "Engineering"
end.map do |_, employee|
  employee
end.sort do |e1, e2|
  e2[:salary] <=> e1[:salary]
end.take(1)
putt res

res = employees.product(departments).find_all do |e, d|
  e[:department_id] == d[:id] || e[:department_id] == nil
end
putj res






