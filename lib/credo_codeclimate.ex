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

      formatted_issues =
        exec
        |> Execution.get_issues()
        |> Enum.filter(&new_issue?/1)
        |> Enum.map(&format/1)

      File.write!(filepath, JSON.encode_to_iodata!(formatted_issues))

      exec
    end

    defp new_issue?(%{diff_marker: diff}) when diff in [:new, nil], do: true
    defp new_issue?(_issue), do: false

    defp format(issue) do
      check_name = Credo.Code.Name.full(issue.check)
      priority = Credo.Priority.to_atom(issue.priority)
      hash = :erlang.phash2({check_name, priority, issue.filename, issue.line_no})

      %{
        type: "issue",
        check_name: check_name,
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
        severity: severity(priority),
        fingerprint: Integer.to_string(hash, 16)
      }
    end

    defp severity(:higher), do: :blocker
    defp severity(:high), do: :critical
    defp severity(:normal), do: :major
    defp severity(:low), do: :minor
    defp severity(:ignore), do: :info

    defp category(:warning), do: "Bug Risk"
    defp category(:readability), do: "Clarity"
    defp category(:refactor), do: "Complexity"
    defp category(:design), do: "Clarity"
    defp category(:consistency), do: "Style"
    defp category(:unknown), do: nil

    defp column_end(column, trigger) do
      if column && trigger do
        column + String.length(to_string(trigger))
      end
    end
  end

  import Credo.Plugin
  alias Credo.CLI.Command

  @doc false
  def init(exec) do
    exec
    |> register_cli_switch(:report_file, :string)
    |> append_task(Command.Suggest.SuggestCommand, :print_after_analysis, GenerateReport)
    |> append_task(Command.Diff.DiffCommand, :print_after_analysis, GenerateReport)
  end
end
