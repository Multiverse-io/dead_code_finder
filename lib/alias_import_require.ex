defmodule DeadCodeFinder.AliasImportRequire do
  def find(file) do
    file
    |> String.split("\n", trim: true)
    |> find(%{alias: [], import: [], require: []}, :single)
  end

  defp find([], acc, _mode) do
    acc
  end

  defp find([line | rest], acc, mode) do
    find(rest, acc, mode)

    alias_regexes()
    |> Enum.reduce_while(nil, fn {regex, runnable_mode, new_mode}, _ ->
      case {run_regex(regex, line, mode, runnable_mode), mode, new_mode} do
        {nil, _, _} ->
          {:cont, nil}

        {[alias], :multi, _} ->
          alias = acc.namespace <> "." <> alias
          {:halt, {:add_aliases, [alias], new_mode}}

        {[namespace], _, :multi} ->
          acc = Map.put(acc, :namespace, namespace)
          {:halt, {:acc, acc, new_mode}}

        {[alias], _, _} ->
          {:halt, {:add_aliases, [alias], new_mode}}

        {[namespace, aliases], _, _} ->
          {:halt, {:add_aliases, parse_multiple_aliases(namespace, aliases), new_mode}}
      end
    end)
    |> case do
      nil ->
        find(rest, acc, mode)

      {:acc, acc, new_mode} ->
        new_mode = determine_new_mode(mode, new_mode)
        find(rest, acc, new_mode)

      {:add_aliases, aliases, new_mode} ->
        new_mode = determine_new_mode(mode, new_mode)
        aliases = Enum.map(aliases, fn alias -> Module.concat([alias]) end)
        find(rest, Map.update!(acc, :alias, &(&1 ++ aliases)), new_mode)
    end
  end

  defp determine_new_mode(old_mode, :no_change), do: old_mode
  defp determine_new_mode(_, new_mode), do: new_mode

  defp run_regex(regex, line, _current_mode, :any) do
    do_run_regex(regex, line)
  end

  defp run_regex(regex, line, current_mode, runnable_mode) do
    if current_mode == runnable_mode do
      do_run_regex(regex, line)
    else
      nil
    end
  end

  defp do_run_regex(regex, line) do
    Regex.run(regex, line, capture: :all_but_first)
  end

  defp parse_multiple_aliases(namespace, aliases) do
    aliases
    |> String.split(",")
    |> Enum.map(fn alias ->
      namespace <> "." <> String.trim(alias)
    end)
  end

  defp alias_regexes do
   [
     {~r|^\s*alias ([^{]+)\.{([^}]+)}|, :single, :no_change},
     {~r|^\s*alias ([^{\s,]+)\s*$|, :single, :no_change},
     {~r|^\s*alias ([^{\s,]+)\.{$|, :single, :multi},
     {~r|^\s*([^{\s,]+),$|, :multi, :multi},
     {~r|^\s*([^{\s,]+)|, :multi, :single},
   ]
  end
end
