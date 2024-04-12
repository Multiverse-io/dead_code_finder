defmodule DeadCodeFiner.AliasImportRequireTest do
  use ExUnit.Case, async: true
  alias DeadCodeFinder.AliasImportRequire

  describe "find/1" do
    test "given an empty file, there're no aliases etc" do
      assert %{alias: [], import: [], require: []} == AliasImportRequire.find("")
    end

    test "given file with a simple one-line alias in it, we return it" do
      file = "defmodule DeadCodeFinder do\n  alias DeadCodeFinder.AliasImportRequire\n"
      assert %{alias: [DeadCodeFinder.AliasImportRequire]} = AliasImportRequire.find(file)
    end

    test "given file with a different simple one-line alias in it, we return it" do
      file = "defmodule DeadCodeFinder do\n  alias Cool.Module\n"
      assert %{alias: [Cool.Module]} = AliasImportRequire.find(file)
    end

    test "given file with a multiple simple one-line alias in it, we return it" do
      file = "defmodule DeadCodeFinder do\n  alias Cool.Module\n  alias Farm.Animals"
      assert %{alias: [Cool.Module, Farm.Animals]} = AliasImportRequire.find(file)
    end
  end
end
