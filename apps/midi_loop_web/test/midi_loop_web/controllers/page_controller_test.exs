defmodule MidiLoopWeb.PageControllerTest do
  use MidiLoopWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Connect MIDI keyboard or controller"
  end
end
