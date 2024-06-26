defmodule ExDebugTest do
  use ExUnit.Case
  doctest ExDebug

  import ExUnit.CaptureIO
  import Mock

  describe "console/2" do
    test "Write the input term on console and return it." do
      input = {:ok, "some value"}

      assert {
        ^input,
        [
          "--------------------------------------------------- " <> _datetime,
          "{:ok, \"some value\"}",
          "----------------------------------------------------------------- " <> _app_version,
          ""
        ]
      } = fn -> ExDebug.console(input) end |> with_io() |> format_capture()
    end
    
    test "The return is a passtrhough of the input term." do
      atom    = :atom
      binary  = <<1, 2, 3>>
      boolean = true
      list    = [1, 2, 3]
      map     = %{a: "1"}
      null    = nil
      number  = 123
      regex   = ~r/^regex$/
      string  = "string"
      tuple   = {:ok, 1}

      assert {
        ^atom,
        [_header, ":atom", _footer, ""]
      } = fn -> ExDebug.console(atom) end |> with_io() |> format_capture()
      
      assert {
        ^binary,
        [_header, "<<1, 2, 3>>", _footer, ""]
      } = fn -> ExDebug.console(binary) end |> with_io() |> format_capture()
      
      assert {
        ^boolean,
        [_header, "true", _footer, ""]
      } = fn -> ExDebug.console(boolean) end |> with_io() |> format_capture()
      
      assert {
        ^list,
        [_header, "[1, 2, 3]", _footer, ""]
      } = fn -> ExDebug.console(list) end |> with_io() |> format_capture()
      
      assert {
        ^map,
        [_header, "%{a: \"1\"}", _footer, ""]
      } = fn -> ExDebug.console(map) end |> with_io() |> format_capture()
      
      assert {
        ^null,
        [_header, "nil", _footer, ""]
      } = fn -> ExDebug.console(null) end |> with_io() |> format_capture()
      
      assert {
        ^number,
        [_header, "123", _footer, ""]
      } = fn -> ExDebug.console(number) end |> with_io() |> format_capture()
      
      assert {
        ^regex,
        [_header, "~r/^regex$/", _footer, ""]
      } = fn -> ExDebug.console(regex) end |> with_io() |> format_capture()
      
      assert {
        ^string,
        [_header, "\"string\"", _footer, ""]
      } = fn -> ExDebug.console(string) end |> with_io() |> format_capture()
      
      assert {
        ^tuple,
        [_header, "{:ok, 1}", _footer, ""]
      } = fn -> ExDebug.console(tuple) end |> with_io() |> format_capture()
    end
    
    test "Configure the :width parameter in config.ex file." do
      prev_value = Application.get_env(:ex_debug, :width)
      Application.put_env(:ex_debug, :width, 40)

      input = {:ok, "some value"}
      result = fn -> ExDebug.console(input) end |> with_io() |> format_capture()

      Application.put_env(:ex_debug, :width, prev_value)

      assert {
        ^input,
        [
          "----------- " <> _datetime,
          "{:ok, \"some value\"}",
          "------------------------- " <> _app_version,
          ""
        ]
      } = result
    end
    
    test "Set the :width parameter in options." do
      input = {:ok, "some value"}

      assert {
        ^input,
        [
          "----------- " <> _datetime,
          "{:ok, \"some value\"}",
          "------------------------- " <> _app_version,
          ""
        ]
      } = fn ->
            ExDebug.console(input, width: 40)
          end
          |> with_io()
          |> format_capture()
    end
    
    test "Set the :label parameter in options." do
      input = {:ok, "some value"}

      assert {
        ^input,
        [
          "Process 01 ---------------------------------------- " <> _datetime,
          "{:ok, \"some value\"}",
          "----------------------------------------------------------------- " <> _app_version,
          ""
        ]
      } = fn ->
            ExDebug.console(input, label: "Process 01")
          end
          |> with_io()
          |> format_capture()
    end
    
    test "Do not write the input term on console in :prod enviroment." do
      with_mocks [
        # This mock sets the hypotetical enviroment.
        {System, [:passthrough], get_env: fn _ -> "prod" end}
      ] do
        input = :some_value

        assert {
          ^input,
          [""]
        } = fn -> ExDebug.console(input) end |> with_io() |> format_capture()
      end
    end
  end

  defp format_capture({return, capture}), do:
    {return, capture |> String.replace(~r/\e.*?m/, "") |> String.split("\n")}
end