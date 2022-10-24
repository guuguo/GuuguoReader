extension MatchExt on Match{
  groupOrNull(int index){
    try{
      return group(index);
    }catch(e){
      return null;
    }
  }
}