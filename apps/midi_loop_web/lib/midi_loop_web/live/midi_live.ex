defmodule MidiLoopWeb.MidiLive do
  use Phoenix.LiveView
  use Bitwise, only_operators: true

  alias Midi.State

  def render(assigns) do
    MidiLoopWeb.MidiView.render("index.html", assigns)
  end

  def mount(_session, socket) do
    s = struct(State)
    {:ok, assign(socket, state: s)}
  end

  def handle_event("user_gesture", _value, %{assigns: assigns} = socket) do
    new_state = Midi.user_gesture(assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("midi_input", input, %{assigns: assigns} = socket) do
    new_state = Midi.midi_input(input, assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("midi_output", output, %{assigns: assigns} = socket) do
    new_state = Midi.midi_output(output, assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("inc_tempo", _, %{assigns: assigns} = socket) do
    new_state = Midi.inc_tempo(assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event("dec_tempo", _, %{assigns: assigns} = socket) do
    new_state = Midi.dec_tempo(assigns.state)
    {:noreply, assign(socket, state: new_state)}
  end

  @midi_file "mid"
  def handle_event(@midi_file, mid, %{assigns: _assigns} = socket) do
    File.write("~/mid.mid", IO.inspect(mid, limit: :infinity))

    mid = mid |> AtomicMap.convert(%{safe: false}) |> Map.get(:mid)

    {_mid, derived} = MidiFile.process(mid)

    IO.inspect(derived)
    {:noreply, socket}
  end

  @status_byte 0xF0
  @channel_byte 0x0F

  @midi_message "m"

  @doc """
  Handle MIDI message event.
  """
  def handle_event(
        @midi_message,
        %{
          "d" => %{"0" => status, "1" => key, "2" => value},
          "i" => port_id,
          "t" => time
        },
        %{assigns: assigns} = socket
      ) do
    message_code = status &&& @status_byte
    channel = (status &&& @channel_byte) + 1

    new_state =
      Midi.handle_message(message_code, key, value, channel, port_id, time, assigns.state)

    {:noreply, assign(socket, state: new_state)}
  end

  def handle_event(
        @midi_message,
        %{
          "d" => %{"0" => status, "1" => key},
          "i" => port_id,
          "t" => time
        },
        %{assigns: assigns} = socket
      ) do
    message_code = status &&& @status_byte
    channel = (status &&& @channel_byte) + 1

    new_state = Midi.handle_message(message_code, key, channel, port_id, time, assigns.state)

    {:noreply, assign(socket, state: new_state)}
  end
end
