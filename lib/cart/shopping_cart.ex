defmodule ShoppingCart do
  use GenServer

  defmodule Cart do
    defstruct [:user_id, :items]

    def new(user_id) do
      %Cart{user_id: user_id, items: %{}}
    end

    def add_item(%Cart{items: items} = cart, key, quantity) do
      new_items =
        items
        |> Map.update(key, quantity, fn old_quantity -> old_quantity + quantity end)

      %{cart | items: new_items}
    end

    def get_items(%Cart{items: items}) do
      items
    end

    def remove_item(%Cart{items: items} = cart, key, quantityToRemove) do
      old_quantity =
        items
        |> Map.get(key)

      res = old_quantity - quantityToRemove

      if res <= 0 do
        new_items =
          items
          |> Map.delete(key)

        %{cart | items: new_items}
      else
        try do
          new_items =
            items
            |> Map.replace!(key, res)

          %{cart | items: new_items}
        catch
          # Ignore....
          _kind, _ -> cart
        end
      end
    end
  end

  # Server
  def init(init_arg) do
    {:ok, init_arg}
  end

  def handle_cast({:add_item, item, quantity}, cart) do
    new_cart = Cart.add_item(cart, item, quantity)
    {:noreply, new_cart}
  end

  def handle_cast({:remove_item, item, quantity}, cart) do
    new_cart = Cart.remove_item(cart, item, quantity)
    {:noreply, new_cart}
  end

  def handle_call(:get_items, _from, cart) do
    items = Cart.get_items(cart)
    {:reply, items, cart}
  end

  # Client
  def create(user_id) do
    {:ok, cart} = GenServer.start(__MODULE__, Cart.new(user_id))
    cart
  end

  def add_item(cart, item, quantity) do
    GenServer.cast(cart, {:add_item, item, quantity})
  end

  def remove_item(cart, item, quantity) do
    GenServer.cast(cart, {:remove_item, item, quantity})
  end

  def get_items(cart) do
    GenServer.call(cart, :get_items)
  end
end
