defmodule DeadCodeFinder do
  alias DeadCodeFinder.AliasImportRequire

  def find do
    :dead_code_finder
    |> Application.get_env(:applications)
    |> Enum.reduce([], fn application, acc ->
      {:ok, modules} = :application.get_key(application, :modules)
      acc ++ modules
    end)
    |> Map.new(fn module ->
      functions = module.__info__(:functions)
      # file_path = Keyword.fetch!(module.__info__(:compile), :source)
      file_path =
        :compile
        |> module.__info__()
        |> Keyword.fetch!(:source)
        |> to_string()

      file = File.read!(file_path)

      module_stats =
        Map.merge(
          %{functions: functions, file_path: file_path},
          AliasImportRequire.find(file)
        )

      {module, module_stats}
    end)
  end
end
