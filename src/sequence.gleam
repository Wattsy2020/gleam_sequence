import gleam/option.{type Option, None, Some}

type Node(a) {
  Node(value: a, left: Option(Node(a)), right: Option(Node(a)))
}

/// A sequence that supports adding items at either end in O(log(n)) time complexity
pub opaque type Sequence(a) {
  Items(Node(a))
  Empty
}

/// Create an empty sequence
pub fn new() -> Sequence(a) {
  Empty
}

/// Create a sequence from a single item
pub fn of(item: a) -> Sequence(a) {
  Items(Node(item, None, None))
}

// very naive, just go the left of the tree to add it
fn prepend_node(node: Node(a), item: a) -> Node(a) {
  let left_node = case node {
    Node(_, None, _) -> Node(item, None, None)
    Node(_, Some(left_node), _) -> prepend_node(left_node, item)
  }
  Node(..node, left: Some(left_node))
}

/// Add the item to the start of the sequence
pub fn prepend(sequence: Sequence(a), item: a) -> Sequence(a) {
  case sequence {
    Empty -> of(item)
    Items(node) -> Items(prepend_node(node, item))
  }
}

// very naive, just go the right of the tree to add it
fn append_node(node: Node(a), item: a) -> Node(a) {
  let right_node = case node {
    Node(_, _, None) -> Node(item, None, None)
    Node(_, _, Some(right_node)) -> append_node(right_node, item)
  }
  Node(..node, right: Some(right_node))
}

/// Add an item to the end of the sequence
pub fn append(sequence: Sequence(a), item: a) -> Sequence(a) {
  case sequence {
    Empty -> of(item)
    Items(node) -> Items(append_node(node, item))
  }
}

fn init_node(node: Node(a)) -> #(Option(Node(a)), a) {
  case node {
    Node(value, left_node, None) -> #(left_node, value)
    Node(value, left_node, Some(right_node)) -> {
      let #(new_right_node, tail_value) = init_node(right_node)
      let new_node = Node(value, left_node, new_right_node)
      #(Some(new_node), tail_value)
    }
  }
}

/// Retrieve a tuple of #(all items of sequence except the last item, last item in the sequence)
/// Returns Error(Nil) if the sequence is empty
pub fn init(sequence: Sequence(a)) -> Result(#(Sequence(a), a), Nil) {
  case sequence {
    Empty -> Error(Nil)
    Items(node) ->
      case init_node(node) {
        #(Some(node), value) -> Ok(#(Items(node), value))
        #(None, value) -> Ok(#(Empty, value))
      }
  }
}

fn tail_node(node: Node(a)) -> #(a, Option(Node(a))) {
  case node {
    Node(value, None, right_node) -> #(value, right_node)
    Node(value, Some(left_node), right_node) -> {
      let #(head_value, new_left_node) = tail_node(left_node)
      let new_node = Node(value, new_left_node, right_node)
      #(head_value, Some(new_node))
    }
  }
}

/// Retrieve a tuple of #(first item in the sequence, all items of sequence except the first item)
/// Returns Error(Nil) if the sequence is empty
pub fn tail(sequence: Sequence(a)) -> Result(#(a, Sequence(a)), Nil) {
  case sequence {
    Empty -> Error(Nil)
    Items(node) ->
      case tail_node(node) {
        #(value, Some(node)) -> Ok(#(value, Items(node)))
        #(value, None) -> Ok(#(value, Empty))
      }
  }
}

fn do_from_list(list: List(a), result: Sequence(a)) -> Sequence(a) {
  case list {
    [] -> result
    [first, ..remaining] -> do_from_list(remaining, append(result, first))
  }
}

/// Create a sequence from a list
pub fn from_list(list: List(a)) -> Sequence(a) {
  do_from_list(list, Empty)
}

fn do_to_list(sequence: Sequence(a), result: List(a)) -> List(a) {
  case init(sequence) {
    Error(Nil) -> result
    Ok(#(remaining, last_item)) -> do_to_list(remaining, [last_item, ..result])
  }
}

/// Convert a sequence to a list
pub fn to_list(sequence: Sequence(a)) -> List(a) {
  do_to_list(sequence, [])
}
