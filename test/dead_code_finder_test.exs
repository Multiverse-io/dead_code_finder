defmodule DeadCodeFinderTest do
  use ExUnit.Case, async: true

  describe "find/0" do
    test "returns the module info for all applications defined in config under :dead_code_finder, :applications" do
      assert %{
               DeadCodeFinder => %{
                 functions: [find: 0],
                 aliases: [DeadCodeFinder.AliasImportRequire],
                 imports: [],
                 requires: [],
                 file_path: _
               },
               DeadCodeFinder.AliasImportRequire => %{
                 functions: [find: 1],
                 aliases: [],
                 imports: [],
                 requires: [],
                 file_path: _
               }
             } = DeadCodeFinder.find()
    end

    test "returns the file paths of modules" do
      assert %{
               DeadCodeFinder => %{file_path: dead_code_finder_path},
               DeadCodeFinder.AliasImportRequire => %{file_path: alias_import_require_path}
             } = DeadCodeFinder.find()

      assert String.ends_with?(dead_code_finder_path, "lib/dead_code_finder.ex")
      assert String.ends_with?(alias_import_require_path, "lib/alias_import_require.ex")
    end
  end
end
