// P_3_1_4_01.pde
// WordItem.pde, WordMap.pde
// 
// Generative Gestaltung, ISBN: 978-3-87439-759-9
// First Edition, Hermann Schmidt, Mainz, 2009
// Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
// Copyright 2009 Hartmut Bohnacker, Benedikt Gross, Julia Laub, Claudius Lazzeroni
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

// Code is based on the treemap class from Visualizing Data, First Edition, Copyright 2008 Ben Fry.

class WordMap extends SimpleMapModel {    
  HashMap words;

  WordMap() {
    words = new HashMap();
  }

  void addWord(String word) {
    WordItem item = (WordItem) words.get(word);
    if (item == null) {
      item = new WordItem(word);
      words.put(word, item);
    }
    item.incrementSize();
  }

  void finishAdd() {
    items = new WordItem[words.size()];
    words.values().toArray(items);
  }
}



