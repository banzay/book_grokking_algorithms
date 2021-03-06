defmodule Towers.CellTest do
  use ExUnit.Case
  alias Towers.{Cell}

  @tag cell: true
  test "apply_values/1" do
    empty_set = MapSet.new()

    assert %Cell{
             value: 4,
             values: ^empty_set
           } =
             Cell.apply_values(%Cell{
               values: MapSet.new([4]),
               value: nil
             })
  end

  @tag cell: true
  test "apply_discovered/2" do
    values = MapSet.new([4])

    assert %Cell{
             value: nil,
             values: ^values
           } =
             Cell.apply_discovered(
               %Cell{
                 values: MapSet.new([1, 3, 4]),
                 value: nil
               },
               MapSet.new([1, 3]),
               4
             )

    values2 = MapSet.new()

    assert %Cell{
             value: 4,
             values: ^values2
           } =
             Cell.apply_discovered(
               %Cell{
                 values: MapSet.new([1, 4]),
                 value: nil
               },
               MapSet.new([1, 2, 3]),
               4
             )
  end

  @tag cell: true
  test "apply_uniques/2" do
    empty_set = MapSet.new()

    assert %Cell{
             value: 2,
             values: ^empty_set
           } =
             Cell.apply_uniques(
               %Cell{
                 values: MapSet.new([1, 2, 3]),
                 value: nil
               },
               MapSet.new([2, 10])
             )
  end
end
