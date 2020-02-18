import Shuffle_iOS

class SampleCard: SwipeCard {
    
    override var swipeDirections: [SwipeDirection] {
        return [.left, .up, .right, .down]
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        footerHeight = 80
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func overlay(forDirection direction: SwipeDirection) -> UIView? {
        switch direction {
        case .left:
            return SampleCardOverlay.left()
        case .up:
            return SampleCardOverlay.up()
        case.right:
            return SampleCardOverlay.right()
        case .down:
            return SampleCardOverlay.down()
        default:
            return nil
        }
    }
    
    func configure(withModel model: SampleCardModel) {
        content = SampleCardContentView(withImage: model.image)
        footer = SampleCardFooterView(withTitle: "\(model.name), \(model.age)", subtitle: model.occupation)
    }
    
    func configureFB(withModel model: CardModel) {
//        let stringURL = URL(string: model.imageURL!)!
//        let imageRetrieved = UIImage(data: try! Data(contentsOf: stringURL))
//        content = SampleCardContentView(withImage: imageRetrieved)
        print("configuring fb")
        content = SampleCardContentView(withImageURL: model.imageURL)
        footer = SampleCardFooterView(withTitle: model.name, subtitle: model.country)
     }
}
