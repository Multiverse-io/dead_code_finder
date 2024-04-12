defmodule DeadCodeFinder do
  alias DeadCodeFinder.AliasImportRequire

  def find do
    {:ok, modules} = :application.get_key(:dead_code_finder, :modules)

    # modules = [hd(modules)]

    _modules =
      Map.new(modules, fn module ->
        functions = module.__info__(:functions)
        file_path = Keyword.fetch!(module.__info__(:compile), :source)
        file = File.read!(file_path)
        IO.inspect(file)
        raise "no"
        _alias_import_requires = AliasImportRequire.find(file)
        {module, %{functions: functions, file_path: file_path}}
      end)
      |> IO.inspect()
  end
end
