defmodule DeadCodeFinder.AliasImportRequire do
  def find(file) do
    lines = String.split(file, "\n", trim: true)
    find(%{aliases: [], imports: [], requires: [], mode: :single}, lines)
  end

  defp find(acc, []) do
    acc
    |> Map.delete(:mode)
    |> Map.update!(:aliases, &Enum.reverse/1)
  end

  defp find(%{mode: mode} = acc, [line | rest]) do
    alias_finders()
    |> Map.fetch!(mode)
    |> Enum.reduce_while(acc, fn {regex, regex_match_fun}, acc ->
      case Regex.run(regex, line, capture: :all_but_first) do
        nil ->
          {:cont, acc}

        captures ->
          {new_aliases, acc} = regex_match_fun.(captures, acc)
          {:halt, %{acc | aliases: prepend_new_aliases(new_aliases, acc.aliases)}}
      end
    end)
    |> find(rest)
  end

  defp prepend_new_aliases(new_aliases, existing) do
    Enum.reduce(new_aliases, existing, fn new_alias, aliases ->
      [Module.concat([new_alias]) | aliases]
    end)
  end

  defp alias_finders do
    %{
      single: [
        single_line_single_alias(),
        single_line_multiple_aliases(),
        multi_line_alias_start_line()
      ],
      multi: [
        multi_line_alias_middle_lines(),
        multi_line_alias_last_line()
      ]
    }
  end

  defp single_line_single_alias do
    {~r|^\s*alias ([^{\s,]+)\s*$|, fn [alias], acc -> {[alias], acc} end}
  end

  defp single_line_multiple_aliases do
    {~r|^\s*alias ([^{]+)\.{([^}]+)}|,
     fn [namespace, aliases], acc ->
       aliases =
         aliases
         |> String.split(",")
         |> Enum.map(fn alias -> namespace <> "." <> String.trim(alias) end)

       {aliases, acc}
     end}
  end

  defp multi_line_alias_start_line do
    {~r|^\s*alias ([^{\s,]+)\.{$|,
     fn [namespace], acc ->
       {[], Map.merge(acc, %{namespace: namespace, mode: :multi})}
     end}
  end

  defp multi_line_alias_middle_lines do
    {~r|^\s*([^{\s,]+),$|,
     fn [alias], acc ->
       {[acc.namespace <> "." <> alias], acc}
     end}
  end

  defp multi_line_alias_last_line do
    {~r|^\s*([^{\s,]+)|,
     fn [alias], acc ->
       {[acc.namespace <> "." <> alias], Map.put(acc, :mode, :single)}
     end}
  end
end
