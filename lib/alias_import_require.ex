defmodule DeadCodeFinder.AliasImportRequire do
  @alias "alias"
  @import "import"
  @require "require"
  @directives_regex "(\\b#{@alias}\\b\|\\b#{@import}\\b\|\\b#{@require}\\b)"

  def find(file) do
    lines = String.split(file, "\n", trim: true)
    find(%{aliases: [], imports: [], requires: [], mode: :single, directive: @alias}, lines)
  end

  defp find(acc, []) do
    acc
    |> Map.drop([:mode, :directive, :namespace])
    |> Map.new(fn {directive, modules} -> {directive, Enum.reverse(modules)} end)
  end

  defp find(%{mode: mode} = acc, [line | rest]) do
    finders()
    |> Map.fetch!(mode)
    |> Enum.reduce_while(acc, fn {regex, regex_match_fun}, acc ->
      case Regex.run(regex, line, capture: :all_but_first) do
        nil ->
          {:cont, acc}

        captures ->
          {new_modules, acc} = regex_match_fun.(captures, acc)

          {:halt,
           Map.update!(acc, directive_to_atom!(acc.directive), fn existing_modules ->
             add_modules(new_modules, existing_modules)
           end)}
      end
    end)
    |> find(rest)
  end

  defp add_modules(new_modules, existing) do
    Enum.reduce(new_modules, existing, fn new_module, modules ->
      [Module.concat([new_module]) | modules]
    end)
  end

  defp directive_to_atom!(@alias), do: :aliases
  defp directive_to_atom!(@import), do: :imports
  defp directive_to_atom!(@require), do: :requires

  defp finders do
    %{
      single: [
        single_line_directive(),
        single_line_multiple_directives(),
        multi_line_directive_start_line()
      ],
      multi: [
        multi_line_directive_middle_lines(),
        multi_line_directive_last_line()
      ]
    }
  end

  defp single_line_directive do
    {~r|^\s*#{@directives_regex} ([^{\s,]+)\s*$|,
     fn [directive, alias], acc -> {[alias], Map.put(acc, :directive, directive)} end}
  end

  defp single_line_multiple_directives do
    {~r|^\s*#{@directives_regex} ([^{]+)\.{([^}]+)}|,
     fn [directive, namespace, modules], acc ->
       modules =
         modules
         |> String.split(",")
         |> Enum.map(fn module -> namespace <> "." <> String.trim(module) end)

       {modules, Map.put(acc, :directive, directive)}
     end}
  end

  defp multi_line_directive_start_line do
    {~r|^\s*#{@directives_regex} ([^{\s,]+)\.{$|,
     fn [directive, namespace], acc ->
       {[], Map.merge(acc, %{directive: directive, namespace: namespace, mode: :multi})}
     end}
  end

  defp multi_line_directive_middle_lines do
    {~r|^\s*([^{\s,]+),$|, fn [module], acc -> {[acc.namespace <> "." <> module], acc} end}
  end

  defp multi_line_directive_last_line do
    {~r|^\s*([^{\s,]+)|,
     fn [alias], acc -> {[acc.namespace <> "." <> alias], Map.put(acc, :mode, :single)} end}
  end
end
