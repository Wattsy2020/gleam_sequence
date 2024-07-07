import gleam/option.{type Option, None, Some}

type Node(a) {
  Node(value: a, prev: Option(Node(a)), next: Option(Node(a)))
}

type HeadNode(a) {
  HeadNode(value: a, next: Option(Node(a)))
}

type TailNode(a) {
  TailNode(value: a, prev: Option(Node(a)))
}

/// A doubly linked list, with O(1) add time at either end
pub opaque type Sequence(a) {
  Items(head: HeadNode(a), tail: TailNode(a))
  Empty
}

/// Create an empty sequence
pub fn new() -> Sequence(a) {
  Empty
}

/// Create a sequence from a single item
pub fn of(item: a) -> Sequence(a) {
  Items(HeadNode(item, None), TailNode(item, None))
}

/// Retrieve a tuple of #(all items of sequence except the last item, last item in the sequence)
/// Returns Error(Nil) if the sequence is empty
pub fn init(sequence: Sequence(a)) -> Result(#(Sequence(a), a), Nil) {
  case sequence {
    Empty -> Error(Nil)
    Items(_, TailNode(value, None)) -> Ok(#(Empty, value))
    Items(head, TailNode(value, Some(prev_node))) ->
      Ok(#(Items(head, TailNode(prev_node.value, prev_node.prev)), value))
  }
}

/// Retrieve a tuple of #(first item in the sequence, all items of sequence except the first item)
/// Returns Error(Nil) if the sequence is empty
pub fn tail(sequence: Sequence(a)) -> Result(#(a, Sequence(a)), Nil) {
  case sequence {
    Empty -> Error(Nil)
    Items(HeadNode(value, None), _) -> Ok(#(value, Empty))
    Items(HeadNode(value, Some(next_node)), tail) ->
      Ok(#(value, Items(HeadNode(next_node.value, next_node.next), tail)))
  }
}

/// Add the item to the start of the sequence
pub fn prepend(sequence: Sequence(a), item: a) -> Sequence(a) {
  todo
  //case sequence {
  //  Empty -> of(item)
  //  Items(HeadNode(value, None), _) -> Items(HeadNode(item, None), TailNode)
  //}
}

pub fn append(sequence: Sequence(a), item: a) -> Sequence(a) {
  todo
}

pub fn from_list(list: List(a)) -> Sequence(a) {
  case list {
    [] -> Empty
    [first, ..remaining] -> Empty
  }
}
