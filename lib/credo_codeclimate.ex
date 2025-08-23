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
        type: "issue",
        check_name: Credo.Code.Name.full(issue.check),
        description: issue.message,
        content: %{body: issue.check.explanations()[:check]},
        categories: List.wrap(category(issue.check.category())),
        location: %{
          path: issue.filename,
          positions: %{
            begin: %{line: issue.line_no, column: issue.column || 1},
            end: %{column: column_end(issue.column, issue.trigger)}
          }
        },
        severity: severity(issue.priority),
        fingerprint: Integer.to_string(:erlang.phash2(issue), 16)
      }
    end

    defp severity(priority) when is_number(priority) do
      cond do
        priority > 19 -> :blocker
        priority in 10..19 -> :critical
        priority in 0..9 -> :major
        priority in -10..-1 -> :minor
        priority < -10 -> :info
      end
    end

    defp category(category) do
      case category do
        :warning -> "Bug Risk"
        :readability -> "Clarity"
        :refactor -> "Complexity"
        :design -> "Clarity"
        :consistency -> "Style"
        :unknown -> nil
      end
    end

    defp column_end(column, trigger) do
      if column && trigger do
        column + String.length(to_string(trigger))
      end
    end
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
