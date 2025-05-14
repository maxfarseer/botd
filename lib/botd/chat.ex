defmodule Botd.Chat do
  @moduledoc """
  This module is responsible for handling the Telegram chat interactions.
  """

  require Logger

  defstruct chat_id: nil,
            step: :waiting_for_start,
            name: nil,
            death_date: nil,
            reason: nil

  def init_state do
    %__MODULE__{}
  end

  @doc """
  changing step
  """
  def make_next_step(:reset), do: :waiting_for_start
  def make_next_step(:waiting_for_start), do: :selected_action
  def make_next_step(:selected_add_person), do: :waiting_for_name
  def make_next_step(:waiting_for_name), do: :waiting_for_death_date
  def make_next_step(:waiting_for_death_date), do: :waiting_for_reason
  def make_next_step(:waiting_for_reason), do: :finished
  def make_next_step(:finished), do: :after_finished

  def make_next_step(step) do
    Logger.warning("Unknown chat step: #{inspect(step)}")
    step
  end

  # FIN
end
