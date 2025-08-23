defmodule CredoCodeClimateTest do
  use ExUnit.Case, async: true

  @tag :tmp_dir
  test "creates a report file", %{tmp_dir: tmp_dir} do
    Credo.run(~w[
      test/fixtures/issues.ex
        --config-file test/fixtures/.credo.exs
        --report-file #{tmp_dir}/report.json
    ])

    assert file = File.read!(Path.join(tmp_dir, "report.json"))

    assert JSON.decode!(file) == [
             %{
               "check_name" => "Credo.Check.Design.TagTODO",
               "description" => "Found a TODO tag in a comment: # TODO: fix this issue",
               "fingerprint" => "5656F71",
               "location" => %{
                 "path" => "test/fixtures/issues.ex",
                 "positions" => %{
                   "begin" => %{"column" => 5, "line" => 3},
                   "end" => %{"column" => 27}
                 }
               },
               "severity" => "major",
               "categories" => ["Clarity"],
               "content" => %{
                 "body" =>
                   "TODO comments are used to remind yourself of source code related things.\n\nExample:\n\n    # TODO: move this to a Helper module\n    defp fun do\n      # ...\n    end\n\nThe premise here is that TODO should be dealt with in the near future and\nare therefore reported by Credo.\n\nLike all `Software Design` issues, this is just advice and might not be\napplicable to your project/situation.\n"
               },
               "type" => "issue"
             },
             %{
               "check_name" => "Credo.Check.Readability.SinglePipe",
               "description" => "Use a function call when a pipeline is only one function long.",
               "fingerprint" => "99DE45",
               "location" => %{
                 "path" => "test/fixtures/issues.ex",
                 "positions" => %{
                   "begin" => %{"column" => 5, "line" => 5},
                   "end" => %{"column" => 7}
                 }
               },
               "severity" => "critical",
               "categories" => ["Clarity"],
               "content" => %{
                 "body" =>
                   "Pipes (`|>`) should only be used when piping data through multiple calls.\n\nSo while this is fine:\n\n    list\n    |> Enum.take(5)\n    |> Enum.shuffle\n    |> evaluate()\n\nThe code in this example ...\n\n    list\n    |> evaluate()\n\n... should be refactored to look like this:\n\n    evaluate(list)\n\nUsing a single |> to invoke functions makes the code harder to read. Instead,\nwrite a function call when a pipeline is only one function long.\n\nLike all `Readability` issues, this one is not a technical concern.\nBut you can improve the odds of others reading and liking your code by making\nit easier to follow.\n"
               },
               "type" => "issue"
             },
             %{
               "check_name" => "Credo.Check.Warning.IoInspect",
               "description" => "There should be no calls to `IO.inspect/1`.",
               "fingerprint" => "21FEAF4",
               "location" => %{
                 "path" => "test/fixtures/issues.ex",
                 "positions" => %{
                   "begin" => %{"column" => 8, "line" => 5},
                   "end" => %{"column" => 18}
                 }
               },
               "severity" => "critical",
               "categories" => ["Bug Risk"],
               "content" => %{
                 "body" =>
                   "While calls to IO.inspect might appear in some parts of production code,\nmost calls to this function are added during debugging sessions.\n\nThis check warns about those calls, because they might have been committed\nin error.\n"
               },
               "type" => "issue"
             }
           ]
  end
end
