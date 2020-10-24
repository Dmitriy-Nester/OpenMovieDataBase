import Foundation

class NetworkUtil : NSObject
{
    static internal let mainUrl : String = "https://www.omdbapi.com/"
    static internal let apikey : String = "apikey=f5372d65"
    
    private class RequestPair : NSObject
    {
        open var url : URL!
        open var handler : ((Array<MovieModel>, NSError?)->Void)!
        open var error : NSError! = nil
        open var results :  NSArray!
    }
    
    private enum ParseError : Error
    {
        case IncorrectResult
        case IncorrectStructure
    }
    
    static public func performSearch(value : String, handler : ((Array<MovieModel>, NSError?)->Void)!)
    {
        let forurl = self.mainUrl + "?s=" + value.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)! + "&" + self.apikey
        let completeURL = URL(string: forurl)
        if handler != nil && completeURL != nil
        {
            let pair = RequestPair()
            pair.url = completeURL
            pair.handler = handler
            self.performSelector(inBackground: #selector(self.internalRequest(params:)), with: pair)
        }
        else if handler != nil
        {
            let error = NSError(domain: "Incomplete URL", code: -1, userInfo: [:])
            handler([], error)
        }
    }
    
    @objc static private func internalRequest(params : RequestPair)
    {
        var result : Data! = nil
        do
        {
            result = try Data(contentsOf: params.url)
        }
        catch
        {
            params.error = NSError(domain: "Connection problems or incorrect URL",
                                   code: -1, userInfo: ["URL" : params.url.description])
        }
        
        if params.error == nil && result != nil
        {
           do
           {
                let parse = try JSONSerialization.jsonObject(with: result, options: .mutableContainers)
                let dictionary = parse as? NSDictionary
                if dictionary != nil
                {
                    let searchResults = dictionary!["Search"] as? NSArray
                    if searchResults != nil
                    {
                        params.results = searchResults
                    }
                    else if dictionary!["Error"] != nil
                    {
                        params.error = NSError(domain:"Other problems",
                                               code: 0,
                                               userInfo: ["error" : dictionary!["Error"]!])
                    }
                    else
                    {
                        throw ParseError.IncorrectStructure
                    }
                }
                else
                {
                    throw ParseError.IncorrectResult
                }
           }
           catch
           {
                params.error = NSError(domain: "Response parsing error", code: -1, userInfo: nil)
           }
        }
        self.performSelector(onMainThread: #selector(self.requestResult(result:)), with: params, waitUntilDone: false)
    }
    
    @objc private static func requestResult(result : RequestPair)
    {
        if Thread.isMainThread == true
        {
            var models : Array<MovieModel> = []
            for value in (result.results ?? [])
            {
                let movieunit = value as? Dictionary<String, String>
                if movieunit != nil
                {
                    var model = MovieModel()
                    model.imdb = movieunit!["imdbID"]
                    let poster = movieunit!["Poster"]
                    if poster != nil
                    {
                        model.poster = URL(string: poster!)
                    }
                    model.title = movieunit!["Title"]
                    model.year = movieunit!["Year"]
                    model.mediatype = movieunit!["Type"]
                    models.append(model)
                }
            }
            result.handler(models, result.error)
        }
        else
        {
            self.performSelector(onMainThread: #selector(self.requestResult(result:)), with: result, waitUntilDone: false)
        }
    }
}
