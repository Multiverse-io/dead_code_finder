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

    test "given file with multiple aliases in one line using the curly brace syntax, we return them all" do
      file = "defmodule DeadCodeFinder do\n  alias Farm.Mammals.{Pig, Sheep}"
      assert %{alias: [Farm.Mammals.Pig, Farm.Mammals.Sheep]} = AliasImportRequire.find(file)
    end

    test "with a multi-line alias, we get them all" do
      file = "defmodule Zoom.Api.HTTP do\n  alias Farm.{\n    Mammals.Pig,\n    Mammals.Sheep,\n    Barnyard,\n    Tractor,\n    Fields\n  }\n\n  # We are using the Turtles Zoom meeting ID to regularly check that\n "
      assert %{alias: [Farm.Mammals.Pig, Farm.Mammals.Sheep, Farm.Barnyard, Farm.Tractor, Farm.Fields]} = AliasImportRequire.find(file)
    end

    test "with a one-line alias thats wrong because there's nonsense at the end, we don't return it" do
      file = "defmodule DeadCodeFinder do\n  alias DeadCodeFinder.AliasImportRequire.liulkjshldfsli,{\n"
      assert %{alias: []} = AliasImportRequire.find(file)
    end
  end
end
