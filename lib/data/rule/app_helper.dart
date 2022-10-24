String? urlFix(String? url,String baseUrl){
  if(url?.isNotEmpty!=true) return null;
  if(url!.startsWith("//")){
    final protocal=baseUrl.indexOf(":");
    if (protocal >= 0) return "${baseUrl.substring(0, protocal + 1)}" + url;
    else return "https:"+url;
  }
  if(url.startsWith("http")){
    return url;
  }
  if(url.contains(Uri.parse(baseUrl).host)){
    return "http:"+url;
  }else{
    return baseUrl+url;
  }
}