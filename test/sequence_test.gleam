import gleam/list
import gleeunit
import gleeunit/should
import qcheck/generator
import qcheck/qtest
import sequence

pub fn main() {
  gleeunit.main()
}

pub fn new_test() {
  sequence.new()
  |> sequence.to_list
  |> should.equal([])
}

pub fn of_test() {
  sequence.of(1)
  |> sequence.to_list
  |> should.equal([1])
}

pub fn list_conversion_test() {
  use list <- qtest.given(generator.list_generic(
    generator.int_uniform(),
    0,
    100,
  ))
  list
  |> sequence.from_list
  |> sequence.to_list
  == list
}

pub fn prepend_test() {
  use #(list, item) <- qtest.given(generator.tuple2(
    generator.list_generic(generator.int_uniform(), 0, 100),
    generator.int_uniform(),
  ))
  list
  |> sequence.from_list
  |> sequence.prepend(item)
  |> sequence.to_list
  == [item, ..list]
}

pub fn append_test() {
  use #(list, item) <- qtest.given(generator.tuple2(
    generator.list_generic(generator.int_uniform(), 0, 100),
    generator.int_uniform(),
  ))
  list
  |> sequence.from_list
  |> sequence.append(item)
  |> sequence.to_list
  == list.concat([list, [item]])
}

pub fn init_test() {
  use list <- qtest.given(generator.list_generic(
    generator.int_uniform(),
    0,
    100,
  ))
  let init_result = {
    list
    |> sequence.from_list
    |> sequence.init
  }
  case list {
    [] -> init_result == Error(Nil)
    _ -> {
      let assert [last_item_list, ..init_list] = list.reverse(list)
      case init_result {
        Error(Nil) -> False
        Ok(#(init_sequence, last_item_seq)) ->
          sequence.to_list(init_sequence) == list.reverse(init_list)
          && last_item_seq == last_item_list
      }
    }
  }
}

pub fn tail_test() {
  use list <- qtest.given(generator.list_generic(
    generator.int_uniform(),
    0,
    100,
  ))
  let tail_result = {
    list
    |> sequence.from_list
    |> sequence.tail
  }
  case list {
    [] -> tail_result == Error(Nil)
    [first_item_list, ..tail_list] -> {
      case tail_result {
        Error(Nil) -> False
        Ok(#(first_item_seq, tail_sequence)) ->
          sequence.to_list(tail_sequence) == tail_list
          && first_item_seq == first_item_list
      }
    }
  }
}
