defmodule Towers.Row do
  alias __MODULE__

  import IEx

  alias Towers.{Cell}

  defstruct [:n_front, :n_back, cells: [], coords: []]

  def new(n_front, n_back, cells) do
    %Row{
      n_front: n_front,
      n_back: n_back,
      cells: cells
    }
    |> digest_clues()
  end

  def digest_cells(row, cells) do
    digest(%Row{row | cells: cells})
  end

  def digest(row = %Row{cells: cells}) do
    discovered_values =
      cells
      |> Enum.filter(&(&1.value != nil))
      |> Enum.map(& &1.value)

    if has_duplicates?(discovered_values) do
      throw("Error in algorithm - row has duplicates")
    end

    all_values =
      cells
      |> Enum.reduce([], fn %Cell{values: values}, acc ->
        acc ++ MapSet.to_list(values)
      end)

    uniques_set =
      all_values
      |> Enum.group_by(fn v ->
        Enum.count(all_values, &(&1 == v))
      end)
      |> Map.get(1, [])
      |> Enum.into(MapSet.new())

    singles_set =
      cells
      |> Enum.filter(&(MapSet.size(&1.values) == 1))
      |> Enum.reduce(MapSet.new(), &MapSet.union(&1.values, &2))

    discovered_set = Enum.into(discovered_values, MapSet.new())

    result = %Row{
      row |
      cells: cells
      |> Enum.map(&(
        &1
        |> Cell.apply_singles(singles_set)
        |> Cell.apply_uniques(uniques_set)
        |> Cell.apply_discovered(discovered_set)
        |> Cell.apply_values()
      ))
    }

    if result != row, 
      do: digest(result), 
      else: result
  end

  def has_duplicates?(list), do: Enum.uniq(list) != list

  @doc """
    Set initial values[] set for each cell in a row,
    using clues (n_front and n_back).
    After digest clues are no longer needed, 
    because they are transformed here into cells' values[].

    For example for:
        n_front: 1, n_back: 3, board_size: 4,
    matching values are:
        [
            MapSet[4], 
            MapSet[1, 2, 3], 
            MapSet[1, 3], 
            MapSet[1, 2]
        ]
  """
  def digest_clues(%Row{cells: cells} = row) do
    size = length(cells)

    new_values =
      size
      |> permutations()
      |> Enum.filter(&permutation_valid?(row, &1))
      |> Enum.zip()
      |> Enum.map(&MapSet.new(Tuple.to_list(&1)))

    cells =
      cells
      |> Enum.with_index()
      |> Enum.map(fn {cell, i} ->
        %Cell{
          cell
          | values: Enum.at(new_values, i)
        }
      end)

    %Row{row | cells: cells}
  end

  def permutations(size) when is_integer(size) do
    Enum.to_list(1..size)
    |> permutations()
  end

  def permutations([]), do: [[]]

  @doc """
  TODO: understand how this recursion works
  """
  def permutations(list) do
    for elem <- list,
        rest <- permutations(list -- [elem]),
        do: [elem | rest]
  end

  def permutation_valid?(%Row{n_front: n_front, n_back: n_back}, heights) do
    side_valid?(heights, n_front) &&
      side_valid?(Enum.reverse(heights), n_back)
  end

  def side_valid?(heights, n, n_curr \\ 0, max_height_curr \\ 0)

  def side_valid?(_, nil, _, _), do: true

  def side_valid?([], n, n_curr, _max_height_curr),
    do: n == n_curr

  def side_valid?([h | t], n, n_curr, max_height_curr) do
    if h > max_height_curr do
      side_valid?(t, n, n_curr + 1, h)
    else
      side_valid?(t, n, n_curr, max_height_curr)
    end
  end
end
