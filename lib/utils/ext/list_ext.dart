extension ListExt on Iterable {
  List<T> separated<T>(ItemBuilder<T> separateBuilder) {
    List<T> newList = [];
    var i = 0;
    this.forEach((element) {
      newList.add(element);
      if (i != this.length - 1) {
        newList.add(separateBuilder(i));
        i++;
      }
    });
    return newList;
  }
}
extension ListTExt<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T toElement(int index,E e)) {
  final list=this.toList();
  return list.asMap().keys.map((i) => toElement(i,list[i]));
}
}

typedef ItemBuilder<T> =T Function(int index);