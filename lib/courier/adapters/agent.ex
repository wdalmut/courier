defmodule Courier.Adapters.Agent do
  @moduledoc """
  Agent Adapter

  This adapter is not intended to be used directly but instead should be
  used by another adapter:

      defmodule MyCustomAdapter do
        use Courier.Adapters.Agent
      end
  """

  Module.add_doc(__MODULE__, __ENV__.line + 1, :def, {:deliver, 2}, (quote do: [message, opts]), """
  Delivers the message by storing in an Agent
  """)

  Module.add_doc(__MODULE__, __ENV__.line + 1, :def, {:messages, 0}, (quote do: []), """
  Returns a list of all messages in the Agent

  Returns an empty list if no messages are found
  """)

  Module.add_doc(__MODULE__, __ENV__.line + 1, :def, {:messages_for, 1}, (quote do: [recipient]), """
  Returns a list of all messages for the given recipient

      defmodule MockAdapter do
        use Courier.Adapters.Agent
      end
      MockAdapter.start_link([])
      MockAdapter.messages_for("joe@example.com")
      [%Mail.Message{...}, %Mail.Message{...}]
  """)

  Module.add_doc(__MODULE__, __ENV__.line + 1, :def, {:recipients, 0}, (quote do: []), """
  Unique list of all recipients for all messages

  Will include `BCC` recipients

      defmodule MockAdapter do
        use Courier.Adapters.Agent
      end
      MockAdapter.start_link([])
      MockAdapter.recipients()
      ["joe@example.com", {"Brian", "brian@example.com"}]
  """)

  Module.add_doc(__MODULE__, __ENV__.line + 1, :def, {:clear, 0}, (quote do: []), """
  Clears all messages
  """)

  Module.add_doc(__MODULE__, __ENV__.line + 1, :def, {:delete, 1}, (quote do: [message]), """
  Deletes the specific message

  Returns the list of remaning messages.
  """ )

  defmacro __using__([]) do
    quote do
      use Courier.Storage
      @behaviour Courier.Adapter

      def start_link(_opts) do
        Agent.start_link(fn -> [] end, name: __MODULE__)
      end

      def deliver(%Mail.Message{} = message, _opts) do
        Agent.update(__MODULE__, fn(messages) -> [message | messages] end)
      end

      def messages() do
        Agent.get(__MODULE__, fn(messages) -> messages end)
      end

      def clear(),
        do: Agent.update(__MODULE__, fn(_) -> [] end)

      def delete(message) do
        Agent.update(__MODULE__, fn(messages) -> List.delete(messages, message) end)
      end

      defoverridable [deliver: 2, messages: 0, clear: 0, delete: 1]
    end
  end
end
