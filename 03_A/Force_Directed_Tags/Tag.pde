class Tag {
  String name;
  int count = 0;

  // percentage of this tag from all tags (0-1)
  float ratio = 0;
  // position of the tag block (0-1)
  float position = 0;

  Tag(String theName) {
    name = theName;
  }

  String toString() {
    return (name + " (" + count + ")"); 
  }
}

