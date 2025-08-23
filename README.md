# CredoCodeClimate

Credo plugin for writing the CodeClimate-like report file.

This plugin generates a CodeClimate-like report file used by [GitLab Code Quality](https://docs.gitlab.com/ci/testing/code_quality/).

## Installation
Add `credo_codeclimate` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:credo_codeclimate, github: "wigny/credo_codeclimate", tag: "0.1.0", only: [:dev, :test], runtime: false}
  ]
end
```

Add the plugin to your `.credo.exs` config file:
```elixir
%{
  configs: [
    %{
      name: "default",
      plugins: [
        {CredoCodeClimate, report_file: "./gl-code-quality-report.json"}
      ]
    }
  ]
}
```
