defmodule Unix do
  def ps_ax do
    """
  PID TTY      STAT   TIME COMMAND
 8544 ?        S      0:00 [kworker/u:1]
10919 pts/4    Sl+    0:14 vim 016_Pipe_Operator.markdown
10941 pts/5    Ss     0:00 -bash
13936 pts/5    Sl+    0:00 vim test/pipe_operator_playground_test.exs
14422 ?        S      0:00 sleep 3
    """
  end

  def grep(input, match) do
    lines = String.split(input, "\n")
    Enum.filter(lines, fn(line) -> Regex.match?(%r/#{match}/, line) end)
  end

  def awk(lines, column) do
    Enum.map(lines, fn(line) ->
      stripped = String.strip(line)
      columns = Regex.split(%r/ /, stripped, trim: true)
      Enum.at(columns, column-1)
    end)
  end
end

defmodule PipeOperatorPlaygroundTest do
  use ExUnit.Case

  test "ps_ax outputs some processes" do
    output = """
  PID TTY      STAT   TIME COMMAND
 8544 ?        S      0:00 [kworker/u:1]
10919 pts/4    Sl+    0:14 vim 016_Pipe_Operator.markdown
10941 pts/5    Ss     0:00 -bash
13936 pts/5    Sl+    0:00 vim test/pipe_operator_playground_test.exs
14422 ?        S      0:00 sleep 3
    """
    assert Unix.ps_ax == output
  end

  test "grep(thing) returns lines that match 'thing'" do
    input = """
    foo
    bar
    thing foo
    baz
    thing qux
    """
    output = ["thing foo", "thing qux"]
    assert Unix.grep(input, 'thing') == output
  end

  test "awk(1) splits on whitespace and returns the first column" do
    input = ["foo bar", "  baz    qux "]
    output = ["foo", "baz"]
    assert Unix.awk(input, 1) == output
  end

  test "the whole pipeline works" do
    assert (Unix.ps_ax |> Unix.grep('vim') |> Unix.awk(1)) == ["10919", "13936"]
  end
end
