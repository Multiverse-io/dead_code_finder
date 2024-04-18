defmodule DeadCodeFiner.AliasImportRequireTest do
  use ExUnit.Case, async: true
  alias DeadCodeFinder.AliasImportRequire

  describe "find/1 - alias matches" do
    test "given an empty file, there're no aliases etc" do
      assert %{aliases: [], imports: [], requires: []} == AliasImportRequire.find("")
    end

    test "given file with a simple one-line alias in it, we return it" do
      file = """
        defmodule DeadCodeFinder do
          alias DeadCodeFinder.AliasImportRequire
      """

      assert %{aliases: [DeadCodeFinder.AliasImportRequire]} = AliasImportRequire.find(file)
    end

    test "given file with a different simple one-line alias in it, we return it" do
      file = """
      defmodule DeadCodeFinder do
        alias Cool.Module
      """

      assert %{aliases: [Cool.Module]} = AliasImportRequire.find(file)
    end

    test "given file with a multiple simple one-line alias in it, we return it" do
      file = """
      defmodule DeadCodeFinder do
        alias Cool.Module
        alias Farm.Animals
      """

      assert %{aliases: [Cool.Module, Farm.Animals]} = AliasImportRequire.find(file)
    end

    test "given file with multiple aliases in one line using the curly brace syntax, we return them all" do
      file = """
      defmodule DeadCodeFinder do
        alias Farm.Mammals.{Pig, Sheep}
      """

      assert %{aliases: [Farm.Mammals.Pig, Farm.Mammals.Sheep]} = AliasImportRequire.find(file)
    end

    test "with a multi-line alias, we get them all" do
      file = """
      defmodule Zoom.Api.HTTP do
              alias Farm.{
                Mammals.Pig,
                Mammals.Sheep,
                Barnyard,
                Tractor,
                Fields
              }

        # We are using the Turtles Zoom meeting ID to regularly check that
      """

      assert %{
               aliases: [
                 Farm.Mammals.Pig,
                 Farm.Mammals.Sheep,
                 Farm.Barnyard,
                 Farm.Tractor,
                 Farm.Fields
               ]
             } = AliasImportRequire.find(file)
    end
  end

  describe "find/1 - alias ANTI matches" do
    test "with a one-line alias thats wrong because there's nonsense at the end, we don't return it" do
      file = """
              defmodule DeadCodeFinder do
                alias DeadCodeFinder.AliasImportRequire.liulkjshldfsli,{
      """

      assert %{aliases: []} = AliasImportRequire.find(file)
    end
  end

  describe "find/1 - import matches" do
    test "given an empty file, there're no imports etc" do
      assert %{aliases: [], imports: [], requires: []} == AliasImportRequire.find("")
    end

    test "given file with a simple one-line import in it, we return it" do
      file = """
        defmodule DeadCodeFinder do
          import DeadCodeFinder.AliasImportRequire
      """

      assert %{imports: [DeadCodeFinder.AliasImportRequire]} = AliasImportRequire.find(file)
    end

    test "given file with a different simple one-line import in it, we return it" do
      file = """
      defmodule DeadCodeFinder do
        import Cool.Module
      """

      assert %{imports: [Cool.Module]} = AliasImportRequire.find(file)
    end

    test "given file with a multiple simple one-line import in it, we return it" do
      file = """
      defmodule DeadCodeFinder do
        import Cool.Module
        import Farm.Animals
      """

      assert %{imports: [Cool.Module, Farm.Animals]} = AliasImportRequire.find(file)
    end

    test "given file with multiple imports in one line using the curly brace syntax, we return them all" do
      file = """
      defmodule DeadCodeFinder do
        import Farm.Mammals.{Pig, Sheep}
      """

      assert %{imports: [Farm.Mammals.Pig, Farm.Mammals.Sheep]} = AliasImportRequire.find(file)
    end

    test "with a multi-line import, we get them all" do
      file = """
      defmodule Zoom.Api.HTTP do
              import Farm.{
                Mammals.Pig,
                Mammals.Sheep,
                Barnyard,
                Tractor,
                Fields
              }

        # We are using the Turtles Zoom meeting ID to regularly check that
      """

      assert %{
               imports: [
                 Farm.Mammals.Pig,
                 Farm.Mammals.Sheep,
                 Farm.Barnyard,
                 Farm.Tractor,
                 Farm.Fields
               ]
             } = AliasImportRequire.find(file)
    end
  end
end
