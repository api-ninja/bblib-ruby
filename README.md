# BBLib

BBLib (Brandon-Black-Lib) is a collection of various reusable methods and classes to extend the Ruby language. One of the primary goals with the BBLib is to keep it as lightweight as possible. This means you will not find dependencies outside of the Ruby core libraries.

Good news! BBLib is now compatible with Opal! Well, like 90% compatible, but it can be 100% compiled into Javascript. Only very small tweaks were made to support this, so base functionality for the BBLib outside of Opal remains the same. But now it can coexist as both a Ruby gem, and an Opal library.

BBLib contains A LOT of functionality, but is a very small, lightweight library. As such, it can be hard to document everything that is included (and even harder to make a TL:DR version). Continue scrolling for a comprehensive view of what is offered, or take a look at the highlights below for the library's most significant features.

* __HashPath:__ Hash path is an XPath or JSONPath like navigation library for native Ruby hashes. It uses dot ('.') delimited path strings to navigate hash AND array objects. What makes hash path stand out is that it can navigate recursively within both hashes and arrays, including nested hashes/arrays (as deep as they can go!). It isn't only for navigating hashes; it can also copy, move, delete and run various methods using the same path notation.

```ruby
myhash = {a:1, b:2, c:{d:[3,4,{e:5},6]}, f:7}
p myhash.hash_path('c.d..e')
# => [5] - !!Hash Path always returns an array!!
p myhash.hash_path('..e')
# => [5]
p myhash.hash_path('c.d.[1]')
# => [4]
p myhash.hash_path('c.d.[0..1]')
# => [3, 4]

# Hash Path also supports formulas (evaluation statements)
# Formulas are surrounded in parenthesis following a path name
# A $ can be used to specify where in the eval statement to inject the variable

myarray = [
  {title: 'Catan', cost: 41.99},
  {title: 'Mouse Trap', cost: 5.50},
  {title: 'Chess', cost: 25.99}
]

p myarray.hpath('[0..-1]($[:cost] > 10).title') # hpath is a shorter alias for hash_path
# => ["Catan", "Chess"]

# Move key/values
p myhash.hash_path_move('a' => 'c.g.h')
# => {:b=>2, :c=>{:d=>[3, 4, {:e=>5}, 6], :g=>{:h=>1}}, :f=>7}

# Copy key/values
p myhash.hash_path_copy('b' => 'z')
# => {:a=>1, :b=>2, :c=>{:d=>[3, 4, {:e=>5}, 6]}, :f=>7, :z=>2}
```
* __Deep Merge:__ A deep merge algorithm is included that can merge hashes with nested hashes or nested arrays or nested hashes with nested arrays with nested hashes and so on... It can also combine colliding values into arrays rather than overwriting using a toggle-able overwrite flag.
* __File & Time Parsing From Strings:__ Have a string such as '1MB 15KB' and want to make it numeric? Look no further. BBLib has methods to parse files size expressions and duration expressions from strings (like '1min 10sec'). Nearly any variant of size or duration expression is supported. For instance, '1sec', '1s', '1 s', '1 second', '1secs' are all properly parsed as 1 second.
* __Fuzzy String Matching:__ The BBLib has implementations of a few string comparison algorithms. Most noteworthy, it features a simple implementation of the Levenshtein distance algorithm. A class, FuzzyMatcher, is also included to perform weight comparisons of strings using any of the included algorithms.
* __Convert Roman Numerals__ within strings to Integers and Integers to Roman Numerals.
* __Normalize articles__ such as 'the', 'an' and 'a' within titles to be displayed in the front, back or be stripped entirely. Helpful for sorting titles or for string comparisons.
* __Object to Hash:__ Turn any object and its instance variables as well as nested objects and their instance variables into a hash. Handy to have alongside hash path.
* __TaskTimer:__ A simple and easy to use timer class to compliment benchmarking in code by timing various tasks or groups of tasks. History is kept so that averages, sums, mins and maxes can be checked per task.
* __Recursive File Scanners:__ A few file and directory scanners are implemented that recursively (by toggle) scan directories looking for files matching given filters.
* __Plus more...__

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bblib'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bblib

## Usage

### File
#### File Scanners

Various simple file scan methods are available. All of these are toggleable-recursive and can be passed filters using any wildcarding supported by the Ruby Dir.glob() method.

```ruby
# Scan for any files or folders in a path
BBLib.scan_dir 'C:/path/to/files'

#=> 'C:/path/to/files/readme.md'
#=> 'C:/path/to/files/license.txt'
#=> 'C:/path/to/files/folder/'
```

If you need only files or dirs but not both, the following two convenience methods are also available:
```ruby
# Scan for files ONLY
BBLib.scan_files 'C:/path/to/files'

#=> 'C:/path/to/files/readme.md'
#=> 'C:/path/to/files/license.txt'

# Scan for folders  ONLY
BBLib.scan_dirs 'C:/path/to/files'

#=> 'C:/path/to/files/folder/'
```

All of the scan methods also allow for the following named arguments:
* **recursive**: Default is false. Set to true to recursively scan directories
* **filter**: Default is nil. Can take either a String or Array of Strings. These strings will be used as filters so that only matching files or dirs are returned (Ex: '*.jpg', which would return all jpg files.)

```ruby
# Scan for any 'txt' or 'jpg' files recursively in a dir
BBLib.scan_dir 'C:/path/to/files', recursive: true, filter: ['*.jpg', '*.txt']

#=> 'C:/path/to/files/license.txt'
#=> 'C:/path/to/files/folder/profile.jpg'
#=> 'C:/path/to/files/folder/another_folder/text.txt'
```

In addition, both _scan_files_ and _scan_dirs_ also support a **mode** named argument. By default, this argument is set to :path. In _scan_files_ if :file is passed to :mode, a ruby File object will be returned rather than a String representation of the path. Similarly, if :dir is passed to _scan_dirs_ a ruby Dir object is returned, rather than just a string.

#### File Size Parsing

A file size parser is available that analyzes known patterns in a string to construct a numeric file size. This is very useful for parsing the output from outside applications or from web scrapers.

```ruby
# Turn a string into a file size (in bytes)
BBLib.parse_file_size "1MB 100KB"
#=> 1150976.0
```

By default the output is in bytes, however, this can be modified using the named argument **output**.

```ruby
# Turn a string into a file size (in bytes)
BBLib.parse_file_size "1MB 100KB", output: :megabyte
#=> 1.09765625

# The method can also be called directly on a string
"1.5 Mb".parse_file_size output: :kilobyte
#=> 1536.0
```

All of the following are options for output:
* :byte
* :kilobyte
* :megabyte
* :gigabyte
* :terabtye
* :petabtye
* :exabtye
* :zettabtye
* :yottabtye

Additionally, ANY matching pattern in the string is added to the total, so a string such as "1MB 1megabyte" would yield the equivalent of "2MB". File sizes can also be intermingled with any other text, so "The file is 2 megabytes in size." would successfully parse the file size as 2 megabytes.

#### Other Methods

**string_to_file**

This method is a convenient way to write a string to disk as file. It simply takes a path and a string. By default if the path does not exist it will attempt to create it. This can be controlled using the mkpath argument.

```ruby
# Write a string to disk
string = "This is my wonderful string."
BBLib.string_to_file '/home/user/my_file', string

# OR to avoid the creation of the path if it doesn't exist:

BBLib.string_to_file '/home/user/my_file', string, false

# OR call the method directly on the string

string.to_file '/home/user/another_file', true
```



### Hash

#### Deep Merge

A simple implementation of a deep merge algorithm that merges two hashes including nested hashes within them. It can also merge arrays (default) within the hashes and merge values into arrays (not default) rather than overwriting the values with the right side hash.

Part of the code is based on information found @ http://stackoverflow.com/questions/9381553/ruby-merge-nested-hash

```ruby
h1 = ({value: 1231, array: [1, 2], hash: {a: 1, b_hash: {c: 2, d:3}}})
h2 = ({value: 5, array: [6, 7], hash: {a: 1, z: nil, b_hash: {c: 9, d:10, y:10}}})

# Default behavior merges arrays and overwrites non-array/hash values
h1.deep_merge h2
#=> {:value=>5, :array=>[1, 2, 6, 7], :hash=>{:a=>1, :b_hash=>{:c=>9, :d=>10, :y=>10}, :z=>nil}}

# Don't overwrite colliding values, instead, place them into an array together
h1.deep_merge h2, overwrite_vals: false
#=> {:value=>[1231, 5], :array=>[1, 2, 6, 7], :hash=>{:a=>[1, 1], :b_hash=>{:c=>[2, 9], :d=>[3, 10], :y=>10}, :z=>nil}}

# Don't merge arrays, instead, overwrite them.
h1.deep_merge h2, merge_arrays: false
#=> {:value=>5, :array=>[6, 7], :hash=>{:a=>1, :b_hash=>{:c=>9, :d=>10, :y=>10}, :z=>nil}}
```

A ! version of _deep_merge_ is also available to modify the hash in place rather than returning a new hash.

#### Keys To Sym

Convert all keys within a hash (including nested keys) to symbols. This is useful after parsing json if you prefer to work with symbols rather than strings. An in-place (**!**) version of the method is also available.

```ruby
h = {"author" => "Tom Clancy", "books" => ["Rainbow Six", "The Hunt for Red October"]}
h.keys_to_sym
#=> {:author=>"Tom Clancy", :books=>["Rainbow Six", "The Hunt for Red October"]}
```

_Note: This is similar to what Rails provides, except it even converts keys within nested hashes or nested arrays that contain nested hashes._

#### Keys To Str

The same as keys to sym, but it converts keys to strings rather than symbols.

#### Reverse

Similar to reverse for Array. Calling this will reverse the current order of the Hash's keys. An in place version is also available.

The code behind this is based on a method found @ http://stackoverflow.com/questions/800122/best-way-to-convert-strings-to-symbols-in-hash

```ruby
h = {a:1, b:2, c:3, d:4}
h.reverse
#=> {:d=>4, :c=>3, :b=>2, :a=>1}
```

### Array

#### Interleave

Interleave takes two arrays and pieces them together by grabbing alternating elements from both arrays.

```ruby
a = ['This', 'a', '.']
b = ['is', 'test']

p BBLib.interleave a, b
# OR
p a.interleave b
#=> ["This", "is", "a", "test", "."]
```

### Numeric

#### Keep Between

Used to ensure a numeric value is kept within a set of bounds. The first argument is the number, the second is the minimum of the bounds and the second is the maximum. To specify no min or max simply pass nil as either of the bounds.

```ruby
number = 17
BBLib.keep_between number, 0, 10
#=> 10

number = 0.145
BBLib.keep_between number, 0.5, 1
#=> 0.5

number = -250
BBLib.keep_betwee number, nil, 100
#=> -250
```



### String

#### FuzzyMatcher

FuzzyMatcher (BBLib::FuzzyMatcher) is a class for making fuzzy comparisons with strings. It implements a weighted algorithm system which uses the algorithms listed below to generate a percentage based match between two strings. There are various settings that can be toggled in addition. These settings are:

* **Case Sensitive**: Toggles whether or not strings should be compared in a case sensitive manor.
* **Remove Symbols**: Toggle to remove all symbols from the strings before comparing them.
* **Move Articles**: Toggling this normalizes the position on preceding or trailing articles (the, an, a).
* **Convert Roman**: When toggled to true, all roman numerals found in the strings are converted to integers.

Current algorithms are:
* Levenshtein
* Composition
* Phrase
* Numeric

```ruby
# Create a FuzzyMatcher and set it to be case insensitive
fm = BBLib::FuzzyMatcher.new case_sensitive: false

# Set the weight of two of the algorithms. A weight of zero effectively turns off that algorithm.
fm.set_weight :levenshtein, 10
fm.set_weight :composition, 5

# Get similarity as a %
fm.similarity 'Ruby', 'Rails'
#=> 20.0

# Set the threshold match percent
fm.threshold = 50
# Returns true if the match percent is greater than or equal to the threshold
fm.match? 'Ruby', 'Rails'
#=> false

# Get the similarity of a string with an Array of strings. A hash is returned
# with the key being the string compared and the value being its match %
fm.similarities 'Ruby', ['Ruby', 'Rails', 'Java', 'C++']
#=> {"Ruby"=>100.0, "Rails"=>20.0, "Java"=>0.0, "C++"=>0.0}

# Compare a string to an Array of strings but return only the match with the highest comparison result
fm.best_match 'Ruby', ['Ruby', 'Rails', 'Java', 'C++']
#=> 'Ruby'
```


#### String Comparisons

**ALGORITHIMS**

Implementations of the following algorithms are currently available. All algorithms are for calculating similarity between strings. Most are useful for fuzzy matching. All algorithms are available statically in the BBLib module but are also available as extensions to the String class. Most of these algorithms are case sensitive by default.

__1 - Levenshtein Distance__

A fairly simple rendition of the Levenshtein distance algorithm in Ruby. There are two functions available: **levenshtein_distance** and **levenshtein_similarity**. The former, calculates the number of additions, removals or substitutions needed to turn one string into another. The latter, uses the distance to calculate a percentage based match of two strings.

```ruby
# Get the Levenshtein distance of two strings
'Ruby is great'.levenshtein_distance 'Rails is great'
#  OR
BBLib.levenshtein_distance 'Ruby is great', 'Rails is great'
#=> 4

# Or calculate the similarity as a percent
'Ruby is great'.levenshtein_similarity 'Rails is great'
#=> 71.42857142857143
```

__2 - String Composition__

Compares the character composition of two strings. The order of characters is not relevant, however, the number of occurrences is factored in.

```ruby
'Ruby is great'.composition_similarity 'Rails is great'
#=> 71.42857142857143
```

__3 - Phrase Similarity__

Checks to see how many words in a string match another. Words must match exactly, including case. The results is the percentage of words that have an exact pair. The number of occurrences is also a factor.

```ruby
'Learn Ruby, it is great'.phrase_similarity 'Learn Rails; it is awesome'
#=> 60.0

'ruby, ruby, ruby'.phrase_similarity 'ruby ruby'
#=> 66.66666666666666
```

__4 - Numeric Similarity _(In Progress)_ __

This algorithm is currently undergoing refactoring...

This is primarily for comparing titles (such as movie or game titles). As an example, other algorithms would conclude that _'Terminator 2'_ is more similar to _'Terminator'_ than _'Terminator 2: Judgement Day'_, but the best match may really be _'Terminator 2: Judgement Day'_. To fix this, the numeric similarity would weight more towards the more appropriate title that contains the same number or numbers as itself. A string with no numbers is effectively considered to include a 1 for comparison's sake.

```ruby
a = 'Terminator 2'
b = 'Terminator 2: Judgement Day'
c = 'Terminator'

puts a.levenshtein_similarity c
#=> 83.33333333333334
puts a.numeric_similarity c
#=> 33.33333333333333

puts a.levenshtein_similarity b
#=> 44.44444444444444
puts a.numeric_similarity b
#=> 100.0
```
This algorithm is generally only useful when combined with another algorithm, which is exactly what the FuzzyMatcher class does.

__5 - QWERTY Similarity__

A basic method that compares two strings by measuring the physical difference from one char to another on a QWERTY keyboard (alpha-numeric only). May be useful for detecting typos in words, but becomes less useful depending on the length of the string. This method is still in development and not yet in a final state. Currently a total distance is returned. Eventually, a percentage based match will replace this.

```ruby
'q'.qwerty_distance 's'
#=> 2

'qwerty'.qwerty_distance 'qsertp'
#=> 5
```

#### Roman Numeral

**to_roman**

Converts an integer into a roman numeral. Supports numbers up to 1000 ('M'). Anything greater will simply return a string version of the integer. Can be called directly on any Fixnum object as well as from the BBLib module.

```ruby
BBLib.to_roman 20
#=> 'XX'

15.to_roman
#=> 'XV'
```

**string_to_roman**

Converts any integers found in a string into their roman numeral equivalent. Numbers will only be converted if they are surrounded by white space or by symbols. If the integer is embedded within alpha characters or contains a decimal, it is left untouched.

The method is also extended to the String class to be called directly.

```ruby
BBLib.string_to_roman "Toy Story 3"
#= "Toy Story III"

"Die Hard 2: Die Harder".to_roman
#=> "Die Hard II: Die Harder"

"Left4Dead".to_roman
#=> "Left4Dead"

"Ruby 2.2".to_roman
#=> "Ruby 2.2"
```

**from_roman**

The opposite of _string_to_roman_. Parses a string for roman numerals and converts them into integers. Also extended to the String class to call directly. Works similarly to _to_roman_ in that numerals are converted only if surrounded by white space or symbols.

```ruby
BBLib.from_roman "Toy Story III"
#=> 'Toy Story 3'

"Super Mario Land II: Six Golden Coins".from_roman
#=> 'Super Mario Land 2: Six Golden Coins'

"Donkey Kong CountryIII".from_roman
#=> 'Donkey Kong CountryIII'
```

#### Case Converters

Some basic case converters are now available. The majority of these are complete but not heavily tested, so some bugs or edge cases may exist.

Case supported:
* Title Case
* Start Case
* Camel Case
* Snake Case
* Spinal Case
* Train Case
* Delimited Case

Each case may be called directly on a string or using class methods in the BBLib module.

```ruby
sent = 'This is a casing-test. OK?'

puts sent.title_case
#=> This Is a Casing-Test. Ok?

puts sent.start_case
#=> This Is A Casing-Test. Ok?

puts sent.snake_case
#=> This_is_a_casing_test_OK

puts sent.spinal_case
#=> This-is-a-casing-test-OK

puts sent.train_case
#=> This-Is-A-Casing-Test-Ok

puts sent.delimited_case '+'
#=> This+is+a+casing+test+OK

# By default when title casing or start casing, the capitalize method is used on each word.
# This results in characters following the first to be downcased. To avoid this, the first_only param can be used.
# This param prevents all other chars in a word from being processed.
puts 'i like SQL'.title_case
#=> 'I Like Sql'

puts 'i like SQL'.title_case first_only: true
#=> I Like SQL
```

#### Other

**msplit** _aka multi split_

_msplit_ is similar to the String method split, except it can take an array of string delimiters rather than a single delimiter. The string is split be each delimiter in order and an Array is returned. msplit may also be called on an array to split elements within it.

```ruby
"This_is.a&&&&test".msplit '_', '.', '&'

#=> ['This', 'is', 'a', 'test']
```

By default any empty items from the returned Array are removed. This behavior can be changed using the _:keep_empty_ named param.

```ruby
"This_is.a&&&&test".msplit ['_', '.', '&'], keep_empty: true

#=> ['This', 'is', 'a', '', '', '', 'test']
```

**move_articles**

This method is used to normalize strings that contain titles. It parses a string and checks to see if _the_, _an_ or _a_ are in the title, either preceding or trailing. If they are found they are moved to the front, back or removed depending on the argument passed to _position_.

The method is available via the BBLib module or any instance of String.

```ruby
title = "The Simpsons"
title.move_articles :back
#=> "Simpons, The"

title.move_articles :none
#=> "Simpsons"

title = "Day to Remember, A"
title.move_articles :front
#=> "A Day to Remember"
```

**extract_integers**/**extract_floats**/**extract_numbers**

Three methods to grab numbers from within strings. Integers only nabs numbers with no decimal places, floats gets only numbers with a decimal and numbers gets both integers and floats. The numbers must also be properly formatted, so something like the version number '2.1.1' below will not be extracted.

```ruby
s = 'Test 10 2.5 Number 100 aaaa 10.113 Version 2.1.1'

p s.extract_integers
#=> [10, 100]
p s.extract_floats
#=> [2.5, 10.113]
p s.extract_numbers
#=> [10, 2.5, 100, 10.113]
```

### Time

#### Cron

BBLib includes a lightweight cron syntax parser. It can be used to display the runtimes of a cron based on a cron string. Nearly every variant of cron syntax is supported with the ability to intermix ranges, divisors and explicit numbers in the same interval placing.

```ruby

cron = BBLib::Cron.new('* * * * * *')
puts cron.next
#=> 2016-04-03 22:01:00 -0600

puts cron.previous
#=> 2016-04-03 21:59:00 -0600

p cron.next(5)
#=> [2016-04-03 22:01:00 -0600, 2016-04-03 22:02:00 -0600, 2016-04-03 22:03:00 -0600, 2016-04-03 22:04:00 -0600, 2016-04-03 22:05:00 -0600]

# Set the time explicitly. The default is the current system time.
puts cron.next(time: Time.now+30)
#=> 2016-04-03 22:31:00 -0600
```

An instantiated Cron object is not necessary to get the next and previous times.

```ruby
puts BBLib::Cron.next('* * * * * *')
#=> 2016-04-03 22:04:00 -0600

puts BBLib::Cron.next('0-5 * * * * *')
#=> 2016-04-03 22:04:00 -0600

puts BBLib::Cron.next('0 1 1 1 1 *')
#=> 2018-01-01 01:00:00 -0700

puts BBLib::Cron.next('1 1 1-5 * * 2020')
#=> 2020-01-01 01:01:00 -0700

puts BBLib::Cron.next('*/5 * * * * *')
#=> 2016-04-03 22:05:00 -0600

puts BBLib::Cron.next('1-3,4,5,10-11 1-10 */5 * * *')
#=> 2016-04-06 01:01:00 -0600
```

Named days of the week and month are also supported in various formats and can be used in ranges or comma separated lists. They can even the intermingled with numbers such as 'Jun-9'.

```ruby
puts BBLib::Cron.next('* * * * sun *')
#=> 2016-04-10 00:00:00 -0600

puts BBLib::Cron.next('* * * * sunday *')
#=> 2016-04-10 00:00:00 -0600

puts BBLib::Cron.next('* * * * sun,sat *')
#=> 2016-04-09 00:00:00 -0600

puts BBLib::Cron.next('* * * Jun-Dec * *')
#=> 2016-06-01 00:00:00 -0600

# The next Friday the 13th in December
puts BBLib::Cron.next('* * 13 Dec Fri *')
#=> 2019-12-13 00:00:00 -0700

# The next leap year
puts BBLib::Cron.next('* * 29 February * *')
#=> 2020-02-29 00:00:00 -0700

# The next Feb 29th that also happens to be a Monday
puts BBLib::Cron.next('* * 29 February Monday *')
#=> 2044-02-29 00:00:00 -0700
```

Common Vixie-isms are also supported:

```ruby
puts BBLib::Cron.next('@daily')
#=> 2016-04-04 00:00:00 -0600

puts BBLib::Cron.next('@weekly')
#=> 2016-04-10 00:00:00 -0600
```

_Supported list of Vixie-isms: @daily, @midnight, @noon, @weekly, @monthly, @yearly, @annually_
_Note: @reboot and @restart can be parsed but are inaccurate due to the fact that they have no way of knowing the next reboot._

#### Duration parser

**Parsing a duration from String**

Similar to the file size parser under the files section, but instead can parse duration from know time patterns in a string. By default the result is returned in seconds, but this can be changed using the named param _:output_. The method is also extended to the String class directly.

```ruby
"1hr 10 minutes 11s".parse_duration

#=> 4211.0

"1hr 10 minutes 11s".parse_duration output: :hour

#=> 1.1697222222222223
```
Output options are:
* :yocto
* :zepto
* :atto
* :femto
* :pico
* :nano
* :micro
* :milli
* :sec
* :min
* :hour
* :day
* :week
* :month
* :year

__WARNING:__ _time intervals below microseconds are prone to heavy rounding errors in the current implementation. They are NOT EXACT._

The colon separated duration pattern (eg. '02:30') can also be matched. The last set of digits is treated as seconds with each prior number being one interval greater. The default starting interval can be changed using the __min_interval__ named param. The available options are the same as the output options. This pattern type can even be intermixed with the types shown above and will be added to the total duration.

```ruby
duration = '04:35'

puts duration.parse_duration
#=> 275.0

puts duration.parse_duration min_interval: :min
#=> 16500.0
```

**Create a duration String from Numeric**

There is also a method to turn a Numeric object into a string representation of a duration. This method is extended to the Numeric class. An input may be specified to tell the method what the input number represents. The options for this are the same as the output options listed above. A stop can be added using any of those same options. This will prevent the string from containing anything below the specified time type. For instance, specifying _stop: :sec_ will prevent milliseconds from being included if there are any. There are also three options that can be passed to the _:style_ argument to change the output (options are _:full_, _:medium_ and _:short:).

```ruby
9645.to_duration
#=> '2 hrs 40 mins 45 secs'

101.to_duration input: :hour
#=> '4 days 5 hrs'

20.56.to_duration input: :hour, style: :full
#=> '20 hours 33 minutes 36 seconds'

20.56123.to_duration input: :hour, style: :medium, stop: :min
#=> '20 hrs 33 mins'

123124.to_duration( style: :short)
#=> '34h 12m 4s'
```

#### Task Timer

A very simple task timer is also included. It is not intended to replace benchmarking classes but rather to augment or be used for simplistic timing. You simply need to instantiate a timer and then call start with the name of the task. To stop the timer, call stop and pass in the same task name. Once a single time has been completed for any given task a few different metrics can be pulled on that task. These metrics may also be printed in bulk using the _stats_ method.

```ruby
# Generate a new timer object
t = BBLib::TaskTimer.new

# Call start right before initiating a task and stop immediately after.
5.times do
  t.start :random_sleep
  # Perform task...
  sleep(rand())
  t.stop :random_sleep
end

# Print out the stats from the task
puts t.stats :random_sleep
#=> random_sleep
#=> ------------------------------
#=> Count     5
#=> First     0.3134028911590576
#=> Last      0.5248761177062988
#=> Min       0.20781898498535156
#=> Max       0.9016561508178711
#=> Avg       0.4677897930145264
#=> Sum       2.338948965072632

# Same as above but cnverts seconds into human readable time durations.
# The pretty argument may also be applied to individual stat calls such as avg, sum, min, max, etc...
puts t.stats :random_sleep, pretty: true
#=> random_sleep
#=> ------------------------------
#=> Count     5
#=> First     313 mils
#=> Last      525 mils
#=> Min       208 mils
#=> Max       902 mils
#=> Avg       468 mils
#=> Sum       2 secs 339 mils

# Similar to the above task, this version uses a restart which stops the first start call and initiates a new timer
t.start :another_task
5.times do
  sleep(rand())
  t.restart :another_task
end

# Get the individual average stat for another task. Method calls are aliases so you could also use .average or .av to get the average.
puts t.avg :another_task
#=> 0.5790667057037353
```

By default the task timer will only keep the stats from 100 runs of each task it tracks. The retention can be increased or decreased using the _retention_ method. Also, call stop will return the total time the stopped task ran.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bblack16/bblib. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
