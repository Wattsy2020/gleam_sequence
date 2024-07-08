import gleam/option.{type Option, None, Some}

type Node(a) {
  Node(value: a, left: Option(Node(a)), right: Option(Node(a)))
}

/// A sequence that supports adding items at either end in O(log(n)) time complexity
pub opaque type Sequence(a) {
  Sequence(node: Option(Node(a)))
}

/// Create an empty sequence
pub fn new() -> Sequence(a) {
  Sequence(None)
}

/// Create a sequence from a single item
pub fn of(item: a) -> Sequence(a) {
  Sequence(Some(Node(item, None, None)))
}

// very naive, just go the left of the tree to add it
fn prepend_node(root: Option(Node(a)), item: a) -> Node(a) {
  case root {
    None -> Node(item, None, None)
    Some(node) -> Node(..node, left: Some(prepend_node(node.left, item)))
  }
}

/// Add the item to the start of the sequence
pub fn prepend(sequence: Sequence(a), item: a) -> Sequence(a) {
  Sequence(Some(prepend_node(sequence.node, item)))
}

// very naive, just go the right of the tree to add it
fn append_node(root: Option(Node(a)), item: a) -> Node(a) {
  case root {
    None -> Node(item, None, None)
    Some(node) -> Node(..node, right: Some(append_node(node.right, item)))
  }
}

/// Add an item to the end of the sequence
pub fn append(sequence: Sequence(a), item: a) -> Sequence(a) {
  Sequence(Some(append_node(sequence.node, item)))
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
  case sequence.node {
    None -> Error(Nil)
    Some(node) -> {
      let #(new_root, last_item) = init_node(node)
      Ok(#(Sequence(new_root), last_item))
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
  case sequence.node {
    None -> Error(Nil)
    Some(node) -> {
      let #(first_item, new_root) = tail_node(node)
      Ok(#(first_item, Sequence(new_root)))
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
  do_from_list(list, new())
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

/// Check if two sequences are equal
/// NOTE: `==` can fail, as sequences are represented as trees under the hood
/// and multiple different trees can represent the same "logical sequence"
/// e.g. `2 <- 1 -> None` is the same sequence as `None <- 2 -> 1`
pub fn equals(left: Sequence(a), right: Sequence(a)) -> Bool {
  // todo: this could be more efficient by using zip and comparing sequence items one by one
  // as it would stop early if it finds unequal items
  to_list(left) == to_list(right)
}
