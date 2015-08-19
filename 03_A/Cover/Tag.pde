// Cover.pde
// ImageRibbon.pde, Tag.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Groß, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Groß, Julia Laub, Claudius Lazzeroni
//
// http://www.generative-gestaltung.de
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

/**
 * an instance of Tag collects information about one of the tags that appear in
 * "book.xml".  
 */


class Tag {
  String name;
  // how often does this tag appear
  int count = 0;

  // which orderNum inside all sorted tags
  int orderNum = 0;
  // percentage of this tag from all tags (0-1)
  float ratio = 0;
  // position of the tag block (0-1)
  float position = 0;

  Tag(String theName) {
    name = theName;
  }

  String toString() {
    return (name + "(" + count + ")"); 
  }
}

