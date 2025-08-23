defmodule CredoCodeClimate do
  @moduledoc """
  Credo plugin for writing the CodeClimate-like report file.
  """

  defmodule GenerateReport do
    @moduledoc false

    use Credo.Execution.Task

    def call(exec, _opts) do
      filepath =
        Execution.get_plugin_param(exec, CredoCodeClimate, :report_file) || "codeclimate.json"

      formatted_issues = Enum.map(Execution.get_issues(exec), &format/1)

      File.write!(filepath, JSON.encode_to_iodata!(formatted_issues))

      exec
    end

    defp format(issue) do
      %{
        description: issue.message,
        check_name: String.trim_leading(to_string(issue.check), "Elixir."),
        fingerprint: Base.encode16(<<:erlang.phash2(issue)::integer-size(32)>>),
        severity: severity(issue.priority),
        location: %{
          path: issue.filename,
          lines: %{begin: issue.line_no}
        }
      }
    end

    defp severity(priority) when priority > 19, do: "blocker"
    defp severity(priority) when priority in 10..19, do: "critical"
    defp severity(priority) when priority in 0..9, do: "major"
    defp severity(priority) when priority in -10..-1, do: "minor"
    defp severity(priority) when priority < -10, do: "info"
  end

  import Credo.Plugin

  @doc false
  def init(exec) do
    exec
    |> register_cli_switch(:report_file, :string)
    |> append_task(
      Credo.CLI.Command.Suggest.SuggestCommand,
      :print_after_analysis,
      GenerateReport
    )
  end
end
