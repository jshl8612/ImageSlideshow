//
//  FullScreenSlideshowViewController.swift
//  ImageSlideshow
//
//  Created by Petr Zvoníček on 31.08.15.
//

import UIKit

@objcMembers
open class FullScreenSlideshowViewController: UIViewController {

    open var slideshow: ImageSlideshow = {
        let slideshow = ImageSlideshow()
        slideshow.zoomEnabled = true
        slideshow.contentScaleMode = UIViewContentMode.scaleAspectFit
        slideshow.pageIndicatorPosition = PageIndicatorPosition(horizontal: .center, vertical: .bottom)
        // turns off the timer
        slideshow.slideshowInterval = 0
        slideshow.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]

        return slideshow
    }()

    /// Close button 
    open var closeButton = UIButton()

    /// Close button frame
    open var closeButtonFrame: CGRect?

    /// Closure called on page selection
    open var pageSelected: ((_ page: Int) -> Void)?

    /// Index of initial image
    open var initialPage: Int = 0

    /// Input sources to 
    open var inputs: [InputSource]?

    /// Background color
    open var backgroundColor = UIColor.black

    /// Enables/disable zoom
    open var zoomEnabled = true {
        didSet {
            slideshow.zoomEnabled = zoomEnabled
        }
    }

    fileprivate var isInit = true

    override open func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = backgroundColor
        slideshow.backgroundColor = backgroundColor

        if let inputs = inputs {
            slideshow.setImageInputs(inputs)
        }

        view.addSubview(slideshow)
        
        // top navigation bar Background
        let naviBar = UIView()
        let naviBGColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5)
        naviBar.backgroundColor = naviBGColor
        naviBar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 60)
        view.addSubview(naviBar)
        
        

        // close button configuration
        closeButton.setImage(UIImage(named: "ic_cross_white", in: Bundle(for: type(of: self)), compatibleWith: nil), for: UIControlState())
        closeButton.addTarget(self, action: #selector(FullScreenSlideshowViewController.close), for: UIControlEvents.touchUpInside)

//        view.addSubview(closeButton)
        naviBar.addSubview(closeButton)
        
        
//         download button configuration
        let downloadButton = UIButton(type: .custom)
        
        let image = UIImage(named: "photoDownloadBtn",
                            in: Bundle(for: type(of: self)), compatibleWith: nil)

        downloadButton.setImage(image, for: .normal)
        downloadButton.addTarget(self, action: #selector(download), for: .touchUpInside)
        downloadButton.setTitle("다운로드", for: .normal)
        downloadButton.setTitleColor(.white, for: .normal)
        downloadButton.setTitleColor(UIColor.lightGray, for: .highlighted)
        downloadButton.semanticContentAttribute = .forceRightToLeft
        downloadButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 0)

        naviBar.addSubview(downloadButton)

        
        naviBar.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: naviBar, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: naviBar, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: naviBar, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        naviBar.addConstraint(NSLayoutConstraint(item: naviBar, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: (isiPhoneX ? 88 : 64)))
        
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        naviBar.addConstraint(NSLayoutConstraint(item: naviBar, attribute: .leading, relatedBy: .equal, toItem: closeButton, attribute: .leading, multiplier: 1, constant: -10))
        naviBar.addConstraint(NSLayoutConstraint(item: naviBar, attribute: .bottom, relatedBy: .equal, toItem: closeButton, attribute: .bottom, multiplier: 1, constant: 10))
        closeButton.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 0, constant: 40))
        closeButton.addConstraint(NSLayoutConstraint(item: closeButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 0, constant: 40))
        
        let trailingMargin = NSLayoutConstraint(item: downloadButton, attribute: .trailing, relatedBy: .equal, toItem: naviBar, attribute: .trailing, multiplier: 1, constant: -10)
        let topMargin = NSLayoutConstraint(item: downloadButton, attribute: .bottom, relatedBy: .equal, toItem: naviBar, attribute: .bottom, multiplier: 1, constant: -10)


        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([trailingMargin, topMargin])
    }

    override open var prefersStatusBarHidden: Bool {
        return true
    }

    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isInit {
            isInit = false
            slideshow.setCurrentPage(initialPage, animated: false)
        }
    }

    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        slideshow.slideshowItems.forEach { $0.cancelPendingLoad() }
    }

    open override func viewDidLayoutSubviews() {
        if !isBeingDismissed {
            let safeAreaInsets: UIEdgeInsets
            if #available(iOS 11.0, *) {
                safeAreaInsets = view.safeAreaInsets
            } else {
                safeAreaInsets = UIEdgeInsets.zero
            }
            
//            closeButton.frame = closeButtonFrame ?? CGRect(x: max(10, safeAreaInsets.left), y: max(10, safeAreaInsets.top), width: 40, height: 40)
        }

        slideshow.frame = view.frame
    }

    @objc func close() {
        // if pageSelected closure set, send call it with current page
        if let pageSelected = pageSelected {
            pageSelected(slideshow.currentPage)
        }

        dismiss(animated: true, completion: nil)
    }
    
    @objc func download(){
        let index = slideshow.currentPage == slideshow.slideshowItems.count-1 ? 0 : slideshow.currentPage+1
        if let image = slideshow.slideshowItems[index].imageView.image {
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            print("Save Success!!!!!!!")
            
            let alertController = UIAlertController(title: "",
                                                    message: "이미지를 저장하였습니다.",
                                                    preferredStyle: UIAlertController.Style.alert)
            alertController.addAction(UIAlertAction(title: "확인", style: UIAlertAction.Style.default,handler: nil))
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    fileprivate var isiPhoneX: Bool {
        switch UIScreen.main.nativeBounds.height {
        case 1136:
            //        print("iPhone 5 or 5S or 5C")
            return false
        case 1334:
            //        print("iPhone 6/6S/7/8")
            return false
        case 1920, 2208:
            //        print("iPhone 6+/6S+/7+/8+")
            return false
        case 2436:
            //        print("iPhone X, Xs")
            return true
        case 2688:
            //        print("iPhone Xs Max")
            return true
        case 1792:
            //        print("iPhone Xr")
            return true
        default:
            //        print("unknown")
            return false
        }
    }
}
