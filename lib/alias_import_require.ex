defmodule DeadCodeFinder.AliasImportRequire do
  def find(file) do
    file
    |> String.split("\n", trim: true)
    |> find(%{alias: [], import: [], require: []})
  end

  defp find([], acc) do
    Map.update!(acc, :alias, &Enum.reverse(&1))
  end

  defp find([line | rest], acc) do
    find(rest, acc)

    # case Regex.run(~r|^\s*alias ([^{\s,]+)|
    case Regex.run(~r|^\s*alias (.*)|, line, capture: :all_but_first) do
      nil ->
        find(rest, acc)

      [alias] ->
        aliased_module = Module.concat([alias])
        find(rest, Map.update!(acc, :alias, &[aliased_module | &1]))
    end
  end

  # defp find([line | rest], acc, mode) do
  #  alias_regexes()
  #  |> Enum.reduce_while(nil, fn regex, _ ->
  #    case Regex.run(regex, line, capture: :all_but_first) do
  #      nil ->
  #        {:cont, nil}

  #      [alias] ->
  #        {:halt, [Module.concat([alias])]}

  #      [namespace | aliases] ->
  #        IO.inspect(namespace)
  #        IO.inspect(aliases)
  #        raise "nO"
  #        {:halt, nil}
  #    end
  #  end)
  #  |> case do
  #    nil ->
  #      find(rest, acc, mode)

  #    aliases ->
  #      find(rest, Map.update!(acc, :alias, &(&1 ++ aliases)), mode)
  #  end
  # end

  # defp alias_regexes do
  #  [
  #    ~r|^\s*alias ([^{\s,]+)|,
  #    # {~r|^\s*alias ([^{]+),|, :b},
  #    ~r|^\s*alias ([^{]+)\.{([^}]+)}$|
  #  ]
  # end
end
