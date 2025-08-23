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
               "fingerprint" => "05656F71",
               "location" => %{"lines" => %{"begin" => 3}, "path" => "test/fixtures/issues.ex"},
               "severity" => "major"
             },
             %{
               "check_name" => "Credo.Check.Readability.SinglePipe",
               "description" => "Use a function call when a pipeline is only one function long.",
               "fingerprint" => "0099DE45",
               "location" => %{"lines" => %{"begin" => 5}, "path" => "test/fixtures/issues.ex"},
               "severity" => "critical"
             },
             %{
               "check_name" => "Credo.Check.Warning.IoInspect",
               "description" => "There should be no calls to `IO.inspect/1`.",
               "fingerprint" => "021FEAF4",
               "location" => %{"lines" => %{"begin" => 5}, "path" => "test/fixtures/issues.ex"},
               "severity" => "critical"
             }
           ]
  end
end
