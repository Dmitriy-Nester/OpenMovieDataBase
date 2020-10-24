import UIKit

class MovieCollectionCell : UICollectionViewCell
{
    private var model : MovieModel!
    static private var imageCache : Dictionary<String, UIImage> = [:]
    private var posterView : UIImageView = UIImageView()
    private var typeView : UILabel = UILabel()
    private var nameView : UILabel = UILabel()
    private var noPosterView : UILabel = UILabel()
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.subInit()
    }
    
    private func subInit()
    {
        self.contentView.backgroundColor = UIColor.orange.withAlphaComponent(0.2)
        self.contentView.layer.cornerRadius = 14
        let sframe = self.frame
        var bframe = CGRect(x: 5, y: 5, width: sframe.size.width - 10, height: (sframe.size.height - 10) * 0.6)
        posterView.frame = bframe
        posterView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        posterView.contentMode = .scaleAspectFit
        self.contentView.addSubview(posterView)
        bframe.origin.y += (5 + bframe.size.height)
        bframe.size.height = (sframe.size.height - (5 + bframe.origin.y )) * 0.5
        nameView.frame = bframe
        nameView.autoresizingMask = [.flexibleTopMargin, .flexibleHeight, .flexibleWidth]
        self.contentView.addSubview(nameView)
        bframe.origin.y += bframe.size.height
        typeView.frame = bframe
        typeView.autoresizingMask = nameView.autoresizingMask
        self.contentView.addSubview(typeView)
        noPosterView.text = "Poster absent or loading"
        noPosterView.sizeToFit()
        noPosterView.center = posterView.center
        posterView.addSubview(noPosterView)
    }
    
    public func setModel(model: MovieModel)
    {
        self.model = model
        if self.model.poster != nil
        {
            self.setImage(url: self.model.poster)
        }
        typeView.text = self.model.mediatype
        nameView.text = self.model.title
    }
    
    private func setImage(url : URL)
    {
        let image = Self.imageCache[url.description]
        if image == nil
        {
            weak var that = self
            let loadClosure : (()->Void) = {
            let data = NSData(contentsOf: url)
                if data != nil
                {
                    let download = UIImage(data: Data(referencing: data!))
                    if download != nil
                    {
                        Self.imageCache[url.description] = download!
                        if that?.model != nil && that?.model.poster != nil && that?.model.poster.description == url.description
                        {
                            that?.checkCache()
                        }
                    }
                }
            }
            DispatchQueue.global(qos: .background).async(execute:loadClosure)
        }
        else
        {
            noPosterView.isHidden = true
            posterView.image = image
        }
    }
    
    @objc private func checkCache()
    {
        if Thread.isMainThread == true
        {
            self.setImage(url: self.model.poster!)
        }
        else
        {
            self.performSelector(onMainThread: #selector(checkCache), with: nil, waitUntilDone: true)
        }
    }
    
    static public func resetCache()
    {
        self.imageCache.removeAll()
    }
    
    override func prepareForReuse()
    {
        super.prepareForReuse()
        self.model = nil
        self.posterView.image = nil
        self.nameView.text = nil
        self.typeView.text = nil
        self.noPosterView.isHidden = false
    }
}
