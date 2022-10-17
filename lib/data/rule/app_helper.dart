String urlFix(String url,String baseUrl){
  if(url.startsWith("http")){
    return url;
  }
  if(url.contains(Uri.parse(baseUrl).host)){
    return "http:"+url;
  }else{
    return baseUrl+url;
  }
}